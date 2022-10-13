/*Написать запрос, который из таблицы rm.tcards выведет на экран все номера карт, и референсы договоров по Вашему clientid. 
Названия полей номера карты и рефа договора - pan и refcontract соответственно*/

SELECT pan,
       refcontract
  FROM rm.tcards
 WHERE clientid = '1111111'
commit;

/*Написать запрос, который из таблицы rm.tcards выведет на экран  по Вашему clientid номера карт, и референсы договоров по продуктам "Кредитная карта". 
Названия полей номера карты и рефа договора - pan и refcontract соответственно.
Отфильтровать продукт можно по полю "GR". 
К продукту кредитная карта относятся продукты UNI, UN_M, GOLD, VIP*/

SELECT pan,
       refcontract
  FROM rm.tcards
 WHERE clientid = '1111111'
       AND GR = ( 'UNI', 'UN_M', 'GOLD', 'VIP')
commit;

/*Написать запрос, который из таблицы rm.tcards выведет на экран  по Вашему clientid номера карт, и референсы договоров по продуктам "Кредитная карта", у которых установленный лимит > 0. 
       Названия полей номера карты и рефа договора - pan и refcontract соответственно. Отфильтровать продукт можно по полю "GR". 
       К продукту кредитная карта относятся продукты UNI, UN_M, GOLD, VIP.
       Установленный лимит можно проверить в поле "lim".*/

SELECT pan,
       refcontract
  FROM rm.tcards
 WHERE GR = ( 'UNI', 'UN_M', 'GOLD', 'VIP')
       AND lim > 0
commit;     


/*Написать запрос, который из таблицы LPAR1.EMPLOYEE_DATA_RP выведет на экран: 
 * лдап (LDAP_LOGIN), 
 * фамилию(PEOP_FAM), 
 * имя(PEOP_NAME), 
 * код должности(POSIT_POS), 
 * дату приема (DATE_PR)
сотрудников с датой приема 1-е марта 2022.
    Отсортировать результат по коду должности по возрастанию, затем по дате рождения(REP_BDATE) по убыванию.*/

SELECT LDAP_LOGIN,
       PEOP_FAM,
       PEOP_NAME,
       POSIT_POS,
       DATE_PR
  FROM LPAR1.EMPLOYEE_DATA_RP
 WHERE DATE_PR = '2022-02-01'
 ORDER BY POSIT_POS ASC 
 ORDER BY REP_BDATE DESC 
 commit;

/*Написать запрос, который из таблицы LPAR1.EMPLOYEE_DATA_RP выведет на экран: 
 * лдап (LDAP_LOGIN), 
 * фамилию(PEOP_FAM), 
 * имя(PEOP_NAME), 
 * код должности(POSIT_POS), 
 * дату приема (DATE_PR)
сотрудников с датой приема 1-е марта 2022.
    Вывести 3 самых молодых из них по дате рождения (REP_BDATE)*/

SELECT TOP 3
           LDAP_LOGIN,
           PEOP_FAM,
           PEOP_NAME,
           POSIT_POS,
           DATE_PR
  FROM LPAR1.EMPLOYEE_DATA_RP
 WHERE DATE_PR = '2022-02-01'
 ORDER BY REP_BDATE ASC
 commit;

--test 2 github









