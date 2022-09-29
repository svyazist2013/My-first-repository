/*Среди логинов сотрудников массовой профессии СОК (должность POSIT_POS из LPAR1.EMPLOYEE_DATA_RP принадлежит к REP_GROUP = '1' из LPAR1.EMPLOYEE_DATA_S1) найти тех,
 кто в прошлом году хоть один раз закрывал кредитную карту (rm.tcards продукты (gr) UNI или UN_M или GOLD или VIP,
dateEnd - дата закрытия договора) . В ответ вывести общее кол-во сотрудников. 
В анализ брать только тех сотрудников,
у которых месяц рождения (по дате REP_BDATE из LPAR1.EMPLOYEE_DATA_RP) совпадает с Вашим месяцем рождения (подразумевается только равенство номера месяца от 1 до 12 без анализа года, свою дату рождения вытянуть по лдапу).
Если решение будет с использованием временных таблиц, построить соответствующие индексы.*/
  SELECT REP_CLID AS 'CL_ID'
    INTO #L7_1
    FROM LPAR1.EMPLOYEE_DATA_RP AS T1
   INNER JOIN LPAR1.EMPLOYEE_DATA_S1 AS T2 ON T1.POSIT_POS = T2.POSIT_POS
   WHERE REP_GROUP = '1'
     AND month(T1.REP_BDATE) = (SELECT month(T3.REP_BDATE)
                                  FROM LPAR1.EMPLOYEE_DATA_RP AS T3
                                 WHERE LDAP_LOGIN = 'DD010183VVV'
                                )
  ;
 COMMIT;

 HG (HighGroup)
 CREATE HG index REP_CLID_HG on #L7_1 (CL_ID);


 SELECT COUNT(DISTINCT T1.CL_ID) AS 'COUNT_ID'
   FROM #L7_1 AS T1
   JOIN rm.tcards AS T2 ON T1.CL_ID = T2.CLIENTID
  WHERE T2.gr IN ('UNI', 'UN_M ','GOLD', 'VIP')
    AND year(T2.dateEnd) = (year(today())-1)
    ;
    COMMIT;


 SELECT T2.GR AS 'COUNT_GR'
      , COUNT() AS 'COUNT_ID'
   FROM #L7_1 AS T1
   JOIN rm.tcards AS T2 ON T1.CL_ID = T2.CLIENTID
  WHERE T2.gr IN ('UNI', 'UN_M ','GOLD', 'VIP')
    AND year(T2.dateEnd) = (year(today())-1)
    GROUP BY T2.GR
    ;
    COMMIT;