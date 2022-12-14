/* Задача №1

1. Выбрать клиентов из GREEN зоны по геолокации, ИСКЛЮЧИТЬ из них:
  * клиентов с ОКПО работодателя из зоны BURGUNDY
  * клиентов с цветом продукта BURGUNDY
2. Оставить в выборке только клиентов с группами риска Very low risk/Low risk/Medium
3. Оставить в выборке только клиентов с наличием расчетных веток из категории:
  ZARPL,DEPOSIT,SCORE, FOUNDERS, POSHIST,TRANS
4. Для сотрудников применяем только условия по гео зоне GREEN, остальные отсечения к ним не применять.
5. для клиентов с цветом продукта RED, либо цветом ОКПО работодателя RED 
  - обрезать сумму предрасчета до размера 2 средних З/П.
6.  Клиентам, работающих в сфере 'Будівництво та нерухомість'
  - обрезать сумму предрасчета до размера 2 средних З/П.
7. Посчитать по пулу клиентов из выборки:
   * кол-во клиентов
   * сумму установленных лимитов
   * сумму предрасчета на сейчас
   * сумму предрасчета с учетом обрезки до 2 З/П

-------------------------------------------------------------------
P.S Что откуда брать:
1. Предрасчет по клиентам 
табл SERVICELIM.SRVLIM_CLIENT
поле newlim_CutHistAge
2. цвет зоны/продукта
табл LPAR1.LOCATION_ZONE_DATA_RP
поля PROD_COLOR, FINAL_COLOR 
3. цвет ОКПО, сфера деятельности
табл SERVICELIM.zpOkpoColor
поля zone_okpo, REP_PROFIL_NAME
4. Группу риска брать из табл.
  для розницы: SERVICELIM.SRVLIM_ratingMatrix 
  для вип клиентов: SERVICELIM.SRVLIM_ratingMatrix_vip
  * группа риска в поле riskLevel, расшифровка значений в табл ref.trefRiskLevel (поле riskLevelName)
  ** признак VIP брать из табл rm.tclientInfo, поле vip = 1
5. наличие расчетной ветки смотреть по табл SERVICELIM.B_DAY00_ALL(ключ ид клиента+кардгруппа)
  справочник кардгрупп/категорий в ref.tRefTypeComment,
  поле type = cardgroup
  поле over_type - категория
6. размер средней ЗП:
  табл SERVICELIM.tcredLoadProfit
  поле AvgZpObj
7. Признак сотрудника проверяем по наличию расчетной ветки 
  cardgroup in ('SOTR', 'SOTR_FST')
  где смотреть расчетные ветки - описано в п.5

*/

/*1. Выбрать клиентов из GREEN зоны по геолокации, ИСКЛЮЧИТЬ из них:
  * клиентов с ОКПО работодателя из зоны BURGUNDY
  * клиентов с цветом продукта BURGUNDY
*/
SELECT clientid  
      , cast(null as int) as riskLevel
      , cast(null as varchar(50)) as riskLevelName
     , refcontract  
     , limcurr                 AS lim_curr
     , newlim_CutHistAge       AS new_lim
     , cast(0 as numeric(13,2)) as newlim_CutZoneProd_Okpo 
     , cardgroup               AS card_group
     , cast(0 as bit)          as sotr --флаг для сотрудников и другие флаги по аналогии  
     , cast(0 as bit)          as red_zone_prod_okpo_OR_risk_KVED --флаг для продукта, окпо либо квэд
into #client_GREEN
 FROM SERVICELIM.SRVLIM_CLIENT AS T1
WHERE T1.newlim_CutHistAge > 0
  AND T1.clientid IN (SELECT clientid
                            FROM LPAR1.LOCATION_ZONE_DATA_RP AS T2
                           WHERE FINAL_COLOR = 'GREEN' 
                             AND PROD_COLOR != 'BURGUNDY'
                         )
;          
COMMIT;     

create HG index ClientID_HG on #client_GREEN(clientid);       commit;
create HG index refcontract_HG on #client_GREEN(refcontract); commit;

update #client_GREEN as t1 
   set t1.sotr = 1
  from #client_GREEN as t1
  join SERVICELIM.B_DAY00_ALL as t2 on t1.clientid = t2.clientid 
                                   and t2.cardgroup in ('SOTR', 'SOTR_FST')
;
commit;

update #client_GREEN as t1 
   set t1.red_zone_prod_okpo_OR_risk_KVED = 1
  from #client_GREEN as t1
  join LPAR1.LOCATION_ZONE_DATA_RP AS T2 on t1.clientid = t2.clientid 
                                        AND PROD_COLOR = 'RED'
;
commit;

select top 5 t1.*, t2.zone_okpo, t2.REP_PROFIL_NAME
into #tmp
from #client_GREEN as t1
  join SERVICELIM.zpOkpoColor  AS T2 on t1.clientid = t2.clientid 
                                    AND T2.zone_okpo = 'RED'
;
commit;

insert into #tmp
  select top 5 t1.*, t2.zone_okpo, t2.REP_PROFIL_NAME
from #client_GREEN as t1
  join SERVICELIM.zpOkpoColor  AS T2 on t1.clientid = t2.clientid 
                                    AND T2.REP_PROFIL_NAME = 'Будівництво та нерухомість'
;
commit;

update #client_GREEN as t1 
   set t1.red_zone_prod_okpo_OR_risk_KVED = 1
  from #client_GREEN as t1
  join SERVICELIM.zpOkpoColor  AS T2 on t1.clientid = t2.clientid 
                                    AND T2.zone_okpo = 'RED'
                                     --OR T2.REP_PROFIL_NAME = 'Будівництво та нерухомість') 
                                     -- без скобок происходит связка по условию  'Будівництво та нерухомість' без проверки равенства clientid
                                     --(декартово произведение, связка всего со всеми) 
;
commit;

update #client_GREEN as t1 
   set t1.red_zone_prod_okpo_OR_risk_KVED = 1
  from #client_GREEN as t1
  join SERVICELIM.zpOkpoColor  AS T2 on t1.clientid = t2.clientid 
                                    AND T2.REP_PROFIL_NAME = 'Будівництво та нерухомість'
;
commit;

delete #client_GREEN
  FROM #client_GREEN AS T1
  join SERVICELIM.zpOkpoColor as t2 on t1.clientid = t2.clientid
                                   and t2.zone_okpo = 'BURGUNDY' 
where t1.sotr = 0
;
COMMIT; 

/*2. Оставить в выборке только клиентов с группами риска Very low risk/Low risk/Medium
*/


update #client_GREEN as t1 
   set t1.riskLevel = t2.riskLevel
  from #client_GREEN as t1
  join SERVICELIM.SRVLIM_ratingMatrix AS T2 on t1.clientid = t2.clientid
;
commit;

update #client_GREEN as t1 
   set t1.riskLevelName = t3.riskLevelName
  from #client_GREEN as t1
 join ref.trefRiskLevel AS T3 on t1.riskLevel = t3.riskLevel
;
commit;


/*
--БЫЛО
delete #client_GREEN
  FROM #client_GREEN AS T1
 left join SERVICELIM.SRVLIM_ratingMatrix AS T2 on t1.clientid = t2.clientid
 join ref.trefRiskLevel AS T3 on t2.riskLevel = t3.riskLevel
                              and t3.riskLevelName IN ('Very low risk', 'Low risk', 'Medium risk')
 where t2.clientid is null and t1.sotr = 0

 --
 count() = 0

 не удаляет ввиду последовательности выполнения частей запроса
 1) отрабатывают join 
 2) отрабатывает where

 1) пересечение с табл матрицы.
 2) Оставляем только клиентов в нужных группах риска
 3) проверяем клиентов с clientid is null , таких нет. Т.к. все клиенты 'Very low risk', 'Low risk', 'Medium risk'
  присутствуют в табл матрицы.
;
commit;*/

delete #client_GREEN
  FROM #client_GREEN AS T1
 left join SERVICELIM.SRVLIM_ratingMatrix AS T2 on t1.clientid = t2.clientid
                                                and t2.riskLevel in (
                                                  select a.riskLevel from ref.trefRiskLevel as a 
                                                  where a.riskLevelName IN ('Very low risk', 'Low risk', 'Medium risk')
                                              )
 where  t2.clientid is null 
        and t1.sotr = 0
;
commit;

--не удалил плохих клиентов
/*delete #client_GREEN
  FROM #client_GREEN AS T1
 left join SERVICELIM.SRVLIM_ratingMatrix AS T2 on t1.clientid = t2.clientid
 join ref.trefRiskLevel AS T3 on t2.riskLevel = t3.riskLevel
                              and t3.riskLevelName IN ('Very low risk', 'Low risk', 'Medium risk')
 where  t2.clientid is null 
        and t1.sotr = 0
;
commit;*/

/*3. Оставить в выборке только клиентов с наличием расчетных веток из категории:
  ZARPL,DEPOSIT,SCORE, FOUNDERS, POSHIST,TRANS
*/

   delete #client_GREEN
     FROM #client_GREEN AS T1
left join SERVICELIM.B_DAY00_ALL AS T2 on t1.clientid = t2.clientid
                                        and t2.cardgroup IN (
                                                      SELECT TYPE
                                                        FROM ref.tRefTypeComment AS T3
                                                       WHERE over_type IN (
                                                                          'ZARPL', 
                                                                          'DEPOSIT', 
                                                                          'SCORE', 
                                                                          'FOUNDERS', 
                                                                          'POSHIST', 
                                                                          'TRANS')
                                                             )
 where t2.clientid is null and t1.sotr = 0
;
commit;

/*4. Для сотрудников применяем только условия по гео зоне GREEN, остальные отсечения к ним не применять.*/ --убрать D по таблице табл SERVICELIM.SRVLIM_CLIENT?
SELECT top 10 *
  from SERVICELIM.SRVLIM_CLIENT
 where f_nclient  IS NULL 
   AND f_nref     IS NULL
   AND f_nref_add IS NULL*/
   AND newlim_CutHistAge > 0
;


/*5. для клиентов с цветом продукта RED, либо цветом ОКПО работодателя RED 
  - обрезать сумму предрасчета до размера 2 средних З/П.
6.  Клиентам, работающих в сфере 'Будівництво та нерухомість'
  - обрезать сумму предрасчета до размера 2 средних З/П.*/

  update #client_GREEN as t1 
     set newlim_CutZoneProd_Okpo = (T2.AvgZpObj * 2)
    from #client_GREEN as t1
    join SERVICELIM.tcredLoadProfit  AS T2 ON t1.clientid = t2.clientid 
                                    AND T1.red_zone_prod_okpo_OR_risk_KVED = 1
                                     
;
commit;

update #client_GREEN as t1 
     set newlim_CutZoneProd_Okpo = T1.new_lim
    from #client_GREEN as t1
   WHERE T1.red_zone_prod_okpo_OR_risk_KVED = 0
                                     
;
commit;


/*7. Посчитать по пулу клиентов из выборки:
   * кол-во клиентов
   * сумму установленных лимитов
   * сумму предрасчета на сейчас
   * сумму предрасчета с учетом обрезки до 2 З/П*/


   SELECT COUNT (clientid)    AS 'кол-во клиентов'
        , SUM   (lim_curr) AS 'сумму установленных лимитов'
        , SUM   (new_lim)  AS 'сумму предрасчета на сейчас'
        , SUM   (newlim_CutZoneProd_Okpo)  AS 'сумму предрасчета с учетом обрезки до 2 З/П'
  from #client_GREEN
