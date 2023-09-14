#!/bin/bash

export NLS_LANG=AMERICAN_AMERICA.UTF8

echo -n "Do you have properly installed oracle client(Y|N) (sqlplus start with no problem)? [Y]: "
read ORA_CLIENT_

if [ "$ORA_CLIENT_" == "N" ]; then

   ORACLE_CLIENT_PATH="/home/csn/instantclient_21_3"
   TNS_ADMIN="/home/csn"

   echo -n "Enter path to oracle client (default $ORACLE_CLIENT_PATH) and press enter: "
   read ORACLE_CLIENT_PATH_

   if [ -n "$ORACLE_CLIENT_PATH_" ]; then
      ORACLE_CLIENT_PATH=$ORACLE_CLIENT_PATH_
   fi

   echo -n "Enter path to tnsnames.ora (default $TNS_ADMIN) and press enter: "
   read TNS_ADMIN_

   if [ -n "$TNS_ADMIN_" ]; then
      TNS_ADMIN=$TNS_ADMIN_
   fi

   export PATH=$ORACLE_CLIENT_PATH:$PATH
   export LD_LIBRARY_PATH=$ORACLE_CLIENT_PATH:$LD_LIBRARY_PATH
   export TNS_ADMIN=$TNS_ADMIN

fi

echo -n "Enter test number (1, 2, 3) and press enter: "
read TEST_NUMBER_

if [ -z "$TEST_NUMBER_" ] || ! [[ $TEST_NUMBER_ =~ ^[1-3]{1}$ ]]; then
   echo "Error. Incorrect test number!"
   exit 1
fi

echo "Execute test" $TEST_NUMBER_

echo -n "Enter the connect string (username@tnsname) and press enter: "
read ORAUID_

if [ -z "$ORAUID_" ]; then
   echo "Error. Incorrect connect string (empty)!"
   exit 1
fi

if [[ "$ORAUID_" =~ "^[^@]+@[^@]+$" ]]; then
   echo "Error. Incorrect connect string (format)!"
   exit 1
fi

sqlplus $orauid @'../../task'$TEST_NUMBER_'/query.sql'
