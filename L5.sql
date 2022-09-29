/*Вывести данные в формате:
* ид сотрудника
* лдап
* имя
* фамилия
* сегмент риска (предрасчет карты)

Задание: по работающим(peop_state = '0') сотрудникам департамента 'ДЕПАРТАМЕНТ УПРАВЛЕНИЯ И МОДЕЛИРОВАНИЯ ПОРТФЕЛЬНЫХ РИСКОВ' (bus_bus = '49000004')
вывести данные в требуемом формате. 
Данные по сотрудникам брать из табл LPAR1.EMPLOYEE_DATA_RP
Группу риска можно взять из табл SERVICELIM.SRVLIM_ratingMatrix (поле matrixColor)
Подумать по каким полям связать таблицы*/

SELECT ид сотрудника
     , лдап
     , имя
     , фамилия
     , сегмент риска

SELECT TOP 3 *
  FROM LPAR1.EMPLOYEE_DATA_RP
 WHERE peop_state = '0'
   AND bus_bus = '49000004'
COMMIT;     

SELECT TOP 3 *
  FROM SERVICELIM.SRVLIM_ratingMatrix
COMMIT;

SELECT t1.REP_CLID AS 'ид сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия'
     , t2.matrixColor AS 'сегмент риска'
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 INNER JOIN SERVICELIM.SRVLIM_ratingMatrix AS t2 ON t1.REP_CLID = t2.clientid
 WHERE peop_state = '0'
   AND bus_bus = '49000004'
COMMIT; 



/*Из сотрудников департамента 'ДЕПАРТАМЕНТ УПРАВЛЕНИЯ И МОДЕЛИРОВАНИЯ ПОРТФЕЛЬНЫХ РИСКОВ' (bus_bus = '49000004')
выбрать тех, кто попадает в сегмент риска YELLOW (табл SERVICELIM.SRVLIM_ratingMatrix (поле matrixColor))
и при этом попадает в ЧС (таблица ЧС rm.tBlackList_online).
На экран вывести выборку таких сотрудников в формате:
*лдап
*имя
*фамилия
* код ЧС(CLKod)
* причину попадания в ЧС(BlackRemark)
* сегмент риска (matrixColor)*/

SELECT TOP 3 *
  FROM rm.tBlackList_online
COMMIT;

SELECT t1.REP_CLID AS 'ид сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия'
     , t2.matrixColor AS 'сегмент риска'
     , t3.CLKod AS 'код ЧС'
     , t3.BlackRemark AS 'причину попадания в ЧС'
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 INNER JOIN SERVICELIM.SRVLIM_ratingMatrix AS t2 ON t1.REP_CLID = t2.clientid
 INNER JOIN rm.tBlackList_online AS t3 ON t1.REP_CLID = t3.ClientID
 --WHERE peop_state = '0' - по активным не находит
   AND bus_bus = '49000004'
   AND matrixColor = 'YELLOW'
COMMIT; 


/*Из работающих(peop_state = '0') сотрудникам департамента 'ДЕПАРТАМЕНТ УПРАВЛЕНИЯ И МОДЕЛИРОВАНИЯ ПОРТФЕЛЬНЫХ РИСКОВ' (bus_bus = '49000004')
вывести данные только по тем, кто НЕ попадает в ЧС. 
На экран вывести выборку таких сотрудников в формате:
*лдап
*имя
*фамилия
* сегмент риска (matrixColor) 
Учесть что, сотрудника может не быть в матрице риска, в таком случае выводить по нему null

Данные по сотрудникам брать из табл LPAR1.EMPLOYEE_DATA_RP
Группу риска можно взять из табл SERVICELIM.SRVLIM_ratingMatrix (поле matrixColor)
таблица ЧС rm.tBlackList_online*/

SELECT t1.REP_CLID AS 'ид сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия'
     , t2.matrixColor AS 'сегмент риска'
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
  LEFT JOIN SERVICELIM.SRVLIM_ratingMatrix AS t2 ON t1.REP_CLID = t2.clientid
  LEFT JOIN rm.tBlackList_online AS t3 ON t3.ClientID IS NULL
 WHERE peop_state = '0'
   AND bus_bus = '49000004'
COMMIT; 
