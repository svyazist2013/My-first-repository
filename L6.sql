/*Какое кол-во людей в банке PB устроились на работу(DATE_PR) в один день или после сотрудника DN210893ERV 
в том же подразделении(Департамент LDA_LDAP_LOGIN )
таблица (LPAR1.EMPLOYEE_DATA_RP).
В решении задачи использовать вложенный подзапрос в join. Таблица сотрудников LPAR1.EMPLOYEE_DATA_RP,*/

      SELECT COUNT() AS 'COUNT >= DN210893ERV'
        FROM LPAR1.EMPLOYEE_DATA_RP AS t1
  INNER JOIN (SELECT t2.LDA_LDAP_LOGIN
                   , t2.DATE_PR
                FROM LPAR1.EMPLOYEE_DATA_RP as t2
               WHERE t2.LDAP_LOGIN  = 'DN210893ERV'
              )
                AS t2 ON t1.LDA_LDAP_LOGIN = t2.LDA_LDAP_LOGIN 
                AND t1.DATE_PR >= t2.DATE_PR
COMMIT;



--вариант 1
select count(t1.ldap_login), count()
from LPAR1.EMPLOYEE_DATA_RP as t1 
where t1.LDA_LDAP_LOGIN = 	(
								select a.LDA_LDAP_LOGIN 
								from LPAR1.EMPLOYEE_DATA_RP as a
								where a.ldap_login = 'DN210893ERV'
							)
		and t1.date_pr >= 	(
								select aa.date_pr 
								from LPAR1.EMPLOYEE_DATA_RP as aa
								where aa.ldap_login = 'DN210893ERV'
							)
;
		

select LDA_LDAP_LOGIN, aa.date_pr 
from LPAR1.EMPLOYEE_DATA_RP as aa
where aa.ldap_login = 'DN210893ERV'

--2
select count(t1.ldap_login), count()
from LPAR1.EMPLOYEE_DATA_RP as t1 
join 	(
			select 	a.LDA_LDAP_LOGIN, 
					a.date_pr 
			from LPAR1.EMPLOYEE_DATA_RP as a
			where a.ldap_login = 'DN210893ERV'
		) as t2 on t1.LDA_LDAP_LOGIN = t2.LDA_LDAP_LOGIN
					and t1.date_pr >= t2.date_pr
;

--3 

/*create table  #need_date_lda_login (
 .......
)

insert into #need_date_lda_login
select 	a.LDA_LDAP_LOGIN, 
		a.date_pr 

from LPAR1.EMPLOYEE_DATA_RP as a
where a.ldap_login = 'DN210893ERV' 
;
commit;*/

select 	a.LDA_LDAP_LOGIN, 
		a.date_pr 
into #need_date_lda_login
from LPAR1.EMPLOYEE_DATA_RP as a
where a.ldap_login = 'DN210893ERV' 
;
commit;


select count(t1.ldap_login), count()
from LPAR1.EMPLOYEE_DATA_RP as t1 
join #need_date_lda_login as t2 on t1.LDA_LDAP_LOGIN = t2.LDA_LDAP_LOGIN
								and t1.date_pr >= t2.date_pr
;


/*Выбрать самого младшего сотрудника из таблицы LPAR1.EMPLOYEE_DATA_RP,
который принят на работу после любого из сотрудников Вашего департамента и
который отработал в прошлом месяце больше всех часов по табелю. 
Задачу решить при  помощи скалярного подзапроса с оператором ALL.
(WORK_H_FACT - отработанное время в прошлом месяце в часах)*/

SELECT t1.REP_CLID AS 'ид сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия'
     , t1.DATE_PR AS 'дата приема'
     , t1.LDA_LDAP_LOGIN AS 'где работает'
     , t1.DEPAR_NAME AS 'название подразделения'
     , t1.WORK_H_FACT AS 'отработанное время'
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 WHERE t1.DATE_PR < ALL(SELECT t2.DATE_PR --хотя по условию через ANY
                          FROM LPAR1.EMPLOYEE_DATA_RP AS t2    
                         WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
                           AND peop_state = '0'
                       )
   AND t1.WORK_H_FACT > ALL(SELECT t3.WORK_H_FACT
                          FROM LPAR1.EMPLOYEE_DATA_RP AS t3
/*v2 AND t1.WORK_H_FACT = (SELECT MAX (t3.WORK_H_FACT)
                           FROM LPAR1.EMPLOYEE_DATA_RP AS t3
                         )*/
   AND peop_state = '0'
COMMIT;


/*Посчитать кол-во сотрудников вашего департамента,
которые имеют карту универсальную (gr in ('UNI','UN_M','GOLD','VIP') )
с кредитным лимитом равным максимальному кредитному лимиту среди этих сотрудников.

например :
сотр1 - 1000 грн
сотр2 - 1000 грн
сотр3 - 700 грн
сотр4 - 900 грн

Результат 2 (т.к. макс лимит среди сотрудников - 1000 грн )
Табл сотрудников LPAR1.EMPLOYEE_DATA_RP, для решения можно использовать временные таблицы по желанию.*/

SELECT t1.clientid AS ID
     , MAX (t1.LIM) AS 'MAX_SUM_LIM'
  FROM rm.tcards AS t1
 INNER JOIN (SELECT t2.REP_CLID
               FROM LPAR1.EMPLOYEE_DATA_RP as t2
              WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
                AND peop_state = '0'
            )
                AS t2 ON t1.clientid = t2.REP_CLID 
 WHERE GR IN ('UNI', 'UN_M', 'GOLD', 'VIP')
 GROUP BY ID
COMMIT; 
