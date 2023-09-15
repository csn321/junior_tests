#!/bin/bash

echo -n "Выполнить создание объектов базы данных для тестов (Y|N)? [N]: "
read INSTALL_TEST_

if ! [ "$INSTALL_TEST_" == "Y" ]; then
   exit 1
fi

echo "Создаю объекты базы данных для тестов"

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

rm -f install.log

sqlplus $ORAUID_ @'../../task1/install.sql'

touch install.txt

cat install.log tables.log sequences.log indexes.log data.log > install.txt

mv install.txt "install_`date '+%Y%m%d'`_${PLATFORM}.log" 2>/dev/null
