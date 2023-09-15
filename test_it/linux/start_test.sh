#!/bin/bash

#PLATFORM=linux

PLATFORM=`hostnamectl | grep "Operating"`
PLATFORM=${PLATFORM#*\:}
PLATFORM=`echo $PLATFORM | xargs`
PLATFORM=${PLATFORM// /_}
PLATFORM=${PLATFORM//\./_}

ORACLE_CLIENT_PATH="/home/csn/instantclient_21_3"
TNS_ADMIN="/home/csn"

export NLS_LANG=AMERICAN_AMERICA.UTF8

echo -n "У вас установлен и настроен oracle-клиент таким образом, что sqlplus запускается из командной строки (Y|N)? [Y]: "
read ORA_CLIENT_

if [ "$ORA_CLIENT_" == "N" ]; then

   echo -n "Предполагаю, что oracle-клиент установлен локально. Укажите путь к oracle-клиенту (по-умолчанию $ORACLE_CLIENT_PATH) и нажмите ввод: "
   read ORACLE_CLIENT_PATH_

   if [ -n "$ORACLE_CLIENT_PATH_" ]; then
      ORACLE_CLIENT_PATH=$ORACLE_CLIENT_PATH_
   fi

   echo -n "Укажите путь к файлу tnsnames.ora (по-умолчанию $TNS_ADMIN) и нажмите ввод: "
   read TNS_ADMIN_

   if [ -n "$TNS_ADMIN_" ]; then
      TNS_ADMIN=$TNS_ADMIN_
   fi

   export PATH=$ORACLE_CLIENT_PATH:$PATH
   export LD_LIBRARY_PATH=$ORACLE_CLIENT_PATH:$LD_LIBRARY_PATH
   export TNS_ADMIN

fi

echo -n "Укажите номер теста (1|2|3) и нажмите ввод: "
read TEST_NUMBER_

if [ -z "$TEST_NUMBER_" ] || ! [[ $TEST_NUMBER_ =~ ^[1-3]{1}$ ]]; then
   echo "Ошибка! Указан некорректный номер теста."
   exit 1
fi

echo "Выполняю тест" $TEST_NUMBER_

echo -n "Введите строку соединения с базой данных в формате username@tnsname и нажмите ввод: "
read ORAUID_

if [ -z "$ORAUID_" ]; then
   echo "Ошибка! Указана некорректная строка соединения с базой данных (пустая)."
   exit 1
fi

if ! [[ $ORAUID_ =~ ^[^@]+@[^@]+$ ]]; then
   echo "Ошибка! Указана некорректная строка соединения с базой данных (неправильный формат)."
   exit 1
fi

rm -f query.log

sqlplus $ORAUID_ @'../../task'$TEST_NUMBER_'/query.sql'

mv query.log "query${TEST_NUMBER_}_`date '+%Y%m%d'`_${PLATFORM}.log" 2>/dev/null
