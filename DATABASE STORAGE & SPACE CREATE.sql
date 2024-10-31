1. To check the space usage in an Oracle database, you can use a SQL query to view tablespace usage. Here’s a query to get detailed information about the used and free space in each tablespace:
   
   SELECT
    df.tablespace_name AS "Tablespace",
    df.bytes / 1024 / 1024 AS "Size (MB)",
    (df.bytes - NVL(fs.bytes, 0)) / 1024 / 1024 AS "Used (MB)",
    NVL(fs.bytes, 0) / 1024 / 1024 AS "Free (MB)",
    ROUND(((df.bytes - NVL(fs.bytes, 0)) / df.bytes) * 100, 2) AS "Used (%)"
FROM
    (SELECT tablespace_name, SUM(bytes) AS bytes
     FROM dba_data_files
     GROUP BY tablespace_name) df
LEFT JOIN
    (SELECT tablespace_name, SUM(bytes) AS bytes
     FROM dba_free_space
     GROUP BY tablespace_name) fs
ON df.tablespace_name = fs.tablespace_name
ORDER BY "Used (%)" DESC;

Explanation
Tablespace: The name of the tablespace.
Size (MB): Total size of the tablespace in MB.
Used (MB): Used space in the tablespace in MB.
Free (MB): Free space in the tablespace in MB.
Used (%): The percentage of space used in the tablespace.
This query will help you monitor tablespace usage and determine if any require resizing or cleanup.



Step 1: Check Existing Datafile Paths
You can check the existing datafiles for each tablespace by running:

sql
### 
SELECT tablespace_name, file_name, bytes / 1024 / 1024 AS "Size (MB)"
FROM dba_data_files
WHERE tablespace_name IN ('SYSTEM', 'SYSAUX', 'USERS');
Step 2: Add Space to Tablespaces
For SYSTEM Tablespace
Adding a New Datafile:

sql
### 
ALTER TABLESPACE SYSTEM
ADD DATAFILE '/u01/app/oracle/oradata/orcl/system02.dbf' SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
Or Resizing an Existing Datafile:

sql
### 
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/orcl/system01.dbf' RESIZE 2600M;
For SYSAUX Tablespace
Adding a New Datafile:

sql
### 
ALTER TABLESPACE SYSAUX
ADD DATAFILE '/u01/app/oracle/oradata/orcl/sysaux02.dbf' SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
Or Resizing an Existing Datafile:

sql
### 
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/orcl/sysaux01.dbf' RESIZE 4000M;
For USERS Tablespace
Adding a New Datafile:

sql
### 
ALTER TABLESPACE USERS
ADD DATAFILE '/u01/app/oracle/oradata/orcl/users02.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
Or Resizing an Existing Datafile:

sql
### 
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/orcl/users01.dbf' RESIZE 500M;
After making these changes, recheck the space with:

sql
### 
SELECT tablespace_name, bytes / 1024 / 1024 AS "Total Size (MB)", (bytes - NVL(fs.bytes, 0)) / 1024 / 1024 AS "Used (MB)", NVL(fs.bytes, 0) / 1024 / 1024 AS "Free (MB)"
FROM (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_data_files GROUP BY tablespace_name) df
LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS bytes FROM dba_free_space GROUP BY tablespace_name) fs
ON df.tablespace_name = fs.tablespace_name
WHERE df.tablespace_name IN ('SYSTEM', 'SYSAUX', 'USERS');





/// RANGS  APPS SERVER // 

Since your datafiles are located in F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\, here’s how you can increase space in each tablespace using the specific file paths.

For SYSTEM Tablespace
Resizing SYSTEM datafile:

sql
### 
ALTER DATABASE DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\SYSTEM01.DBF' RESIZE 2500M;
Or adding a new datafile:

sql
### 
ALTER TABLESPACE SYSTEM
ADD DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\SYSTEM02.DBF' SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
For SYSAUX Tablespace
Resizing SYSAUX datafile:

sql
### 
ALTER DATABASE DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\SYSAUX01.DBF' RESIZE 4000M;
Or adding a new datafile:

sql
### 
ALTER TABLESPACE SYSAUX
ADD DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\SYSAUX02.DBF' SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
For USERS Tablespace
Resizing USERS datafile:

sql
### 
ALTER DATABASE DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\USERS01.DBF' RESIZE 500M;
Or adding a new datafile:

sql
### 
ALTER TABLESPACE USERS
ADD DATAFILE 'F:\APPSDB12C\ADMINISTRATOR\ORADATA\ORCLDB\ORCLPDB\USERS02.DBF' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;
After running these commands, verify the new space allocation by running:

sql
### 
SELECT tablespace_name, file_name, bytes / 1024 / 1024 AS "Size (MB)"
FROM dba_data_files
WHERE tablespace_name IN ('SYSTEM', 'SYSAUX', 'USERS');
This should ensure that each tablespace has sufficient room for continued operation. Let me know if you need any further adjustments.