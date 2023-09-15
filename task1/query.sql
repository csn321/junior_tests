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
SET LINESIZE 200
SET MARKUP HTML PREFORMAT ON
SET PAGESIZE 0 EMBEDDED ON
SET COLSEP ' | '
--
COLUMN fio HEADING "ФИО" FORMAT a50
COLUMN address HEADING "Адрес" FORMAT a50
COLUMN postal_code HEADING "Почтовый индекс" FORMAT a16
COLUMN begin_date HEADING "Дата прописки" FORMAT a14
COLUMN end_date HEADING "Дата выписки" FORMAT a14
COLUMN error_text HEADING "Тескт ошибки" FORMAT a120
--
SPOOL query.log
--
ACCEPT p_mode_str DEFAULT '0' PROMPT 'Введите режим выполнения запроса [-1, 0, 1]: '
--
VARIABLE p_mode NUMBER;
VARIABLE p_msg_text VARCHAR2(2000);
BEGIN
 SELECT DECODE('&&p_mode_str', '0', 0, '1', 1, '-1', -1, 0) INTO :p_mode FROM dual;
END;
/
--
DECLARE
 t_count       NUMBER;
 e_fatal_error EXCEPTION;
 g_msg_text    VARCHAR2(2000) := NULL;
BEGIN
 SELECT COUNT(1) INTO t_count FROM user_tables WHERE table_name = 'C#USER';
 IF (t_count = 0) THEN
    g_msg_text := 'ORA-20321: таблица c_objects не создана! Запустите скрипт /gitlab321/cft/junior_tests/task1/install.sql';
    :p_msg_text := g_msg_text;
    RAISE e_fatal_error;
 END IF;
EXCEPTION
 WHEN e_fatal_error THEN
  NULL;
 WHEN OTHERS THEN
  g_msg_text := SQLERRM;
END;
/
--
SELECT :p_msg_text error_text FROM DUAL;
--
SELECT
 x1.fio
,x1.address
,x1.postal_code
,TO_CHAR(x1.begin_date, 'DD.MM.YYYY') begin_date
,TO_CHAR(x1.end_date, 'DD.MM.YYYY') end_date
FROM
(
 SELECT
  REPLACE(u.c_fio, ',', ' ') fio
 ,REGEXP_REPLACE (a.c_address, '(,\d{6})($)', '') address -- оставляем все, кроме индекса
 ,REGEXP_SUBSTR (a.c_address, '(\d{6})($)') postal_code -- оставляем только индекс
 ,c.id user_on_address_id
 ,c.c_begin begin_date
 ,c.c_end end_date
 --
 ,CASE
   -- есть запись в таблице прописок с неустановленной датой выписки
   WHEN (c.id IS NOT NULL AND c.c_end IS NULL) THEN 1 -- действующий адрес
   -- нет записи в таблице прописок
   WHEN (c.id IS NULL) THEN -1 -- нет действующего адреса
   ELSE 0 -- недействующий адрес
  END is_mode
 --
 -- сортировка: сначала с максимальной датой прописки, с макимальным идентификатором
 ,ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY c.c_begin DESC, c.id DESC) rn
 FROM
  x#user u
 LEFT JOIN x#user_on_address c
  ON c.c_user = u.id
 LEFT JOIN x#address a
  ON a.id = c.c_address
) x1
WHERE
-- все граждане (одна строка с последними актуальными данными)
 (:p_mode = 0 AND x1.rn = 1)
-- p_mode = 1 действующий адрес
-- p_mode = -1 нет действующего адрес
OR (:p_mode <> 0 AND x1.is_mode = :p_mode AND x1.rn = 1)
;

SPOOL OFF

EXIT

