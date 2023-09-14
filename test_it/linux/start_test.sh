#!/bin/bash

export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=/home/csn/instantclient_21_3:$PATH
export LD_LIBRARY_PATH=/home/csn/instantclient_21_3:$LD_LIBRARY_PATH
export TNS_ADMIN=/home/csn

echo -n "Enter test number (1, 2, 3) and press enter: "
read test_number

echo "Execute test" $test_number

if [ $test_number -lt 1 ] || [ $test_number -gt 3 ]; then
   echo "Error. Incorrect test number!"
   exit 1
fi

echo -n "Enter the connect string (username@tnsname) and press enter: "
read orauid

if [ -z "$orauid" ]; then
   echo "Error. Incorrect connect string (empty)!"
   exit 1
fi

if [[ "$orauid" =~ "^[^@]+@[^@]+$" ]]; then
   echo "Error. Incorrect connect string (format)!"
   exit 1
fi

sqlplus $orauid @'../../task'$test_number'/query.sql'
