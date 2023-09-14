SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET LINESIZE 1000 TRIMOUT ON TRIMSPOOL ON
SET TERMOUT OFF FEEDBACK OFF

SET VERIFY OFF

SPOOL indexes.log

---------------------------------------------------------------
-- Индексы
---------------------------------------------------------------
PROMPT -- CREATE INDEX i_x#user_on_address_c_user
CREATE INDEX i_x#user_on_address_c_user
 ON x#user_on_address (c_user);

PROMPT -- CREATE INDEX i_x#user_on_address_c_address
CREATE INDEX i_x#user_on_address_c_address
 ON x#user_on_address (c_address);

SPOOL OFF
