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

/*
5. Выбрать самого младшего сотрудника из таблицы BUS_GENERAL.EMPLOYEE_DATA_RP, 
который принят на работу после любого из сотрудников Вашего департамента 
и который отработал в прошлом месяце больше всех часов по табелю. Задачу решить при  помощи скалярного подзапроса с оператором ALL. 



*/

--variant 1
select top 1 LDAP_LOGIN, DATE_PR, REP_BDATE, WORK_H_FACT
   from BUS_GENERAL.EMPLOYEE_DATA_RP
 where DATE_PR > ALL (
                    select DATE_PR
                    from BUS_GENERAL.EMPLOYEE_DATA_RP
                  where LDA_LDAP_LOGIN = (
                                          select LDA_LDAP_LOGIN
                                            from BUS_GENERAL.EMPLOYEE_DATA_RP
                                            where LDAP_LOGIN = 'DN210893ERV'
                                          )
                    )
        and WORK_H_FACT is not null
        AND peop_state = '0'
order by REP_BDATE desc, WORK_H_FACT desc

--
SELECT t1.REP_CLID AS 'ид сотрудника'
     , t1.LDAP_LOGIN AS 'лдап'
     , t1.PEOP_NAME AS 'имя'
     , t1.PEOP_FAM AS 'фамилия'
     , t1.DATE_PR AS 'дата приема'
     , t1.LDA_LDAP_LOGIN AS 'где работает'
     , t1.DEPAR_NAME AS 'название подразделения'
     , t1.WORK_H_FACT AS 'отработанное время'
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 WHERE t1.DATE_PR > ALL(SELECT t2.DATE_PR --хотя по условию через ANY
                          FROM LPAR1.EMPLOYEE_DATA_RP AS t2    
                         WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
                           AND peop_state = '0'
                       )

  AND t1.WORK_H_FACT = (SELECT MAX (t3.WORK_H_FACT)
                           FROM LPAR1.EMPLOYEE_DATA_RP AS t3
                         )
   AND peop_state = '0'
COMMIT;

--variant 3
SELECT max(t2.DATE_PR) as m_date -- макс дата приема нашего сотрудника
into #our_dep_dates
FROM LPAR1.EMPLOYEE_DATA_RP AS t2    
WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
 AND peop_state = '0'
;
commit;

SELECT t1.REP_CLID  
     , t1.LDAP_LOGIN  
     , t1.WORK_H_FACT 
     , t1.REP_BDATE 
into #need_empl
  FROM LPAR1.EMPLOYEE_DATA_RP AS t1
 WHERE t1.DATE_PR > (SELECT a.m_date  
                          FROM #our_dep_dates as a
                       )
        and WORK_H_FACT is not null
        AND peop_state = '0'
;
commit;


--самый молодой сотрудник
SELECT t1.REP_CLID  
     , t1.LDAP_LOGIN  
     , t1.WORK_H_FACT  
into #top_age_sotr
  FROM #need_empl AS t1
 WHERE t1.REP_BDATE = (SELECT max(a.REP_BDATE)
                          FROM #need_empl as a
                       )
;
commit;


select top 1 t1.REP_CLID  
     , t1.LDAP_LOGIN  
     , t1.WORK_H_FACT

from  #top_age_sotr as t1
order by WORK_H_FACT desc

select t1.REP_CLID  
     , t1.LDAP_LOGIN  
     , t1.WORK_H_FACT

from  #top_age_sotr as
where WORK_H_FACT = (select max(a.WORK_H_FACT) from #top_age_sotr as a)


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

--variant 1
SELECT t1.clientid AS ID
     , MAX (t1.LIM) AS 'MAX_SUM_LIM'
into #empl
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

select count() from #empl as t1 
where t1.MAX_SUM_LIM = (SELECT max(a.MAX_SUM_LIM) from #empl as a)
;



--variant 2
SELECT count()
 
  FROM rm.tcards AS t1
 INNER JOIN (SELECT t2.REP_CLID
               FROM LPAR1.EMPLOYEE_DATA_RP as t2
              WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
                AND peop_state = '0'
            ) AS t2 ON t1.clientid = t2.REP_CLID 
 join (SELECT max(a.lim) as m_lim
               FROM rm.tcards as a
              WHERE a.clientid in (
                                    SELECT t2.REP_CLID
                                     FROM LPAR1.EMPLOYEE_DATA_RP as t2
                                    WHERE t2.LDA_LDAP_LOGIN = 'DN0014000000'
                                      AND peop_state = '0'
                                  )
                    and a.GR IN ('UNI', 'UN_M', 'GOLD', 'VIP')
            ) as t3 on t1.lim = t3.m_lim
 WHERE GR IN ('UNI', 'UN_M', 'GOLD', 'VIP')
 
COMMIT; 