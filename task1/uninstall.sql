SPOOL uninstall.log

DROP SEQUENCE x#user_sq_id;
DROP SEQUENCE x#address_sq_id;
DROP SEQUENCE x#user_on_address_sq_id;

DROP TABLE x#user_on_address;
DROP TABLE x#address;
DROP TABLE x#user;

SPOOL OFF
