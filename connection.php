<?php

// Create connection to Oracle
// $objConnect=oci_connect("DEVELOPERS","Test1234","10.99.99.20:1525/ORCLPDB",'AL32UTF8');
$conn = oci_connect("TESTDB", "Test123", "localhost:1521/ORCL",);
// $conn = oci_connect("DB_NAME", "DB_PASSWORD", "DB_IP:PORT_NO/DATABASE_NAME");
// (DESCRIPTION =
//       (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
//       (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
//     )
if (!$conn) {
  
$m = oci_error();
  
echo $m['message'], "\n";
 
exit;

}
else {
  
echo "Connected to Oracle DB!";

}

// $allDataSQL  = oci_parse(
//     $conn,
//     "SELECT *  FROM PERSONS"
// );

// oci_execute($allDataSQL);
// $number = 0;
// while ($row = oci_fetch_assoc($allDataSQL)) {
//     print_r($row);
// }

// Close the Oracle connection

oci_close($conn);
?>
