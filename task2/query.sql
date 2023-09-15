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
<<<<<<< HEAD
SET FEED OFF
SET HEADING OFF
SET PAGESIZE 10000
SET LINESIZE 1

=======
SET LINESIZE 1000
SET PAGESIZE 0 EMBEDDED ON
>>>>>>> 96b7b068dcb855e33e46465cdc27491dfa593653
--
SPOOL query.log
--
SELECT
 -- определяем ASCI-код буквы 'a', на каждом уровне вычисляем следующий символ
 TRIM((CHR(ASCII('a') + LEVEL - 1))) letters
FROM
 dual
CONNECT BY
 LEVEL <= 26 -- количество букв
;

SPOOL OFF

EXIT

