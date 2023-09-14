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
  t_place CONSTANT VARCHAR2(100) := 'Омск,Курган,Новосибирск,Тюмень';
 BEGIN
  FOR c IN (
   SELECT 
    fam.name
   ,name.name 
   ,fat.name
   FROM (
    SELECT
     SUBSTR(t_fam
           ,DECODE(level, 1, 1, INSTR(t_fam, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_fam, ',', 1, level), 0, LENGTH(t_fam) + 1, INSTR(t_fam, ',', 1, level)) 
            - DECODE(level, 1, 1, INSTR(t_fam, ',', 1, level - 1) + 1)) name
    FROM 
     dual
    CONNECT BY 
     LEVEL < 7) fam
   ,(
    SELECT
     SUBSTR(t_name
           ,DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_name, ',', 1, level), 0, LENGTH(t_name) + 1, INSTR(t_name, ',', 1, level)) 
            - DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)) name
    FROM 
     dual
    CONNECT BY 
     LEVEL < 5) name
   ,(
    SELECT
     SUBSTR(t_fat
           ,DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_fat, ',', 1, level), 0, LENGTH(t_fat) + 1, INSTR(t_fat, ',', 1, level)) 
            - DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)) name
    FROM 
     dual
    CONNECT BY 
     LEVEL < 5) fat
  ) LOOP
     INSERT INTO x#user (
      id
     ,c_fio
     ) VALUES (

     );
  END LOOP;
 END set_fio;
 --
BEGIN
 --
 set_fio; 
 --
END;
/

COMMIT;

SPOOL OFF
