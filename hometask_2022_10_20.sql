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
6. 	Клиентам, работающих в сфере 'Будівництво та нерухомість'
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
SELECT clientid                AS ID_CL
     , newlim_CutHistAge       AS new_lim
	 , limcurr                 AS lim_curr
	 , refcontract             AS ref_contract
	 , cardgroup               AS card_group
 INTO #client_GREEN
 FROM SERVICELIM.SRVLIM_CLIENT AS T1
WHERE T1.newlim_CutHistAge > 0
  AND T1.clientid IN (SELECT clientid
                        FROM ref.trefZpProjType AS T2
                       WHERE FINAL_COLOR = 'GREEN' 
					     AND PROD_COLOR != 'BURGUNDY'
                     )
;					 
COMMIT;			

create HG index ClientID_HG on #client_GREEN(clientid);       commit;
create HG index refcontract_HG on #client_GREEN(refcontract); commit;

SELECT *
  INTO #client_OKPO
  FROM #client_GREEN AS T1
 WHERE T1.clientid NOT IN (SELECT clientid
                             FROM SERVICELIM.zpOkpoColor AS T2
                            WHERE zone_okpo = 'BURGUNDY' 
                          )
;
COMMIT;	

create HG index ClientID_HG    on #client_OKPO(clientid);    commit;
create HG index refcontract_HG on #client_OKPO(refcontract); commit;

/*2. Оставить в выборке только клиентов с группами риска Very low risk/Low risk/Medium
*/

SELECT *
  INTO #client_ratingMatrix 
  FROM #client_OKPO AS T1
 WHERE T1.clientid IN (SELECT clientid
                         FROM SERVICELIM.SRVLIM_ratingMatrix AS T2
                        WHERE riskLevel IN (SELECT riskLevel
                                              FROM ref.trefRiskLevel AS T3
                                             WHERE riskLevelName IN ('Very low risk', 'Low risk', 'Medium risk')
							               )
                      )
;
COMMIT;	

create HG index ClientID_HG    on #client_ratingMatrix(clientid);    commit;
create HG index refcontract_HG on #client_ratingMatrix(refcontract); commit;


/*3. Оставить в выборке только клиентов с наличием расчетных веток из категории:
 	ZARPL,DEPOSIT,SCORE, FOUNDERS, POSHIST,TRANS
*/

SELECT *
  INTO #client_cardgroup 
  FROM #client_ratingMatrix AS T1
 WHERE T1.clientid IN (SELECT clientid
                         FROM SERVICELIM.B_DAY00_ALL AS T2
                        WHERE cardgroup IN (SELECT TYPE
                                              FROM ref.tRefTypeComment AS T3
                                             WHERE over_type IN ('ZARPL', 'DEPOSIT', 'SCORE', 'FOUNDERS', 'POSHIST', 'TRANS')
							               )
                      )
;
COMMIT;

create HG index ClientID_HG    on #client_cardgroup(clientid);    commit;
create HG index refcontract_HG on #client_cardgroup(refcontract); commit;

4. Для сотрудников применяем только условия по гео зоне GREEN, остальные отсечения к ним не применять.
5. для клиентов с цветом продукта RED, либо цветом ОКПО работодателя RED 
	- обрезать сумму предрасчета до размера 2 средних З/П.
6. 	Клиентам, работающих в сфере 'Будівництво та нерухомість'
	- обрезать сумму предрасчета до размера 2 средних З/П.
7. Посчитать по пулу клиентов из выборки:
   * кол-во клиентов
   * сумму установленных лимитов
   * сумму предрасчета на сейчас
   * сумму предрасчета с учетом обрезки до 2 З/П
