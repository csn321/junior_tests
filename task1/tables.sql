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
SET VERIFY OFF

SPOOL tables.log

---------------------------------------------------------------
-- Граждане
---------------------------------------------------------------
PROMPT -- CREATE TABLE x#user
CREATE TABLE x#user
(
  -- Идентификатор гражданина
  id              NUMBER
                          CONSTRAINT pk_x#user_id PRIMARY KEY
  -- ФИО гражданина
 ,c_fio           VARCHAR2(100)
);

COMMENT ON TABLE  x#user       IS 'Граждане';
COMMENT ON COLUMN x#user.id    IS 'Идентификатор гражданина';
COMMENT ON COLUMN x#user.c_fio IS 'ФИО гражданина';

---------------------------------------------------------------
-- Адреса
---------------------------------------------------------------
PROMPT -- CREATE TABLE x#address
CREATE TABLE x#address
(
  -- Идентификатор адреса
  id              NUMBER
                          CONSTRAINT pk_x#address_id PRIMARY KEY
  -- Адрес
 ,c_address       VARCHAR2(4000)
);

COMMENT ON TABLE  x#address           IS 'Адреса';
COMMENT ON COLUMN x#address.id        IS 'Идентификатор адреса';
COMMENT ON COLUMN x#address.c_address IS 'Адрес';

---------------------------------------------------------------
-- Прописки
---------------------------------------------------------------
PROMPT -- CREATE TABLE x#user_on_address
CREATE TABLE x#user_on_address
(
  -- Идентификатор прописки
  id              NUMBER
                          CONSTRAINT pk_x#user_on_address_id PRIMARY KEY
  -- Идентификатор гражданина
 ,c_user          NUMBER
                          CONSTRAINT nn_x#user_on_address_c_user NOT NULL
                          CONSTRAINT fk_x#user_on_address_c_user
                           REFERENCES x#user(id)
  -- Идентификатор адреса
 ,c_address       NUMBER
                          CONSTRAINT nn_x#user_on_address_c_address NOT NULL
                          CONSTRAINT fk_x#user_on_address_c_address
                           REFERENCES x#address(id)
  -- Дата прописки
 ,c_begin         DATE
                          CONSTRAINT nn_x#user_on_address_c_begin NOT NULL
  -- Дата выписки
 ,c_end           DATE
);

COMMENT ON TABLE  x#user_on_address           IS 'Прописки';
COMMENT ON COLUMN x#user_on_address.id        IS 'Идентификатор прописки';
COMMENT ON COLUMN x#user_on_address.c_user    IS 'Идентификатор гражданина';
COMMENT ON COLUMN x#user_on_address.c_address IS 'Идентификатор адреса';
COMMENT ON COLUMN x#user_on_address.c_begin   IS 'Дата прописки';
COMMENT ON COLUMN x#user_on_address.c_end     IS 'Дата выписки';

SPOOL OFF

