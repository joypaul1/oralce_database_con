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
