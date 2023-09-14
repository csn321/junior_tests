SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 1000 TRIMOUT ON TRIMSPOOL ON
SET TERMOUT OFF FEEDBACK OFF

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
                          CONSTRAINT pk_x#user_id                    PRIMARY KEY
                          CONSTRAINT nn_x#user_id                    NOT NULL
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
                          CONSTRAINT pk_x#address_id                 PRIMARY KEY
                          CONSTRAINT nn_x#address_id                 NOT NULL
  -- Адрес
 ,c_address       VARCHAR2(4000)
);

COMMENT ON TABLE  x#address       IS 'Адреса';
COMMENT ON COLUMN x#address.id    IS 'Идентификатор адреса';
COMMENT ON COLUMN x#address.c_fio IS 'Адрес';

---------------------------------------------------------------
-- Прописки
---------------------------------------------------------------
PROMPT -- CREATE TABLE x#user_on_address
CREATE TABLE x#user_on_address
(
  -- Идентификатор прописки
  id              NUMBER
                          CONSTRAINT pk_x#user_on_address_id         PRIMARY KEY
                          CONSTRAINT nn_x#user_on_address_id         NOT NULL
  -- Идентификатор гражданина
 ,c_user          NUMBER
                          CONSTRAINT nn_x#user_on_address_c_user     NOT NULL
                          CONSTRAINT fk_x#user_on_address_c_user
                           REFERENCES x#user(id)
  -- Идентификатор адреса
 ,c_address       NUMBER
                          CONSTRAINT nn_x#user_on_address_c_address  NOT NULL
                          CONSTRAINT fk_x#user_on_address_c_address
                           REFERENCES x#address(id)
  -- Дата прописки
 ,c_begin         DATE
                          CONSTRAINT nn_x#user_on_address_c_begin    NOT NULL
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

