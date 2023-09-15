ECHO OFF

chcp 1251

FOR /F "skip=1" %%g IN ('wmic os get localdatetime') DO (SET START_DATE=%%g) & GOTO done
:done
SET START_DATE=%START_DATE:~0,12%

FOR /F "tokens=*" %%g IN ('ver') DO (SET PLATFORM=%%g)
SET PLATFORM=%PLATFORM: =_%
SET PLATFORM=%PLATFORM:.=_%
SET PLATFORM=%PLATFORM:"=_%
SET PLATFORM=%PLATFORM:[=_%
SET PLATFORM=%PLATFORM:]=_%
SET PLATFORM=%PLATFORM:__=_%

SET NLS_LANG=AMERICAN_AMERICA.UTF8

SET /p TEST_NUMBER="������� ����� ����� (1|2|3) � ������� ����:" 

IF "%TEST_NUMBER%" == "1" SET "NOTERROR=Y"
IF "%TEST_NUMBER%" == "2" SET "NOTERROR=Y"
IF "%TEST_NUMBER%" == "3" SET "NOTERROR=Y"

IF NOT DEFINED NOTERROR (
  ECHO ������! ������ ������������ ����� �����
  EXIT 1
)

ECHO �������� ���� %TEST_NUMBER%

SET /p ORAUID="������� ������ ���������� � ����� ������ � ������� username@tnsname � ������� ����: " 

IF "%ORAUID%" == "" SET "ERROR=Y"
IF %ORAUID:@=% == %ORAUID% SET "ERROR=Y"

IF DEFINED ERROR (
  ECHO ������! ������� ������������ ������ ���������� � ����� ������
  EXIT 1
)

IF EXIST query.log (
  del /F /Q  query.log
)

chcp 65001

sqlplus %ORAUID% @"../../task%TEST_NUMBER%/query.sql"

rename query.log "query%TEST_NUMBER%_%START_DATE%_%PLATFORM%.log"
