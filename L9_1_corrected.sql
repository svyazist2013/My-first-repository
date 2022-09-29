/*"Посчитать среднюю утилизацию по всему портфелю карт (gr in ('UNI','UN_M', 'GOLD','VIP') and stateContract not in ('K','C','Z'))
табл rm.tcards
bal = сальдо, lim = лимит"*/


   SELECT cast(round (SUM (T1.bal) / SUM (T1.lim) * 100, 2) as numeric(13,2)) AS AVG_UTIL
     FROM rm.tcards AS T1
    WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
      AND stateContract not in ('K','C','Z')
        ;
  COMMIT;

  /*По портфелю карт посчитать объемы сальдо и доли по сальдо в разрезе сегментов в зависимости от установленной суммы лимита. 
 (gr in ('UNI','UN_M', 'GOLD','VIP') and stateContract not in ('K','C','Z'))
табл rm.tcards.
bal = сальдо, lim = лимит

в таком виде:
лимиты 0-500 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 500-1000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 1000-5000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 5000-10000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 1000-25000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 25000-50000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
лимиты 50000-100000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля
более 100000 грн ....(сальдо сегмента) ...... доля сегмента по сальдо от общ. портфеля*/

   SELECT SUM (T1.bal) AS bal
     INTO #CARDS_BAL
     FROM rm.tcards AS T1
    WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
      AND stateContract not in ('K','C','Z')
        ;
  COMMIT;

  SELECT CASE WHEN T1.lim BETWEEN 0     AND 499.99  THEN 'лимиты 0-499 грн'
              WHEN T1.lim BETWEEN 500  AND 999.99  THEN 'лимиты 500-1000 грн'
              WHEN T1.lim BETWEEN 1000 AND 4999.99 THEN 'лимиты 1000-5000 грн'
              WHEN T1.lim BETWEEN 5000 AND 9999.99 THEN 'лимиты 5000-10000 грн'
              ELSE 'лимиты >10000 грн' END AS SEG_LIM
            , SUM (T1.bal) AS SUM_SEG_LIM
            , t2.bal
     into #s_bal
     FROM rm.tcards AS T1
    CROSS JOIN #CARDS_BAL AS T2 
    WHERE gr in ('UNI','UN_M', 'GOLD','VIP')
      AND stateContract not in ('K','C','Z')
    GROUP BY SEG_LIM,t2.bal
;
commit;

   select SEG_LIM,
          SUM_SEG_LIM,
          cast(round(SUM_SEG_LIM/bal*100.0,2) as numeric(13,2)) as bal_part-- может ли быть значение выражения в строке другого сегмента?

   from #s_bal

;

/*
SEG_LIM SUM_SEG_LIM bal_part
лимиты 500-1000 грн   -28387377.85  0.05
лимиты 1000-5000 грн  -947080270.10 1.65
лимиты 5000-10000 грн -2426186193.43  4.22
лимиты 0-499 грн      -12261200374.31 21.34
лимиты >10000 грн     -41785362476.10 72.74

*/
----------
/*От объема централизованных снижений лимита за 2022-06-30 отобрать по 10% договоров из каждой кардгруппы
 (10% считать от общ кол-ва в этой кардгруппе), по максимальной дельте снижения.
таб. rm.tcredCatalogChangeLimit
фильтры:
cg is null -- контр группа
chlimstatus  = 1 -- упешное изменение
source = 'CENTRAL'
id_type = 'DOWN'

datechange - дата изменения лимита
slimCurr - лимит до снижения
slimNew - лимит после снижения

собрать результат в постоянную табл в своей схеме, и вывести на экран кол-во записей в табл

(смотреть функции ранжирования)*/


 SELECT T1.CardGroup
      , T1.refcontract
      , (T1.slimCurr - T1.slimNew) AS DELTA_VOL
      , ROW_NUMBER() OVER (PARTITION BY T1.CardGroup ORDER BY DELTA_VOL DESC) AS RNK
   INTO #TMP_1
   FROM rm.tcredCatalogChangeLimit AS T1   
  WHERE datechange = '2022-06-30'
    AND source = 'CENTRAL'
    AND id_type = 'DOWN'
    AND chlimstatus = 1
    AND cg is null
    ;
    COMMIT;


   SELECT CardGroup
        , COUNT (CardGroup) AS COUNT_CARD
        , max (RNK) AS MAX_RNK
        , ROUND (MAX_RNK/10, 0) AS RNK_10
     INTO #TMP_2
     FROM #TMP_1 AS T2
     GROUP by CardGroup
     ;

  SELECT T1.CardGroup
       , T1.refcontract
       , T1.DELTA_VOL
       , T1.RNK
    INTO #TMP_3
    FROM #TMP_1 AS T1
    JOIN #TMP_2 AS T2 ON T1.CardGroup = T2.CardGroup
   WHERE T1.RNK <= T2.RNK_10
   ; 
   COMMIT;





CREATE TABLE DD010183VVV.DOWN_STAT(
	                     PRIMARY KEY (refcontract)
	                   , refcontract    char(25)      NOT null
	                   , CardGroup      char(25)      NOT null
	                   , DELTA_VOL      numeric(13,2) NOT null
	                   , RNK            int           NOT null
                       )
commit;
   INSERT INTO DD010183VVV.DOWN_STAT( 
	                                refcontract
                                , CardGroup
                                , DELTA_VOL
                                , RNK
                                   )
SELECT   T1.refcontract
       , T1.CardGroup
       , T1.DELTA_VOL
       , T1.RNK
    FROM #TMP_1 AS T1
    JOIN #TMP_2 AS T2 ON T1.CardGroup = T2.CardGroup
   WHERE T1.RNK <= T2.RNK_10
   ; 
   COMMIT;


SELECT COUNT ()
  FROM DD010183VVV.DOWN_STAT
  ;


/*предположим, что клиентов из выборки в пункте 3 нам надо обзвонить, для этого их надо закрепить за условными сотрудниками отделения.
Пусть под этот проект нам выделили 700 сотрудников. Они пронумерованы от 1 до 700 в некотором списке.
Задача - распределить равномерно клиентов из нашей выборки между этими 700 сотрудниками. Для этого нам будет достаточно в итоговой временной таблице из пункта 3 добавить поле, в котором будет ранг от 1 до 700. 
Учесть, что на сотрудников с меньшим порядковым номером надо передавать договора с самыми большими дельтами снижения в первую очередь

(смотреть функции ранжирования)*/


  SELECT  NTILE (700) OVER (ORDER BY DELTA_VOL DESC) AS NT_RNK
        , refcontract
        , CardGroup
        , DELTA_VOL
        , RNK
  INTO #TMP_4
  FROM DD010183VVV.DOWN_STAT 
  ;
  COMMIT; 


  SELECT TOP 100*
    FROM #TMP_4
    ;

 SELECT COUNT ()
      , SUM (DELTA_VOL)
      , NT_RNK
   FROM #TMP_4
  GROUP BY NT_RNK;


  /*Посчитать потенциал увеличения по кредитным картам.
Для этого нужно использовать источник SERVICELIM.SRVLIM_CLIENT
1) по полям max_newlimit и limCurr можно определить потенциал
2) исключить клиентов с пустыми ('') либо null договорами (поле refcontract)
3) исключить клиентов, у которых есть жесткие для волны стоп-факторы по клиенту
(негатив по клиенту находится в таблице SERVICELIM.NCLIENT_DAY00, 
флаг жесткости можно проверить в справочнике ref.treftypeCommentSystem, поле WAVE )
4) исключить клиентов, у которых по договору есть жесткие для волны стоп-факторы 
(негатив по договору находится в таблице SERVICELIM.NREF_DAY00,  связка по полю refcontract,
флаг жесткости можно проверить в справочнике ref.treftypeCommentSystem, поле WAVE ) 
5) исключить клиентов, у которых было какое-либо изменение лимита по журналу за последние 90 дней
 (журнал rm.tCredCatalogChangeLimit, связка по полю refcontract)
6) исключить вип-клиентов ( rm.tclientinfo, поле vip = 1)
7) исключить клиентов, которые были в работе бизнеса за последние 30 дней (SERVICELIM.tLimitsForBusiness)
Вывод: вывести на экран потенциал увеличения , и кол-во клиентов в разрезе группы риска (табл SERVICELIM.SRVLIM_ratingMatrix, поле matrixColor)*/

--разбить запрос , т.к. слишком тяжелый 
--исходник
     SELECT clientid
          , refcontract
          , max_newlimit - limCurr AS POTENCIAL
          , limcurr
          , max_newlimit
          , cardgroup
       INTO #POTENCIAL
       FROM SERVICELIM.SRVLIM_CLIENT AS T1
  LEFT JOIN SERVICELIM.NCLIENT_DAY00 AS T2 ON T1.clientid = T2.clientid 
      WHERE POTENCIAL > 0
        AND refcontract IS NOT NULL -- не проверили NULL
        AND T2.id_type NOT IN (SELECT id_type
                                 FROM ref.treftypeCommentSystem AS T3
                                WHERE WAVE = 'Y'
                                ) --!!! теряются клиенты без стоп-факторов
          ;
COMMIT;


--переписанный
SELECT clientid
          , refcontract
          , max_newlimit - limCurr AS POTENCIAL
          , limcurr
          , max_newlimit
          , cardgroup
          , f_nclient
          , f_nref
          , f_nref_add
       INTO #POTENCIAL
       FROM SERVICELIM.SRVLIM_CLIENT AS T1
      WHERE POTENCIAL > 0
        AND isnull(refcontract,'') <> ''
;
COMMIT;

--создать индекс по ид клиента, т.к. часто используется в join , 
--и при этом кол-во записей > 1000

create HG index ClientID_HG on #POTENCIAL(clientid);commit;
create HG index refcontract_HG on #POTENCIAL(refcontract);commit;

--удаляем клиентов с негативом
delete #POTENCIAL as t1 
from #POTENCIAL as t1 
join SERVICELIM.NCLIENT_DAY00 AS T2 ON T1.clientid = T2.clientid 
join ref.treftypeCommentSystem AS T3 on t2.id_type = t3.id_type
                                  and t3.wave = 'Y'
;
commit;

/*4) исключить клиентов, у которых по договору есть жесткие для волны стоп-факторы 
(негатив по договору находится в таблице SERVICELIM.NREF_DAY00,  связка по полю refcontract,
флаг жесткости можно проверить в справочнике ref.treftypeCommentSystem, поле WAVE )*/

    DELETE #POTENCIAL
      FROM #POTENCIAL as t1 --алиас пропущен
 LEFT JOIN SERVICELIM.NREF_DAY00 AS T4 ON T1.refcontract = T4.refcontract
     WHERE T4.id_type IN (SELECT id_type
                            FROM ref.treftypeCommentSystem AS T3
                           WHERE WAVE = 'Y'
                             )
   ;
COMMIT;

/*5) исключить клиентов, у которых было какое-либо изменение лимита по журналу за последние 90 дней
 (журнал rm.tCredCatalogChangeLimit, связка по полю refcontract)*/

    DELETE #POTENCIAL
      FROM #POTENCIAL as t1 -- алиас пропущен
     WHERE T1.refcontract IN (SELECT refcontract
                                FROM rm.tCredCatalogChangeLimit AS T5
                               WHERE dateDT > today()-90
                             )
   ;
COMMIT;


/*6) исключить вип-клиентов (rm.tclientinfo, поле vip = 1  ClientID)*/ 

    DELETE #POTENCIAL
      FROM #POTENCIAL as t1 -- алиас пропущен
     WHERE T1.clientid IN (SELECT ClientID
                             FROM rm.tclientinfo AS T6
                            WHERE vip = 1
                             )
   ;
COMMIT;


/*7) исключить клиентов, которые были в работе бизнеса за последние 30 дней*/
--SERVICELIM.tLimitsForBusiness

DELETE #POTENCIAL
      FROM #POTENCIAL as t1 -- алиас пропущен
     WHERE T1.clientid IN (SELECT ClientID
                             FROM SERVICELIM.tLimitsForBusiness AS T6
                            WHERE t6.dateODB >= dateadd(dd,-30,today())
                             )
   ;
COMMIT;

--Вывод: вывести на экран потенциал увеличения , и кол-во клиентов в разрезе группы риска 
--(табл SERVICELIM.SRVLIM_ratingMatrix, поле matrixColor)

select  t2.matrixColor,
        sum(POTENCIAL) as s_potencial,
        count(t1.clientid) as cnt_cl

from #POTENCIAL as t1 
join SERVICELIM.SRVLIM_ratingMatrix as t2 on t1.ClientID = t2.clientid
group by t2.matrixColor
;


/*matrixColor s_potencial cnt_cl
BLUE  24 114 214 269  | 886 996
GREEN 8 163 616 828 | 357 205*/
