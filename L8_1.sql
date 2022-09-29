/*Посчитать среднюю утилизацию лимитов на сейчас по продукту кредитная карта, по сотрудникам нашего департамента, которые были в статусе "работает" хотя бы один день в течение апреля 2022.
1) Департамент вытянуть по своему лдапу из LPAR1.EMPLOYEE_DATA_RP (поле bus_bus)
2) История статусов сотрудников по дням в табл LPAR1.EMPLOYEE_HIST_DATA_RP(статус работает peop_state = '0')
3) установленный лимит и сальдо брать из таблицы rm.tcards (поля bal, lim) 
4) по rm.tcards проверять данные только по открытым договорам (gr in ('UNI','UN_M', 'GOLD','VIP') and stateContract not in ('K','C','Z'))
5) учесть, что bal может быть null при lim > 0 , и наоборот. Считать null в этих полях как ноль.
6) результат вывести в % , с математическим округлением до сотых*/

SELECT DISTINCT (T2.REP_CLID) AS EMPLOYERS
  INTO #EMPLOYERS
  FROM LPAR1.EMPLOYEE_DATA_RP AS T2
 WHERE T2.bus_bus = (SELECT T3.bus_bus 
                       FROM LPAR1.EMPLOYEE_DATA_RP AS T3
                      WHERE T3.LDAP = 'DD010183VVV'
                    ) 
  JOIN LPAR1.EMPLOYEE_HIST_DATA_RP AS T4 ON T2.REP_CLID = T4.REP_CLID
 WHERE peop_state = '0'    
   AND year(DATE_ODB) = 2022
   AND month(DATE_ODB) = 4
   ;
   COMMIT;
  

   SELECT round (SUM (ISNULL (T1.bal, 0)) / SUM (ISNULL (T1.lim, 0))*100, 2) AS AVG_UTIL
     FROM rm.tcards AS T1
    WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
      AND stateContract not in ('K','C','Z')
      AND T1.CLIENT_ID IN (SELECT T2.REP_CLID
                             FROM #EMPLOYERS 
                          ) 
        ;
  COMMIT;                  
                    


/*По работающим на сейчас сотрудникам нашего департамента вывести данные в формате:
* лдап
* ид клиента
* ФИО (через пробел, брать из LPAR1.EMPLOYEE_DATA_RP)
* референс договора кредитной карты
* сумма пополнений кредитки в течение прошлых 2х месяцев

Вывести с сортировкой по сумме пополнений от большего к меньшему

1) Департамент вытянуть по своему лдапу из LPAR1.EMPLOYEE_DATA_RP (поле bus_bus)
2) референс договора брать из rm.tcards, проверять данные только по открытым договорам (gr in ('UNI','UN_M', 'GOLD','VIP') and stateContract not in ('K','C','Z')),
связка по ид клиента из LPAR1.EMPLOYEE_DATA_RP
3) сумму пополнений брать из segm.repUniversalSegment (поле sTranCROnLineAll),
 таблица историческая, помесячная, фильтровать по полю DT. Оно в формате yyyy-mm-01

Рекомендуется использование временных таблиц.*/


SELECT t1.REP_CLID AS 'ид_сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия' -- Склеить? Если да, через ||?
  INTO #EMPLOYERS
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 WHERE t1.bus_bus = (SELECT t2.bus_bus 
                       FROM LPAR1.EMPLOYEE_DATA_RP AS t2
                      WHERE t2.LDAP = 'DD010183VVV'
                    ) 
   AND t1.peop_state = '0'
;
COMMIT;

   SELECT t3.RefContract AS 'референс_договора'
        , t3.CLIENT_ID AS 'ид_сотрудника'
     INTO #EMPLOYERS_RefContract
     FROM rm.tcards AS t3
    WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
      AND stateContract not in ('K','C','Z')
      AND t3.CLIENT_ID IN (SELECT t4.REP_CLID
                             FROM #EMPLOYERS 
                          ) 
        ;
  COMMIT; 


SELECT SUM (ISNULL (t5.sTranCROnLineAll, 0)) AS 'сумма_пополнений'
     , t5.RefContract AS 'референс_договора'
     , t7.ид_сотрудника
  INTO #EMPLOYERS_RefContract_SUM
  FROM segm.repUniversalSegment AS t5
  JOIN #EMPLOYERS_RefContract AS t7 ON t7.референс_договора = t5.RefContract
 WHERE t5.RefContract IN (SELECT t6.RefContract
                            FROM #EMPLOYERS_RefContract AS t6
                          )
   AND year(DT) = 2022
   AND month(DT) IN (5, 4)
;
COMMIT;

SELECT t8.ид_сотрудника
     , t8.лдап
     , t8.имя
     , t8.фамилияAS 
     , t9.референс_договора 
     , t9.сумма_пополнений
  FROM #EMPLOYERS AS T8
  JOIN #EMPLOYERS_RefContract_SUM AS T9 ON T9.ид_сотрудника = t8.ид_сотрудника
  ;
COMMIT;
