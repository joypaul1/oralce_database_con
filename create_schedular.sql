BEGIN
  -- Create the job
  DBMS_SCHEDULER.create_job (
    job_name        => 'UPDATE_SALES_COLLECTION_EMI_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN DEV_PROCEDURE.UPDATE_SALES_AND_COLLECTION_EMI; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=2', -- every 2 hours
    enabled         => TRUE,
    comments        => 'Job to update sales and collection EMI every 2 hours'
  );
END;
/


BEGIN
  -- Create the job
  DBMS_SCHEDULER.create_job (
    job_name        => 'UPDATE_DATA_SYSNC_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN DEVELOPERS."RML_COLL_CCD_DATA_SYN"; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=3', -- every 2 hours
    enabled         => TRUE,
    comments        => 'Job to update dev sync data every 3 hours'
  );
END;
/

BEGIN
  -- Create the job
  DBMS_SCHEDULER.create_job (
    job_name        => 'UPDATE_INVOICE_STATUS_PROC_LEASE_TRANSFER',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN LEASE_TRANSFER.UPDATE_INVOICE_STATUS_PROC END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=HOURLY; INTERVAL=2', -- every 2 hours
    enabled         => TRUE,
    comments        => 'Job to update UPDATE_INVOICE_STATUS_PROC sync data every 3 hours'
  );
END;
/



SELECT job_name, enabled, last_start_date, next_run_date, last_run_duration
FROM USER_SCHEDULER_JOBS;




CREATE OR REPLACE PROCEDURE DEV_PROCEDURE.UPDATE_SALES_AND_COLLECTION_EMI
AS
BEGIN
   -- Starting the transaction
   SAVEPOINT start_update;

   BEGIN
      -- First procedure: EMI_ERP_VIEW_DATA_COPY
      BEGIN
         DEVELOPERS.EMI_ERP_VIEW_DATA_COPY;
      EXCEPTION
         WHEN OTHERS THEN
            -- Rollback to the savepoint if this procedure fails
            ROLLBACK TO start_update;
            DBMS_OUTPUT.PUT_LINE('Error in EMI_ERP_VIEW_DATA_COPY: ' || SQLERRM);
            INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
            VALUES ('EMI_ERP_VIEW_DATA_COPY: ' || SQLERRM, SYSDATE);
            RAISE;  -- Reraise to halt the process
      END;

      -- Second procedure: UPDATE_EMI_PROCESSING
      BEGIN
         DEVELOPERS.UPDATE_EMI_PROCESSING;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO start_update;
            DBMS_OUTPUT.PUT_LINE('Error in UPDATE_EMI_PROCESSING: ' || SQLERRM);
            INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
            VALUES ('UPDATE_EMI_PROCESSING: ' || SQLERRM, SYSDATE);
            RAISE;
      END;

      -- Third procedure: UPDATE_SALES_MAN_PROFILE_EMI
      BEGIN
         DEVELOPERS.UPDATE_SALES_MAN_PROFILE_EMI;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO start_update;
            DBMS_OUTPUT.PUT_LINE('Error in UPDATE_SALES_MAN_PROFILE_EMI: ' || SQLERRM);
            INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
            VALUES ('UPDATE_SALES_MAN_PROFILE_EMI: ' || SQLERRM, SYSDATE);
            RAISE;
      END;

      -- Repeat this pattern for the remaining procedures
      BEGIN
         DEVELOPERS.UPDATE_SALES_GREEN_ZONE_EMI;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO start_update;
            DBMS_OUTPUT.PUT_LINE('Error in UPDATE_SALES_GREEN_ZONE_EMI: ' || SQLERRM);
            INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
            VALUES ('UPDATE_SALES_GREEN_ZONE_EMI: ' || SQLERRM, SYSDATE);
            RAISE;
      END;

      BEGIN
         DEVELOPERS.UPDATE_SALES_MAN_ACTIVE_EMI;
      EXCEPTION
         WHEN OTHERS THEN
            ROLLBACK TO start_update;
            DBMS_OUTPUT.PUT_LINE('Error in UPDATE_SALES_MAN_ACTIVE_EMI: ' || SQLERRM);
            INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
            VALUES ('UPDATE_SALES_MAN_ACTIVE_EMI: ' || SQLERRM, SYSDATE);
            RAISE;
      END;

      -- Add similar blocks for the remaining procedures...

      -- If all procedures succeed, commit the changes
      COMMIT;

   EXCEPTION
      WHEN OTHERS THEN
         -- If something fails, rollback the whole transaction
         ROLLBACK;
         DBMS_OUTPUT.PUT_LINE('Error in procedure execution: ' || SQLERRM);
         INSERT INTO DEV_PROCEDURE.ERROR_LOG (ERROR_MESSAGE, ERROR_TIMESTAMP)
         VALUES ('General error: ' || SQLERRM, SYSDATE);
         RAISE;  -- Optionally, re-raise to propagate the error
   END;
END;
/
