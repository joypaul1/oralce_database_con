impdp DEVELOPERS/Test1234@10.99.99.20:1525/ORCLPDB dumpfile=TEST_DATA.dmp directory=DATA_PUMP_DIR REMAP_SCHEMA=developers2:DEVELOPERS
impdp TESTDB/Test123@localhost/ORCL schemas=TESTDB dumpfile=26_06_2024_23_40.dmp directory=E:\oracle_database REMAP_SCHEMA=TESTDB:26_06_2024_23_40
impdp TestDB/Test123@localhost/ORCL schemas=TESTDB directory=E:\oracle_database dumpfile=26_06_2024_23_40.DMP logfile=impdp.log
impdp system/password@ORCL11 schemas=atgdb_cata dumpfile=MYDATA.dmp logfile=log.txt remap_schema=atgdb_cata:cata

**** WORKING ****
impdp SYS/Test123456 dumpfile=MYDATA.DMP directory=ORACLE_DATABASE
impdp SYS/Test123456 dumpfile=MYDATA.DMP directory=RESALE_ORACLE_DATABASE
impdp RESALE/resale@ORCL dumpfile=MYDATA.DMP directory=RESALE_ORACLE_DATABASE



expdp DEVELOPERS/Test1234@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_DEVELOPERS_mrg.dmp directory=DATA_PUMP_DIR
expdp RESALE/resale@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_jRESALE_mrg.dmp directory=RESALE_DATA_PUMP_DIR
expdp WSHOP/wshop123Test@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_WSHOP_mrg.dmp directory=RESALE_DATA_PUMP_DIR
expdp LOYALTY/LOYALTYP@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_loyalty_mrg.dmp directory=RESALE_DATA_PUMP_DIR
expdp COUPON_SERVICE/RMLIT2024CUP@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_coupon_mrg.dmp directory=RESALE_DATA_PUMP_DIR
expdp DEV_PROCEDURE/RMLIT2024DEV@10.99.99.20:1525/ORCLPDB dumpfile=13_02_2025_joy_devpro_mrg.dmp directory=RESALE_DATA_PUMP_DIR


expdp WSHOP/wshop123Test@10.99.99.20:1525/ORCLPDB dumpfile=31_10_2024_joy_cspd_mrg.dmp directory=RESALE_DATA_PUMP_DIR
expdp LOYALTY/LOYALTYP@10.99.99.20:1525/ORCLPDB dumpfile=31_10_2024_joy_loyalty_mrg.dmp directory=RESALE_DATA_PUMP_DIR