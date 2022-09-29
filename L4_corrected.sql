/*"По таблице LPAR1.CLID_JUR_DATA_RP вывести на экран названия топ 100 (рандомно) юр. лиц (CLID_NAME_FORM) 
в названии которых есть выражение ""ВIЙСЬКОВА ЧАСТИНА"" или ""ВОИНСКАЯ ЧАСТЬ"", при этом в названии есть слово ""ОБ'ЄДНАННЯ"""*/

SELECT TOP 100
         CLID_NAME_FORM
  FROM LPAR1.CLID_JUR_DATA_RP
 WHERE (CLID_NAME_FORM LIKE '%ВIЙСЬКОВА ЧАСТИНА%' or CLID_NAME_FORM LIKE '%ВОИНСКАЯ ЧАСТЬ%') --error
   AND CLID_NAME_FORM LIKE '%ОБ''ЄДНАННЯ%'

commit;

/*"Попробуем найти примеры гос. организаций, которые относятся к угольной промышленности по офф. названию.
По таблице LPAR1.CLID_JUR_DATA_RP вывести на экран названия топ 100 (рандомно) юр. лиц (CLID_NAME_FORM) 
в названиях которых есть символы ""ВУГІЛ"" и ""ДЕРЖ"""*/

SELECT TOP 100
         CLID_NAME_FORM
  FROM LPAR1.CLID_JUR_DATA_RP
 WHERE CLID_NAME_FORM LIKE '%ВУГІЛ%' --error
   AND CLID_NAME_FORM LIKE '%ДЕРЖ%'
commit;

/*"из таблицы сотрудников LPAR1.EMPLOYEE_DATA_RP 
вывести кол-во сотрудников, в разрезе каждого имени PEOP_NAME.
При этом имена, которые встречаются менее 500 раз не выводить.
Учитывать только сотрудников в статусе (PEOP_STATE) ""работает"" ( '0')
Отсортировать от самого часто встречающегося имени"*/

SELECT PEOP_NAME 
     , COUNT(PEOP_NAME) as cPEOP_NAME
  FROM LPAR1.EMPLOYEE_DATA_RP
 WHERE PEOP_STATE = '0'
 GROUP BY PEOP_NAME
HAVING cPEOP_NAME > 500
 ORDER BY cPEOP_NAME desc
commit;-- есть сомнения и непонимание логики воспроизведения


/*"из таблицы сотрудников LPAR1.EMPLOYEE_DATA_RP 
Вывести на экран средний возраст (кол-во лет) декретчиц (PEOP_DEK = 1) и их кол-во в разрезе каждого названия должности(POSIT_NAME).
Разобраться как найти возраст, зная дату рождения(REP_BDATE). (ссылка на доп. материал справа)
Отсортировать по кол-ву сотрудников от большего, чтобы увидеть на какой должности больше всего декретчиц"*/

SELECT POSIT_NAME
     , AVG (datediff (yy, REP_BDATE, today()) as age
     , COUNT(POSIT_NAME) as cPOSIT_NAME
  FROM LPAR1.EMPLOYEE_DATA_RP
 WHERE PEOP_DEK = 1
 GROUP BY POSIT_NAME
 ORDER BY  cPOSIT_NAME desc
commit;

SELECT POSIT_NAME
     , cast(AVG (datediff (yy, REP_BDATE, today())) as numeric(13,2)) as age --приведение к типу данных с 2 знаками после запятой
     , COUNT(POSIT_NAME) as cPOSIT_NAME
  FROM LPAR1.EMPLOYEE_DATA_RP 
 WHERE PEOP_DEK = 1
 GROUP BY POSIT_NAME
 ORDER BY  cPOSIT_NAME desc



