SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 1000 TRIMOUT ON TRIMSPOOL ON
SET TERMOUT OFF FEEDBACK OFF

SET VERIFY OFF

SPOOl sequences.log

----------------------------------------------------------------------------
--  Последовательность идентификаторов записей в таблице x#user
----------------------------------------------------------------------------
PROMPT CREATE SEQUENCE x#user_sq_id
CREATE SEQUENCE x#user_sq_id
 INCREMENT BY 1
 START WITH 1
 NOCACHE
 ORDER;

----------------------------------------------------------------------------
--  Последовательность идентификаторов записей в таблице x#address
----------------------------------------------------------------------------
PROMPT CREATE SEQUENCE x#address_sq_id
CREATE SEQUENCE x#address_sq_id
 INCREMENT BY 1
 START WITH 1
 NOCACHE
 ORDER;

----------------------------------------------------------------------------
--  Последовательность идентификаторов записей в таблице x#user_on_address
----------------------------------------------------------------------------
PROMPT CREATE SEQUENCE x#user_on_address_sq_id
CREATE SEQUENCE x#user_on_address_sq_id
 INCREMENT BY 1
 START WITH 1
 NOCACHE
 ORDER;

SPOOL OFF

