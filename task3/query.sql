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
SET COLSEP ' | '
--
SPOOL query3.log
--
-- Задание 3
-- Создать sql-запрос, который преобразует строку, состоящую из пар
-- «ключ:значение», разделенных символом «#», в таблицу с двумя колонками
-- &quot;Ключ&quot; и &quot;Значение&quot;, отсортировать по полю &quot;Значение&quot; по убыванию.
-- Пример строки:
-- Аналитик:1#Разработчик:12#Тестировщик:10#Менеджер:3
--
WITH row_date AS  (
  SELECT
   'Аналитик:1#Разработчик:12#Тестировщик:10#Менеджер:3' str
  FROM
   DUAL
)
SELECT
 x1.key
,x1.value
FROM
(
 SELECT
  REGEXP_SUBSTR(REGEXP_SUBSTR (str,'([^#]+)', 1, LEVEL), '[^:]+', 1, 1) key
 ,REGEXP_SUBSTR(REGEXP_SUBSTR (str,'([^#]+)', 1, LEVEL), '[^:]+', 1, 2) value
 FROM
  row_date
 CONNECT BY
  LEVEL <= REGEXP_COUNT(str, '#')+1 -- количество символов '#' + 1
) x1
ORDER BY
 x1.key DESC
;

SPOOL OFF

EXIT

