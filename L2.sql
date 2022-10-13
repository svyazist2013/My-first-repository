/*создать таблицу в схеме DD010183VVV с названием myFirstTable 
c полями :
ldap - строка, размерность 12 символов.
name - строка 255 символов
surName - строка 255 символов
dateBirth - дата
GPH - флажок сотрудника гпх, два значения 1 или 0, по умолчанию 0
-------------------------
первичный ключ на таблице - ldap, учесть что в таблице не может быть значений null, в любой из колонок*/
--Rodion comment
--test notification

CREATE TABLE DD010183VVV.myFirstTable(
	                     PRIMARY KEY (ldap)
	                   , ldap      char(12)  NOT null
	                   , name      char(255) NOT null
	                   , surName   char(255) NOT null
	                   , dateBirth date      NOT null
	                   , GPH       bit       NOT null
                       )
commit;

/*в таблице DD010183VVV.myFirstTable
добавить колонку 
isMarried - два значения 1 или 0, по умолчанию 0, не может быть значений null*/

ALTER TABLE DD010183VVV.myFirstTable
                    ADD isMarried bit NOT null DEFAULT '0'
commit;

/*в таблице DD010183VVV.myFirstTable
удалить колонку 
dateBirth*/

ALTER TABLE DD010183VVV.myFirstTable
                   DROP dateBirth
commit;

/*изменить колонку isMarried в таблице DD010183VVV.myFirstTable
сделать значение по умолчанию 1, не может быть значений null*/

ALTER TABLE DD010183VVV.myFirstTable
                 MODIFY isMarried NOT null DEFAULT '1'
commit;
