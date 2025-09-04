/* Formatted on 11/08/2025 3:24:08 PM (QP5 v5.287) */
CREATE OR REPLACE FUNCTION IS_SASH_OR_CARAT (p_rml_id VARCHAR2)
   RETURN NUMBER
IS
   V_COUNT   NUMBER := 0;
BEGIN
   SELECT 1
     INTO V_COUNT
     FROM DEVELOPERS.RML_HR_APPS_USER
    WHERE RML_ID = p_rml_id AND UPPER (R_CONCERN) IN ('SASH', 'CARAT');

   RETURN CASE WHEN V_COUNT > 0 THEN 1 ELSE 0 END;
END;
/

-- CURRENT MONTH & YEAR WISE CHECK THE

CREATE OR REPLACE FUNCTION HR_MONTHLY_CL_TAKEN_INCL_HCL (p_rml_id VARCHAR2)
   RETURN NUMBER
IS
   v_year      NUMBER := EXTRACT (YEAR FROM SYSDATE);
   v_month     NUMBER := EXTRACT (MONTH FROM SYSDATE);
   v_full_cl   NUMBER := 0;
   v_half_cl   NUMBER := 0;
BEGIN
   -- Full-day CL taken in that month
   SELECT NVL (SUM ( (TRUNC (end_date) - TRUNC (start_date) + 1)), 0)
     INTO v_full_cl
     FROM DEVELOPERS.RML_HR_EMP_LEAVE
    WHERE     RML_ID = p_rml_id
          AND LEAVE_TYPE = 'CL'
          AND LINE_MNGR_APVL_STS = 1
          AND EXTRACT (YEAR FROM SYSDATE) = v_year
          AND EXTRACT (MONTH FROM SYSDATE) = v_month;

   -- Half-day CL count (HCL is always single-day per our rule)
   SELECT NVL (COUNT (*), 0)
     INTO v_half_cl
     FROM DEVELOPERS.RML_HR_EMP_LEAVE
    WHERE     RML_ID = p_rml_id
          AND LEAVE_TYPE = 'HCL'
          AND LINE_MNGR_APVL_STS = 1
          AND EXTRACT (YEAR FROM SYSDATE) = v_year
          AND EXTRACT (MONTH FROM SYSDATE) = v_month;

   RETURN v_full_cl + (0.5 * v_half_cl);
END;
/

-- CURRENT YEAR WISE CHECK THE

CREATE OR REPLACE FUNCTION HR_YEARLY_CL_TAKEN_INCL_HCL (p_rml_id VARCHAR2)
   RETURN NUMBER
IS
   v_year      NUMBER := EXTRACT (YEAR FROM SYSDATE);
   v_full_cl   NUMBER := 0;
   v_half_cl   NUMBER := 0;
BEGIN
   -- Full-day CL taken in that month
   SELECT NVL (SUM ( (TRUNC (end_date) - TRUNC (start_date) + 1)), 0)
     INTO v_full_cl
     FROM DEVELOPERS.RML_HR_EMP_LEAVE
    WHERE     RML_ID = p_rml_id
          AND LEAVE_TYPE = 'CL'
          AND LINE_MNGR_APVL_STS = 1
          AND EXTRACT (YEAR FROM SYSDATE) = v_year;

   -- Half-day CL count (HCL is always single-day per our rule)
   SELECT NVL (COUNT (*), 0)
     INTO v_half_cl
     FROM DEVELOPERS.RML_HR_EMP_LEAVE
    WHERE     RML_ID = p_rml_id
          AND LEAVE_TYPE = 'HCL'
          AND LINE_MNGR_APVL_STS = 1
          AND EXTRACT (YEAR FROM SYSDATE) = v_year;

   RETURN v_full_cl + (0.5 * v_half_cl);
END;
/

-- CL balance (yearly) including HCL as 0.5

CREATE OR REPLACE FUNCTION GET_CL_BALANCE_INCL_HCL (p_rml_id    VARCHAR2,
                                                    p_year      VARCHAR2)
   RETURN NUMBER
IS
   v_assign    NUMBER := 0;
   v_taken     NUMBER := 0;          -- LEAVE_TAKEN + LATE_LEAVE from the view
   v_hcl_cnt   NUMBER := 0;
BEGIN
   -- Base CL assignment and taken from the yearly view
   SELECT NVL (LEAVE_ASSIGN, 0), NVL (LEAVE_TAKEN + LATE_LEAVE, 0)
     INTO v_assign, v_taken
     FROM LEAVE_DETAILS_INFORMATION
    WHERE RML_ID = p_rml_id AND LEAVE_PERIOD = p_year AND LEAVE_TYPE = 'CL';

   -- Count HCL entries for that year (approved only)
   SELECT NVL (COUNT (*), 0)
     INTO v_hcl_cnt
     FROM RML_HR_EMP_LEAVE
    WHERE     RML_ID = p_rml_id
          AND LEAVE_TYPE = 'HCL'
          AND LINE_MNGR_APVL_STS = 1
          AND TO_CHAR (START_DATE, 'YYYY') = p_year;

   RETURN v_assign - (v_taken + 0.5 * v_hcl_cnt);
END;
/


-- Short Leave trigger (max 3 per month)
CREATE OR REPLACE TRIGGER TRG_SHL_LEAVE_LIMIT
   BEFORE INSERT
   ON RML_HR_EMP_LEAVE
   FOR EACH ROW
   WHEN (NEW.LEAVE_TYPE = 'SHL')
DECLARE
   V_COUNT   NUMBER := 0;
BEGIN
   --ELIGIBITY CHECK
   IF IS_SASH_OR_CARAT (:NEW.RML_ID) = 0
   THEN
      RAISE_APPLICATION_ERROR (-20001,'Short leave is only for SASH and CART.');
   END IF;

   -- Normalize to single-day entry
   IF TRUNC (:NEW.START_DATE) <> TRUNC (:NEW.END_DATE)
   THEN
      RAISE_APPLICATION_ERROR (-20001, 'Short leave must be a single date.');
   END IF;

   SELECT COUNT (*)
     INTO V_COUNT
     FROM RML_HR_EMP_LEAVE
    WHERE     RML_ID = :NEW.RML_ID
          AND LEAVE_TYPE = 'SHL'
          AND LINE_MNGR_APVL_STS = 1
          AND EXTRACT (YEAR FROM START_DATE) =
                 EXTRACT (YEAR FROM :NEW.START_DATE)
          AND EXTRACT (MONTH FROM START_DATE) =
                 EXTRACT (MONTH FROM :NEW.START_DATE);

   IF V_COUNT >= 3
   THEN
      RAISE_APPLICATION_ERROR (-20001, 'Short leave limit get 3 monthly exceeded.');
   END IF;
END;
/