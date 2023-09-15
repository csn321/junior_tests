--
-- Copyright (C) ООО "ХардСофт321" https://hardsoft321.org/license
-- Это программа является свободным программным обеспечением. Вы можете
-- распространять и/или модифицировать её согласно условиям Стандартной
-- Общественной Лицензии GNU, опубликованной Фондом Свободного Программного
-- Обеспечения, версии 3.
-- Эта программа распространяется в надежде, что она будет полезной, но БЕЗ
-- ВСЯКИХ ГАРАНТИЙ, в том числе подразумеваемых гарантий ТОВАРНОГО СОСТОЯНИЯ ПРИ
-- ПРОДАЖЕ и ГОДНОСТИ ДЛЯ ОПРЕДЕЛЁННОГО ПРИМЕНЕНИЯ. Смотрите Стандартную
-- Общественную Лицензию GNU для получения дополнительной информации.
-- Вы должны были получить копию Стандартной Общественной Лицензии GNU вместе
-- с программой. В случае её отсутствия, посмотрите http://www.gnu.org/licenses/.
-- Перевод на русский язык: https://code.google.com/archive/p/gpl3rus/wikis/LatestRelease.wiki
--
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET LINESIZE 200
SET MARKUP HTML PREFORMAT ON
SET PAGESIZE 0 EMBEDDED ON
SET COLSEP ' | '
SET FEED OFF
SET DEFINE OFF
SET SERVEROUTPUT ON
--
COLUMN fio HEADING "ФИО" FORMAT a40
COLUMN address HEADING "Адрес" FORMAT a40
COLUMN postal_code HEADING "Почтовый индекс" FORMAT a16
COLUMN begin_date HEADING "Дата прописки" FORMAT a14
COLUMN end_date HEADING "Дата выписки" FORMAT a14
COLUMN error_text HEADING "" FORMAT a120
--
ACCEPT p_mode_str DEFAULT '0' PROMPT 'Введите режим выполнения запроса [-1, 0, 1]: '
--
VARIABLE p_mode NUMBER;
--
BEGIN
 SELECT DECODE('&&p_mode_str', '0', 0, '1', 1, '-1', -1, 0) INTO :p_mode FROM dual;
END;
/
--
SPOOL query.log
--
DECLARE
 t_count       NUMBER;
 e_fatal_error EXCEPTION;
BEGIN
 SELECT
  COUNT(1)
 INTO
  t_count
 FROM
  user_tables
 WHERE
  table_name IN ('X#USER', 'X#ADDRESS', 'X#USER_ON_ADDRESS');
 --
 IF (t_count < 3) THEN
    dbms_output.put_line('ORA-20321: одна или несколько таблиц не созданы! Запустите скрипт /junior_tests/task1/install.sql');
    RAISE e_fatal_error;
 END IF;
END;
/
--
SPOOL OFF
--
SPOOL query.log
--
SELECT
 x2.fio
,x2.address
,x2.postal_code
,TO_CHAR(x2.begin_date, 'DD.MM.YYYY') begin_date
,TO_CHAR(x2.end_date, 'DD.MM.YYYY') end_date
FROM (
 SELECT
  x1.fio
 ,x1.address
 ,x1.postal_code
 ,x1.begin_date
 ,x1.end_date
 ,x1.rn
 FROM (
  SELECT
   REPLACE(u.c_fio, ',', ' ') fio
  ,CASE
    WHEN (c.c_end IS NULL) THEN
     REGEXP_REPLACE (a.c_address, '(,\d{6})($)', '') -- оставляем все, кроме индекса
    ELSE
     ''
    END address
  ,CASE
    WHEN (c.c_end IS NULL) THEN
     REGEXP_SUBSTR (a.c_address, '(\d{6})($)') -- оставляем только индекс
    ELSE
     ''
    END postal_code
  ,c.id user_on_address_id
  ,c.c_begin begin_date
  ,c.c_end end_date
  -- сортировка: сначала с максимальной датой прописки затем с макимальным идентификатором
  ,ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY c.c_begin DESC, c.id DESC) rn
  FROM
   x#user u
  LEFT JOIN x#user_on_address c
   ON c.c_user = u.id
  LEFT JOIN x#address a
   ON a.id = c.c_address
 ) x1
 WHERE
  x1.rn = 1
) x2
WHERE
 -- все граждане (одна строка с последними актуальными данными)
 :p_mode = 0
OR
-- действующий адрес
(:p_mode = 1
 AND x2.begin_date IS NOT NULL
 AND x2.end_date IS NULL)
OR
 -- нет действующего адреса
(:p_mode = -1
 AND (x2.begin_date IS NULL
    OR x2.end_date IS NOT NULL))
;

SPOOL OFF

EXIT

