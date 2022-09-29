/*Какое кол-во людей в банке PB устроились на работу(DATE_PR) в один день или после 
сотрудника DN210893ERV в том же подразделении(Департамент LDA_LDAP_LOGIN ) 
таблица (LPAR1.EMPLOYEE_DATA_RP). В решении задачи использовать вложенный подзапрос в join. 
Таблица сотрудников LPAR1.EMPLOYEE_DATA_RP,
*/

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