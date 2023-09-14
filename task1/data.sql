SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 1000

SPOOL data.log

DECLARE
 --
 PROCEDURE set_fio
 IS
 DECLARE
  t_fam CONSTANT VARCHAR2(100) := 'Иванов,Петров,Федоров,Зайцев,Семенов,Волков';
  t_name CONSTANT VARCHAR2(100) := 'Иван,Петр,Федор,Семен';
  t_fat CONSTANT VARCHAR2(100) := 'Иванович,Петрович,Федорович,Семенович';
 BEGIN
  FOR c IN (
   SELECT
    fam.last_name
   ,name.first_name
   ,fat.second_name
   FROM (
    SELECT
     SUBSTR(t_fam
           ,DECODE(level, 1, 1, INSTR(t_fam, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_fam, ',', 1, level), 0, LENGTH(t_fam) + 1, INSTR(t_fam, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_fam, ',', 1, level - 1) + 1)) last_name
    FROM
     dual
    CONNECT BY
     LEVEL < 7) fam
   ,(
    SELECT
     SUBSTR(t_name
           ,DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_name, ',', 1, level), 0, LENGTH(t_name) + 1, INSTR(t_name, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)) first_name
    FROM
     dual
    CONNECT BY
     LEVEL < 5) name
   ,(
    SELECT
     SUBSTR(t_fat
           ,DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_fat, ',', 1, level), 0, LENGTH(t_fat) + 1, INSTR(t_fat, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)) second_name
    FROM
     dual
    CONNECT BY
     LEVEL < 5) fat
  ) LOOP
     INSERT INTO x#user (
      id
     ,c_fio
     ) VALUES (
      x#user_sq.nextval
     ,c.last_name || ',' || c.first_name || ',' || c.second_name
     );
  END LOOP;
 END set_fio;
 --
 --
 --
 PROCEDURE set_address
 IS
 DECLARE
  t_place CONSTANT VARCHAR2(100) := 'Омск,Курган,Новосибирск,Тюмень';
  t_street CONSTANT VARCHAR2(100) := 'Пушкина,Карла Маркса,Лермонтова,Мира,Ленина';
  t_house CONSTANT VARCHAR2(100) := '1,2,15,8,33,142,11,56,72';
 BEGIN
  FOR c IN (
   SELECT
    p.place
   ,s.street
   ,h.house
   ,TO_CHAR(p.index, '99') || TO_CHAR(s.index, '99') || TO_CHAR(h.index, '99') index
   FROM (
    SELECT
     SUBSTR(t_place
           ,DECODE(level, 1, 1, INSTR(t_place, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_place, ',', 1, level), 0, LENGTH(t_place) + 1, INSTR(t_place, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_place, ',', 1, level - 1) + 1)) place
    ,60+level index
    FROM
     dual
    CONNECT BY
     LEVEL < 5) p
   ,(
    SELECT
     SUBSTR(t_street
           ,DECODE(level, 1, 1, INSTR(t_street, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_street, ',', 1, level), 0, LENGTH(t_street) + 1, INSTR(t_street, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_street, ',', 1, level - 1) + 1)) street
    ,20+level index
    FROM
     dual
    CONNECT BY
     LEVEL < 5) s
   ,(
    SELECT
     SUBSTR(t_house
           ,DECODE(level, 1, 1, INSTR(t_house, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_house, ',', 1, level), 0, LENGTH(t_house) + 1, INSTR(t_house, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_house, ',', 1, level - 1) + 1)) house
    ,10+level index
    FROM
     dual
    CONNECT BY
     LEVEL < 5) h
  ) LOOP
     INSERT INTO x#address (
      id
     ,c_address
     ) VALUES (
      x#address_sq.nextval
     ,'г.'c.place || ',ул.' || c.street || ',' || c.house || ',' || c.index
     );
  END LOOP;
 END set_address;
 --
BEGIN
 --
 set_fio;
 --
END;
/

COMMIT;

SPOOL OFF
