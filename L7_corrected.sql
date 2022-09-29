/*Выбрать LDAP_LOGIN (из таблицы LPAR1.EMPLOYEE_DATA_RP)
 самого старшего из работающих(peop_state = '0')
 сотрудника Северо-Западного РУ (*** ECA_BRNM2 = 'VFH0' в таблице LPAR1.BRNM_DATA_RP).
Связка по полю ECA_BRNM.*/

SELECT TOP 1 LDAP_LOGIN AS 'OLDER_LDAP'
          ,  REP_BDATE  AS 'WAS_BORN'
  FROM LPAR1.EMPLOYEE_DATA_RP AS T1
 WHERE T1.ECA_BRNM IN ( SELECT T2.ECA_BRNM 
						  FROM LPAR1.BRNM_DATA_RP AS T2
						 WHERE T2.ECA_BRNM2 = 'VFH0'
					  )
   AND T1.peop_state = '0'
   ORDER BY REP_BDATE
COMMIT;



//////

SELECT TOP 1 LDAP_LOGIN AS 'OLDER_LDAP'
           , REP_BDATE  AS 'WAS_BORN'
  FROM LPAR1.EMPLOYEE_DATA_RP AS T1
 INNER JOIN LPAR1.BRNM_DATA_RP AS T2 ON T1.ECA_BRNM = T2.ECA_BRNM
 WHERE T1.peop_state = '0'
   AND T2.ECA_BRNM2 = 'VFH0'
 ORDER BY REP_BDATE
COMMIT; 
//

/*Определить кол-во сотрудников в банке PB (поле BBN_BNMN),
 которые не привязаны ни к одной массовой профессии,
которые приняты на работу в один день с Вами или после Вас.
(наличие сотрудника в массовой профессии = наличию кода должности сотрудника (POSIT_POS)
 в справочнике массовых профессий LPAR1.EMPLOYEE_DATA_S1). */

      SELECT COUNT(LDAP_LOGIN) AS 'NOT_MAS_STAFF'
        FROM LPAR1.EMPLOYEE_DATA_RP AS T1
   LEFT JOIN LPAR1.EMPLOYEE_DATA_S1 AS T2 ON T1.POSIT_POS = T2.POSIT_POS
       WHERE T2.POSIT_POS IS NULL
         AND T1.DATE_PR >= (SELECT DATE_PR
                              FROM LPAR1.EMPLOYEE_DATA_RP  AS T3
                             WHERE LDAP_LOGIN ='DD010183VVV'
                            )
         AND T1.PEOP_STATE = '0'
         AND T1.BBN_BNMN = 'PB'
      COMMIT;