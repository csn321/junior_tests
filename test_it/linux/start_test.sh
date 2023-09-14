#!/bin/bash

export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=/home/csn/instantclient_21_3:$PATH
export LD_LIBRARY_PATH=/home/csn/instantclient_21_3:$LD_LIBRARY_PATH
export TNS_ADMIN=/home/csn

ORAUID=waterman@giszkh_test

#ORAUID=waterman/ubgth6jkf
#sqlplus

echo -n "Enter test number (1, 2, 3) and press enter: "
read test_number

echo -n "Execute test" $test_number

if [ $test_number -lt 1 ] || [ $test_number -gt 3 ]; then
   echo "Error. Incorrect test number!"
   exit 1
fi

sqlplus $ORAUID @'../../task'$test_number'/query.sql'

#sqlplus $ORAUID << END
#@@../../task'$test_number'/query.sql
#END
