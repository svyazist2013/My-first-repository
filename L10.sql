/*Отобрать во временную таблицу клиентов, которые за полгода официально получали ЗП в приватбанке.
* использовать источник rm.tDebCard. Определить наличие выплат за последние полгода можно по полю AvgZpObj.
* брать в учет только следующие типы ЗП проектов
VIP -КОММЕРЧЕСКИЙ                                                                                   
БЮДЖЕТНЫЙ                                                                                           
КОМЕРЧЕСКИЙ                                                                                         
СТРАТЕГИЧЕСКИЙ   
СОТРУДНИКИ БАНКА                                                                                                                                                                       
справочник типов в табл ref.trefZpProjType, поле ZpProjType
* Не брать в учет клиентов, у которых поле ZpOKPO в rm.tDebCard пустое
* по окпо предприятия от которого зачисления дотянуть код сферы деятельности из табл rm.TCLIENTINFO (поле K110) , связка по ZpOKPO и inn
* по коду сферы деятельности вытянуть из справочника название сферы деятельности (табл. rm.k110, поле UKR_SUB_INDUST)

По этим клиентам вывести на экран агрегатную информацию за последние полгода помесячно по суммам зачислений в разрезе каждой сферы деятельности.
(помесячные суммы есть в rm.tDebCard, в полях Z01obj        Z02obj        Z03obj        Z04obj        Z05obj        Z06obj)
выгрузить результат в экселевский файл*/

SELECT *
  INTO #client_Zp
  FROM rm.tDebCard AS T1
 WHERE AvgZpObj > 0 -- OR IS NOT NULL
   AND ZpProjType IN (SELECT ZpProjType
                        FROM ref.trefZpProjType AS T2
                       WHERE comm IN ( 'VIP -КОММЕРЧЕСКИЙ'
                                     , 'БЮДЖЕТНЫЙ'                                                                                           
                                     , 'КОМЕРЧЕСКИЙ'                                                                                         
                                     , 'СТРАТЕГИЧЕСКИЙ'   
                                     , 'СОТРУДНИКИ БАНКА'
                                     )
                     )
   AND ZpOKPO IS NOT NULL
     ;
     COMMIT;

-- *по окпо предприятия от которого зачисления дотянуть код сферы деятельности из табл rm.TCLIENTINFO (поле K110) , связка по ZpOKPO и inn
     SELECT * 
          , T5.k110
       INTO #client_Zp_k110
       FROM #client_Zp AS T3
  LEFT JOIN rm.TCLIENTINFO AS T4 ON T3.ZpOKPO = T4.inn
  ;
  COMMIT;

--* по коду сферы деятельности вытянуть из справочника название сферы деятельности (табл. rm.k110, поле UKR_SUB_INDUST)
SELECT *
     , T3.UKR_SUB_INDUST
  INTO #client_Zp_INDUST_k110
  FROM #client_Zp__k110 AS T5
  JOIN rm.k110 AS T6 ON T5.k110 = T6.k110
  ;
  COMMIT;



/*SELECT *
     , T5.k110
     , T3.UKR_SUB_INDUST
  INTO #client_Zp_INDUST
  FROM #client_Zp AS T4
  JOIN rm.TCLIENTINFO AS T5 ON T4.ZpOKPO = T5.inn
  JOIN rm.k110 AS T3 ON T3.k110 = T5.k110
  ;
  COMMIT;*/

--V2
SELECT *
     , T2.k110
     , T3.UKR_SUB_INDUST
  INTO #client_Zp
  FROM rm.tDebCard AS T1
  JOIN rm.TCLIENTINFO AS T2 ON T1.ZpOKPO = T2.inn
  JOIN rm.k110        AS T3 ON T3.k110 = T2.k110
 WHERE AvgZpObj > 0 -- OR IS NOT NULL
   AND ZpProjType IN (SELECT ZpProjType
                        FROM ref.trefZpProjType AS T4
                       WHERE comm IN ( 'VIP -КОММЕРЧЕСКИЙ'
                                     , 'БЮДЖЕТНЫЙ'                                                                                           
                                     , 'КОМЕРЧЕСКИЙ'                                                                                         
                                     , 'СТРАТЕГИЧЕСКИЙ'   
                                     , 'СОТРУДНИКИ БАНКА'
                                     )
                     )
   AND ZpOKPO IS NOT NULL
     ;
     COMMIT;


/*По этим клиентам вывести на экран агрегатную информацию за последние полгода помесячно по суммам зачислений в разрезе каждой сферы деятельности.
(помесячные суммы есть в rm.tDebCard, в полях Z01obj        Z02obj        Z03obj        Z04obj        Z05obj        Z06obj)
выгрузить результат в экселевский файл*/

SELECT k110
     , UKR_SUB_INDUST
     , SUM (Z01obj)
     , SUM (Z02obj)
     , SUM (Z03obj)      
     , SUM (Z04obj)       
     , SUM (Z05obj)       
     , SUM (Z06obj)
  FROM #client_Zp_INDUST_k110 AS T7
 GROUP BY k110, UKR_SUB_INDUST
 ;
 COMMIT;