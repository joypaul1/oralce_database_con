### Connect as SYSDBA or a privileged user to grant SELECT ANY TABLE
sqlplus SYS/Test123456@your_db as SYSDBA
GRANT SELECT ANY TABLE TO joy;

### Connect as DEVELOPERS user to create public synonyms
sqlplus DEVELOPERS/your_developers_password@your_db

BEGIN
   FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'DEVELOPERS') LOOP
      EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM ' || t.table_name || ' FOR DEVELOPERS.' || t.table_name;
   END LOOP;
END;
/

BEGIN
   FOR v IN (SELECT view_name FROM all_views WHERE owner = 'DEVELOPERS') LOOP
      EXECUTE IMMEDIATE 'CREATE PUBLIC SYNONYM ' || v.view_name || ' FOR DEVELOPERS.' || v.view_name;
   END LOOP;
END;
/
 
### Ensure the privileges are granted explicitly on all objects
BEGIN
   FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'DEVELOPERS') LOOP
      EXECUTE IMMEDIATE 'GRANT SELECT ON DEVELOPERS.' || t.table_name || ' TO joy';
   END LOOP;
END;
/

BEGIN
   FOR v IN (SELECT view_name FROM all_views WHERE owner = 'DEVELOPERS') LOOP
      EXECUTE IMMEDIATE 'GRANT SELECT ON DEVELOPERS.' || v.view_name || ' TO joy';
   END LOOP;
END;
/

### Verify access as JOY user
sqlplus joy/your_joy_password@your_db
SELECT table_name FROM all_tables WHERE owner = 'DEVELOPERS';
SELECT view_name FROM all_views WHERE owner = 'DEVELOPERS';
