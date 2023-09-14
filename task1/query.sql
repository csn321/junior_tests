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
SET LINESIZE 1000
SET FEED OFF
SET COLSEP '|'
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
-- Создать sql-запрос, выводящий для каждого гражданина ФИО, его действующий
-- адрес, почтовый индекс тремя отдельными колонками. Адрес является
-- действующим, если дата выписки не установлена, а дата прописки максимальная.
-- При наличии нескольких действующих адресов брать наиболее актуальный (с
-- максимальным id прописки).
-- Запрос сделать параметризуемым – в зависимости от значения p_mode:
-- p_mode = 1 организовать поиск граждан с действующим местом жительства
--            на текущий момент
-- p_mode = 0 вывести всех граждан (вне зависимости от того указан ли у них
--            действующий адрес)
-- p_mode = -1 организовать поиск граждан без определенного места
--            жительства
--
SELECT
 x1.fio
,x1.address
,x1.postal_code
,x1.begin_date
,x1.end_date
FROM
(
 SELECT
  u.fio
 ,a.address
 ,a.postal_code
 ,c.id user_on_address_id
 ,c.begin_date
 ,c.end_date
 --
 ,CASE
   WHEN (c.id IS NOT NULL AND c.end_date AND NULL) THEN 1 -- действующий адрес
   WHEN (c.id IS NULL) THEN -1 -- нет действующего адреса
   ELSE 0 -- недействующий адрес
  END is_mode
 --
 ,ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY c.begin_date DESC, c.id DESC) rn
 FROM
  x#user u
 LEFT JOIN x#user_on_address c
  ON c.c_user = u.id
 LEFT JOIN x#address a
  ON a.id = c.c_address
) x1
WHERE
 (:p_mode = 0 AND x1.rn = 1) -- все граждане
-- p_mode = 1 действующий адрес
-- p_mode = -1 нет действующего адрес
OR (:p_mode <> 0 AND x1.is_mode = :p_mode AND x1.rn = 1)
;

SPOOL OFF

EXIT

