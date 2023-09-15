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
-- Импорт в схему синхронизации договоров в режиме "онлайн"
DECLARE
 --
 g_regexp      CONSTANT VARCHAR2(20) := '[^,]+';
 g_delimiter   CONSTANT VARCHAR2(1) := ',';
 -- заполнение таблицы x#user
 --
 PROCEDURE set_fio
 IS
  t_last_name   CONSTANT VARCHAR2(50) := 'Иванов,Петров,Федоров,Зайцев,Семенов,Волков';
  t_first_name  CONSTANT VARCHAR2(50) := 'Иван,Петр,Федор,Семен';
  t_second_name CONSTANT VARCHAR2(50) := 'Иванович,Петрович,Федорович,Семенович';
 BEGIN
  -- выбираем все возможные сочетания фамилии, имени и отчества
  INSERT INTO x#user (
   id
  ,c_fio
  )
  SELECT
   x#user_sq_id.nextval id
  ,x1.last_name || g_delimiter || x2.first_name || g_delimiter || x3.second_name c_fio
  FROM (
   SELECT
    REGEXP_SUBSTR(t_last_name, g_regexp, 1, LEVEL) last_name
   FROM
    dual
   CONNECT BY
    LEVEL <= REGEXP_COUNT(t_last_name, g_delimiter) + 1
   ) x1
  ,(SELECT
     REGEXP_SUBSTR(t_first_name, g_regexp, 1, LEVEL) first_name
    FROM
     dual
    CONNECT BY
     LEVEL <= REGEXP_COUNT(t_first_name, g_delimiter) + 1
   ) x2
   ,(SELECT
     REGEXP_SUBSTR(t_second_name, g_regexp, 1, LEVEL) second_name
    FROM
     dual
    CONNECT BY
     LEVEL <= REGEXP_COUNT(t_second_name, g_delimiter) + 1
   ) x3;
 EXCEPTION
  WHEN OTHERS THEN
   dbms_output.put_line('Ошибка при заполнении таблицы x#user: '||SUBSTR (SQLERRM, 1, 2000));
   RAISE;
 END set_fio;
 --
 --
 -- заполнение таблицы x#address
 --
 PROCEDURE set_address
 IS
  t_place       CONSTANT VARCHAR2(50) := 'Омск,Курган,Новосибирск,Тюмень';
  t_street      CONSTANT VARCHAR2(50) := 'Пушкина,Карла Маркса,Лермонтова,Мира,Ленина';
  t_house       CONSTANT VARCHAR2(50) := '1,2,15,8,33,142,11,56,72';
  t_flats_count CONSTANT NUMBER := 30;
 BEGIN
  -- выбираем все возможные сочетания населенного пункта, улицы и дома
  -- предполагаем, что в каждом доме 30 квартир
  -- предполагаем, что почтовый индекс уникален для каждого дома
  INSERT INTO x#address (
   id
  ,c_address
  )
  SELECT
   x#address_sq_id.nextval id
  ,'г.' || p.place || ',ул.' || s.street || g_delimiter || h.house || g_delimiter || TRIM(TO_CHAR(f.flat, '99'))
    || g_delimiter || TRIM(TO_CHAR(p.postal_code, '09')) || TRIM(TO_CHAR(s.postal_code, '09'))
    || TRIM(TO_CHAR(h.postal_code, '09')) c_address
  FROM (
   SELECT
    REGEXP_SUBSTR (t_place, g_regexp, 1, LEVEL) place
   ,60 + LEVEL postal_code
   FROM
    dual
   CONNECT BY
    LEVEL <= REGEXP_COUNT(t_place, g_delimiter) + 1
   ) p
  ,(
   SELECT
    REGEXP_SUBSTR (t_street, g_regexp, 1, LEVEL) street
   ,20 + LEVEL postal_code
   FROM
    dual
   CONNECT BY
    LEVEL <= REGEXP_COUNT(t_street, g_delimiter) + 1
   ) s
  ,(
   SELECT
    REGEXP_SUBSTR (t_house, g_regexp, 1, LEVEL) house
   ,10 + LEVEL postal_code
   FROM
    dual
   CONNECT BY
    LEVEL <= REGEXP_COUNT(t_house, g_delimiter) + 1) h
  ,(
   SELECT
    LEVEL flat
   FROM
    dual
   CONNECT BY
    LEVEL < t_flats_count) f
 EXCEPTION
  WHEN OTHERS THEN
   dbms_output.put_line('Ошибка при заполнении таблицы x#address: '||SUBSTR (SQLERRM, 1, 2000));
   RAISE;
 END set_address;
 --
 --
 -- заполнение таблицы x#user_on_adress
 --
 PROCEDURE set_user_on_address
 IS
 BEGIN
  INSERT INTO x#user_on_address (
   id
  ,c_user
  ,c_address
  ,c_begin
  ,c_end
  )
  SELECT
   x#user_on_address_sq_id.nextval
  ,x1.id user_id
  ,DECODE(t1.type, 1, x1.a1_id, x1.a2_id) address
  ,DECODE(t1.type, 1, x1.begin1, x1.begin2) begin1
  ,DECODE(t1.type, 1, x1.end1, TO_DATE(NULL)) end1
  FROM (
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
   LEFT OUTER JOIN x#address a1
    ON (a1.id = u1.id)
   LEFT OUTER JOIN x#address a2
    ON (a2.id = u1.id + u1.max_id) --AND u1.id NOT IN (15, 77)
   WHERE
    u1.id NOT IN (50, 75, 99) -- предположим - граждане с id 50, 75 и 99 - бомжи
  ) x1
  ,(SELECT 1 type FROM DUAL
    UNION ALL
    SELECT 2 type FROM DUAL
   ) t1
   WHERE
    t1.type = 1 OR x1.id NOT IN (15, 77) -- граждане с id 15 и 77 выписались, но не прописались
   ;
 EXCEPTION
  WHEN OTHERS THEN
   dbms_output.put_line('Ошибка при заполнении таблицы x#user_on_address: '||SUBSTR (SQLERRM, 1, 2000));
   RAISE;
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

EXIT
