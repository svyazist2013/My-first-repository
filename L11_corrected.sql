/*Посчитать по договорам gr in ('UNI','UN_M','GOLD','VIP') динамику сальдо за последние 10 дней,
при этом в каждой текущей строке добавить сумму прироста сальдо по сравнению с вчерашним днем.
Вывести на экран агрегат в формате:
дата                     сальдо                       прирост сальдо по сравнению со вчера
...............................................................................................
2022-07-21          40 000 344 000           138 000
2022-07-21          39 999 844 000           - 500 000
2022-07-22          40 000 000 000           156 000 */

SELECT T1* -- А МОЖЕТ ТОЛЬКО БАЛАНС И ДАТУ 
  INTO #CARDS_BAL
  FROM rm.tcards AS T1
 WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
   AND stateContract not in ('K','C','Z') 
   AND DATE > today()-11
      ;
COMMIT;


create HG index ClientID_HG on #CARDS_BAL(clientid);commit;
create HG index refcontract_HG on #CARDS_BAL(refcontract);commit;

SELECT T1.*
	 , (SELECT T1.bal WHERE DATE = today()-11) - (SELECT T1.bal WHERE DATE = today()-10) AS DELTA_today()_10
	 , (SELECT T1.bal WHERE DATE = today()-10) - (SELECT T1.bal WHERE DATE = today()-9)  AS DELTA_today()_9
	 , (SELECT T1.bal WHERE DATE = today()-9)  - (SELECT T1.bal WHERE DATE = today()-8)  AS DELTA_today()_8
	 , (SELECT T1.bal WHERE DATE = today()-8)  - (SELECT T1.bal WHERE DATE = today()-7)  AS DELTA_today()_7
	 , (SELECT T1.bal WHERE DATE = today()-7)  - (SELECT T1.bal WHERE DATE = today()-6)  AS DELTA_today()_6
	 , (SELECT T1.bal WHERE DATE = today()-6)  - (SELECT T1.bal WHERE DATE = today()-5)  AS DELTA_today()_5
	 , (SELECT T1.bal WHERE DATE = today()-5)  - (SELECT T1.bal WHERE DATE = today()-4)  AS DELTA_today()_4
	 , (SELECT T1.bal WHERE DATE = today()-4)  - (SELECT T1.bal WHERE DATE = today()-3)  AS DELTA_today()_3
	 , (SELECT T1.bal WHERE DATE = today()-3)  - (SELECT T1.bal WHERE DATE = today()-2)  AS DELTA_today()_2
	 , (SELECT T1.bal WHERE DATE = today()-2)  - (SELECT T1.bal WHERE DATE = today()-1)  AS DELTA_today()_1
  INTO #CARDS_BAL_DINAMIC
  FROM #CARDS_BAL AS T1
  ;
COMMIT;


SELECT T1.DATE
     , SUM (T1.bal) AS BAL
	 , SUM (T1.lim) AS LIM
	 , SUM (DELTA_today()_10) AS SUM_D_10
	 , SUM (DELTA_today()_9)  AS SUM_D_9
	 , SUM (DELTA_today(_8)   AS SUM_D_8
	 , SUM (DELTA_today()_7)  AS SUM_D_7
	 , SUM (DELTA_today()_6)  AS SUM_D_6  
	 , SUM (DELTA_today()_5)  AS SUM_D_5 
	 , SUM (DELTA_today()_4)  AS SUM_D_4 
	 , SUM (DELTA_today()_3)  AS SUM_D_3
	 , SUM (DELTA_today()_2)  AS SUM_D_2
	 , SUM (DELTA_today()_3)  AS SUM_D_1
  FROM #CARDS_BAL_DINAMIC AS T1
 GROUP BY T1.DATE
  ;
COMMIT;

----------------------------------------------
--variant 1
select balDate,
			sum(bal) as s_bal
into #sumDynamik
from rm.tcardsDaily AS T1
 WHERE t1.refcontract in (
 													select a.refcontract from rm.tcards as a 
 													where a.gr in ('UNI','UN_M', 'GOLD','VIP')
 												)
   AND t1.balDate > (today()-11)
  group by balDate
;
commit;


select t1.balDate,
				t1.s_bal,
				(t1.s_bal - t2.s_bal) as delta
from #sumDynamik as t1 
left join #sumDynamik as t2 on t1.balDate = (t2.balDate + 1)
;

--variant 2
--lag/lead functions
select 	balDate,
				sum(bal) as s_bal
into #sumDynamik
from rm.tcardsDaily AS T1
 WHERE t1.refcontract in (
 													select a.refcontract from rm.tcards as a 
 													where a.gr in ('UNI','UN_M', 'GOLD','VIP')
 												)
   AND t1.balDate > (today()-11)
  group by balDate
;
commit;

select 	*,
				lag(s_bal) over(order by balDate) as bal2,
				s_bal - bal2 as delta
from #sumDynamik
;


--variant 3

select 	balDate,
				sum(bal) as s_bal_1,
				cast(null as numeric(13,2)) as s_bal_2
into #sumDynamik
from rm.tcardsDaily AS T1
 WHERE t1.refcontract in (
 													select a.refcontract from rm.tcards as a 
 													where a.gr in ('UNI','UN_M', 'GOLD','VIP')
 												)
   AND t1.balDate > (today()-11)
  group by balDate
;
commit;


update #sumDynamik as t1
set t1.s_bal_2 = t2.s_bal_1
from #sumDynamik as t1 
left join #sumDynamik as t2 on t1.balDate = (t2.balDate + 1)
;
commit;

select * ,
				s_bal_1 - s_bal_2

from #sumDynamik


test code !!!!