IF MY ORACLE D:\app\oracle12bd\product\12.2.0\dbhome_1
Based on this information, here's how you can proceed with running the `impdp` command:

### Step-by-Step Process

1. **Open Command Prompt as Administrator:**
   - Press `Win + S` to open the search bar.
   - Type `cmd`.
   - Right-click on `Command Prompt` and select `Run as administrator`.

2. **Set Oracle Environment Variables:**
   - Set the `ORACLE_SID` and `ORACLE_HOME` environment variables in Command Prompt.

   ```shell
   set ORACLE_SID=ORCL
   set ORACLE_HOME=D:\app\oracle12bd\product\12.2.0\dbhome_1
   ```

   Replace `D:\app\oracle12bd\product\12.2.0\dbhome_1` with your actual Oracle Home directory path.

3. **Connect to SQL*Plus with SYSDBA Privileges:**
   - Open SQL*Plus:

   ```shell
   sqlplus / as sysdba
   ```

   - Enter your SYSDBA password when prompted.

4. **Verify and Prepare Directory Object:**
   - Check if the directory object (`DATA_PUMP_DIR`) exists and is correctly set up in Oracle.

   ```sql
   SELECT directory_name, directory_path FROM dba_directories WHERE directory_name = 'DATA_PUMP_DIR';
   ```

   If it doesn't exist, create it:

   ```sql
   CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS 'D:\ORALCE_DATABASE';
   ```

   Grant necessary privileges:

   ```sql
   GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO SYS;
   ```

5. **Create the Parameter File (`D:\impdp_params.par`):**
   - Create a parameter file (`D:\impdp_params.par`) with the necessary import parameters:

   ```plaintext
   DIRECTORY=DATA_PUMP_DIR
   DUMPFILE=MYDATA.DMP
   LOGFILE=imp.log
   REMAP_SCHEMA=MYDATA:DEVELOPERS
   ```

   Adjust `DUMPFILE`, `LOGFILE`, and `REMAP_SCHEMA` as per your specific import requirements.

6. **Run the `impdp` Command:**
   - Exit SQL*Plus if you're still connected (`EXIT`).
   - Run the `impdp` command from Command Prompt using the parameter file:

   ```shell
   impdp \"SYS/Oralcerangs_2024@ORCL AS SYSDBA\" parfile=D:\impdp_params.par
   ```

   Note the use of escaped double quotes (`\"`) around `"SYS/Oralcerangs_2024@ORCL AS SYSDBA"` to ensure it's treated as a single parameter.

This process should allow you to run the `impdp` command with SYSDBA privileges and import your data using the parameter file (`D:\impdp_params.par`). If you encounter any specific errors or issues during these steps, feel free to ask for further assistance!