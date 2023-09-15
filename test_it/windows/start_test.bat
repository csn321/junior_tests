ECHO OFF

SET NLS_LANG=AMERICAN_AMERICA.UTF8

SET /p TEST_NUMBER="Enter test number (1, 2, 3) and press enter: " 

IF "%TEST_NUMBER%" == "1" SET "NOTERROR=Y"
IF "%TEST_NUMBER%" == "2" SET "NOTERROR=Y"
IF "%TEST_NUMBER%" == "3" SET "NOTERROR=Y"

IF NOT DEFINED NOTERROR (
  ECHO "Incorrect text number %TEST_NUMBER%"
  EXIT 1
)

ECHO "Execute test %TEST_NUMBER%"

SET /p ORAUID="Enter the connect string (username@tnsname) and press enter: " 

IF "%ORAUID%" == "" SET "ERROR=Y"
IF %ORAUID:@=% == %ORAUID% SET "ERROR=Y"

IF DEFINED ERROR (
  ECHO "Incorrect connect string %ORAUID%"
  EXIT 1
)

sqlplus %ORAUID% @"../../task%TEST_NUMBER%/query.sql"
