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

--
SPOOL query.log
--
ACCEPT p_mode_str DEFAULT '0' PROMPT 'Введите режим выполнения запроса [-1, 0, 1]: '
--
VARIABLE p_mode NUMBER;
BEGIN
 SELECT DECODE('&&p_mode_str', '0', 0, '1', 1, '-1', -1, 0) INTO :p_mode FROM dual;
END;
/
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
  u.fio
 ,REGEXP_REPLACE (a.address, '(,\d{6})($)', '') address -- оставляем все, кроме индекса
 ,REGEXP_SUBSTR (a.address, '(\d{6})($)') postal_code -- оставляем только индекс
 ,c.id user_on_address_id
 ,c.begin_date
 ,c.end_date
 --
 ,CASE
   -- есть запись в таблице прописок с неустановленной датой выписки
   WHEN (c.id IS NOT NULL AND c.end_date AND NULL) THEN 1 -- действующий адрес
   -- нет записи в таблице прописок
   WHEN (c.id IS NULL) THEN -1 -- нет действующего адреса
   ELSE 0 -- недействующий адрес
  END is_mode
 --
 -- сортировка: сначала с максимальной датой прописки, с макимальным идентификатором
 ,ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY c.begin_date DESC, c.id DESC) rn
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

