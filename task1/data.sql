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
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 1000

SPOOL data.log
---------------------------------------
-- Заполнение таблиц тестовыми данными
---------------------------------------

DECLARE
 --
 -- заполнение таблицы x#user
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
     level < 7) fam
   ,(
    SELECT
     SUBSTR(t_name
           ,DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_name, ',', 1, level), 0, LENGTH(t_name) + 1, INSTR(t_name, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_name, ',', 1, level - 1) + 1)) first_name
    FROM
     dual
    CONNECT BY
     level < 5) name
   ,(
    SELECT
     SUBSTR(t_fat
           ,DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_fat, ',', 1, level), 0, LENGTH(t_fat) + 1, INSTR(t_fat, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_fat, ',', 1, level - 1) + 1)) second_name
    FROM
     dual
    CONNECT BY
     level < 5) fat
  ) LOOP
     INSERT INTO x#user (
      id
     ,c_fio
     ) VALUES (
      x#user_sq_id.nextval
     ,c.last_name || ',' || c.first_name || ',' || c.second_name
     );
  END LOOP;
 END set_fio;
 --
 --
 -- заполнение таблицы x#address
 --
 PROCEDURE set_address
 IS
 DECLARE
  t_place CONSTANT VARCHAR2(100) := 'Омск,Курган,Новосибирск,Тюмень';
  t_street CONSTANT VARCHAR2(100) := 'Пушкина,Карла Маркса,Лермонтова,Мира,Ленина';
  t_house CONSTANT VARCHAR2(100) := '1,2,15,8,33,142,11,56,72';
  t_flat INTEGER;
 BEGIN
  FOR c IN (
   SELECT
    p.place
   ,s.street
   ,h.house
   ,TRIM(TO_CHAR(p.postal_code, '09')) || TRIM(TO_CHAR(s.postal_code, '09')) || TRIM(TO_CHAR(h.postal_code, '09')) postal_code
   FROM (
    SELECT
     SUBSTR(t_place
           ,DECODE(level, 1, 1, INSTR(t_place, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_place, ',', 1, level), 0, LENGTH(t_place) + 1, INSTR(t_place, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_place, ',', 1, level - 1) + 1)) place
    ,60+level postal_code
    FROM
     dual
    CONNECT BY
     level < 5) p
   ,(
    SELECT
     SUBSTR(t_street
           ,DECODE(level, 1, 1, INSTR(t_street, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_street, ',', 1, level), 0, LENGTH(t_street) + 1, INSTR(t_street, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_street, ',', 1, level - 1) + 1)) street
    ,20+level postal_code
    FROM
     dual
    CONNECT BY
     level < 5) s
   ,(
    SELECT
     SUBSTR(t_house
           ,DECODE(level, 1, 1, INSTR(t_house, ',', 1, level - 1) + 1)
           ,DECODE(INSTR(t_house, ',', 1, level), 0, LENGTH(t_house) + 1, INSTR(t_house, ',', 1, level))
            - DECODE(level, 1, 1, INSTR(t_house, ',', 1, level - 1) + 1)) house
    ,10+level postal_code
    FROM
     dual
    CONNECT BY
     level < 5) h
  ) LOOP
     FOR t_flat IN 1..30
     LOOP
        INSERT INTO x#address (
         id
        ,c_address
        ) VALUES (
         x#address_sq_id.nextval
        ,'г.'c.place || ',ул.' || c.street || ',' || c.house || ',' || TRIM(TO_CHAR(t_flat, '99')) || ',' || c.postal_code
        );
     END LOOP;
  END LOOP;
 END set_address;
 --
 --
 -- заполнение таблицы x#user_on_adress
 --
 PROCEDURE set_user_on_address
 IS
 BEGIN
  FOR c IN (
   SELECT
    u1.id
   ,u1.c_fio
   ,u1.max_id
   ,a1.id a1_id
   ,DECODE(a1.id, NULL, NULL, TO_DATE('01.01.2010', 'DD.MM.YYYY') + a1.id) begin1
   ,DECODE(a2.id, NULL, NULL, TO_DATE('01.01.2010', 'DD.MM.YYYY') + a2.id) end1
   ,a2.id a2_id
   ,DECODE(a2.id, NULL, NULL, TO_DATE('01.01.2010', 'DD.MM.YYYY') + a2.id + 5) begin2
   FROM (
    SELECT
     u.id
    ,u.c_fio
    ,MAX(u.id) OVER() max_id
    FROM
     x#user u
   ) u1
   LEFT OUTER JOIN x#address a1 ON (a1.id = u1.id)
   LEFT OUTER JOIN x#address a2 ON (a2.id = u1.id + u1.max_id)
  ) LOOP
    -- предположим - граждане с id 50, 75 и 99 - бомжи
    IF (c.a1_id IS NOT NULL AND c.id NOT IN (50, 75, 99)) THEN
       INSERT INTO x#user_on_adress (
        id
       ,c_user
       ,c_address
       ,c_begin
       ,c_end
       ) VALUES (
        x#user_on_adress_sq_id.nextval
       ,c.id
       ,c.a1_id
       ,c.begin1
       ,c.end1
       );
    END IF;
    --
    IF (c.a2_id IS NOT NULL AND c.id NOT IN (50, 75, 99)) THEN
       INSERT INTO x#user_on_adress (
        id
       ,c_user
       ,c_address
       ,c_begin
       ) VALUES (
        x#user_on_adress_sq_id.nextval
       ,c.id
       ,c.a2_id
       ,c.begin2
       );
    END IF;
    --
  END LOOP;
 END set_user_on_address;
 --
BEGIN
 --
 set_fio;
 set_address;
 set_user_on_address;
 --
END;
/

COMMIT;

SPOOL OFF
