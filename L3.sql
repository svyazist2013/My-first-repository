/*создать таблицу в схеме DD010183VVV с названием mytCards
c полями :
refcontract - строка, размерность 25 символов.
stateContract- строка 1 символ
lim - число, размерность 13 с точностью до 2 знаков
gr - строка 10 символов
exAge - int*/
--test Rodion

CREATE TABLE DD010183VVV.mytCards(
	                     PRIMARY KEY (ldap)
	                   , refcontract    char(25)      NOT null
	                   , stateContract  char(1)       NOT null
	                   , lim            numeric(13,2) NOT null
	                   , gr             char(10)      NOT null
	                   , exAge          int           NOT null
                       )
commit;


-------------------------
/*1) Наполнить таблицу данными из таблицы rm.tcards с соответствующими названиями колонок, согласно условий:
* продукты (gr) UNI или UN_M или GOLD или DEP или VIP
* без дней просрочки (exage)
* с датой старта договора >= начало текущего года*/

INSERT INTO DD010183VVV.mytCards( 
	                              refcontract
                                , stateContract
                                , lim
                                , gr
                                , exAge)
SELECT refcontract
     , stateContract
     , lim
     , gr
     , exAge
  FROM rm.tcards
 WHERE  GR = ('UNI', 'UN_M', 'GOLD', 'DEP', 'VIP') -- IN ('UNI', 'UN_M', 'GOLD', 'DEP', 'VIP')?
   AND  exage = 0 -- + OR NULL?
   AND  date >= SELECT DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)--????
commit;

--2) Удалить из таблицы договора, которые относятся к продукту VIP или имеют статус(stateContract) закрыт (K или C или Z)

DELETE DD010183VVV.mytCards
  FROM DD010183VVV.mytCards
 WHERE gr = 'VIP'
    OR stateContract =('K', 'C', 'Z') 
commit;    

--3) изменить значение продуктов(gr) по продуктам UN_M - изменить на UNI, по продуктам DEP - изменить на DEPOS

UPDATE DD010183VVV.mytCards
   SET gr = 'UNI'
  FROM DD010183VVV.mytCards
 WHERE gr = 'UN_M'
 commit;

 UPDATE DD010183VVV.mytCards
    SET gr = 'DEPOS'
   FROM DD010183VVV.mytCards
  WHERE gr = 'DEP'
 commit;

--4) Вывести на экран кол-во договоров, сумму лимита(lim), среднюю сумму лимита(lim)  по каждому продукту

SELECT gr as product
     , COUNT(refcontract) as cRef
     , SUM(lim) as sLim
     , AVG(lim) as avLim 

 GROUP BY product
commit;

--5) Вывести на экран кол-во договоров, сумму лимита(lim), среднюю сумму лимита(lim)  в разрезе каждого продукта + статуса договора

SELECT gr as product
     , stateContract
     , COUNT(refcontract) as cRef
     , SUM(lim) as sLim
     , AVG(lim) as avLim 
  FROM DD010183VVV.mytCards
 GROUP BY product, stateContract
commit;

--6) Вывести на экран кол-во уникальных статусов договоров в разрезе каждого продукта

SELECT DISTINC gr as product
     , COUNT(DISTINC stateContract) as sContr
  FROM DD010183VVV.mytCards
commit;--Есть сомнения)

--7) очистить таблицу DD010183VVV.mytCards

DELETE DD010183VVV.mytCards
  FROM DD010183VVV.mytCards
commit;

--8) удалить таблицу DD010183VVV.mytCards*/
DROP TABLE DD010183VVV.mytCards
    commit;



