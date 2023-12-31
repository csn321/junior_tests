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
SET SERVEROUTPUT ON
--
COLUMN fio HEADING "ФИО" FORMAT a40
COLUMN address HEADING "Адрес" FORMAT a40
COLUMN postal_code HEADING "Почтовый индекс" FORMAT a16
COLUMN begin_date HEADING "Дата прописки" FORMAT a14
COLUMN end_date HEADING "Дата выписки" FORMAT a14
COLUMN error_text HEADING "" FORMAT a120
--
VARIABLE p_mode NUMBER;
--
ACCEPT p_mode_accept NUMBER FORMAT 'FM9' DEFAULT '0' PROMPT 'Введите режим выполнения запроса [-1, 0, 1]: '
--
SPOOL query.log
--
DECLARE
 t_count       NUMBER;
 e_fatal_error EXCEPTION;
BEGIN
 SELECT &p_mode_accept INTO :p_mode FROM dual;
 --
 IF (:p_mode NOT IN (0, 1, -1)) THEN
    dbms_output.put_line('ORA-20321: Неверный режим выполнения запроса!');
    RAISE e_fatal_error;
 END IF;
 --
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
 ,CASE
   WHEN (x1.end_date IS NULL) THEN
    REGEXP_REPLACE (x1.address, '(,\d{6})($)', '') -- оставляем все, кроме индекса
   ELSE
    NULL
   END address
 ,CASE
   WHEN (x1.end_date IS NULL) THEN
    REGEXP_SUBSTR (x1.address, '(\d{6})($)') -- оставляем только индекс
   ELSE
    NULL
   END postal_code
 ,x1.begin_date
 ,x1.end_date
 ,x1.rn
 FROM (
  SELECT
   REPLACE(u.c_fio, ',', ' ') fio
  ,a.c_address address
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
 AND x2.address IS NOT NULL)
OR
 -- нет действующего адреса
(:p_mode = -1
 AND x2.address IS NULL)
;

SPOOL OFF

EXIT
