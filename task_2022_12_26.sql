/*
??????? 1.
? ??????? ?????? ?????????? ??????????? ?????????:
?) ???-?? ???????? ?????
?) ???-?? ???????? ? ????????????? ???????
?) ????? ?????????????? ??????
?) ????? ???????????????? ??????
?) ???-?? ????????, ?? ??????? ????? ??????????? ??????? ?? 1000 ??? ?????? ?????????????? ??????
?) ????????? ?????????? (??????) ?????? ????? ????????, ?? ??????? ????? ??????????? ??????? ?? 1000 ??? 
	?????? ?????????????? ??????
????? ?? ????????, ??? ? ???? ???????????:
 * ? ???? limCurr ????? ???? null (??????? ?? ??? ????)
 * ? ???? max_newlimit ????? ???? null (??????? ?? ??? ????)

 ??? ??????? ???????????? ???? ??????????? SERVICELIM.SRVLIM_CLIENT:
 * ???? cardGroup
 * limCurr - ????????????? ?????
 * max_newlimit - ??????????

 ? ???????? ??????? ???????? ??????????? ??????????, ???????? ?????????. 
 ??? ????? ???????????? ?????????? ref.tRefTypeComment:
 * type - ???????? ??????????
 * ID_TYPE - ??? ????? ( ??? ????? 'UP')
 * INT_COMMENT - ??????? ??????????? ??????????
 * over_type - ???????? ?????????

????????? ????????? ??????? ?????? ????????? ???????? ???:
cardgroup	INT_COMMENT	cntAll	cntLim	s_lim	s_maxNewlim	cnt_delta	s_deltaUp
------------------------------------
ZARPL_B	??????????? - ?? ??????	ZARPL	2 145 346	1 234 905	22 456 343 678	49 569 343 678	13 569 523	17 178 178 523
MOBILEBANK	?????????? ??? ??? ? ?????	PAYCASSA	145 346		234 905		456 343 678		569 343 135 	69 523		178 178 523
.......
.......
*/


/*
??????? 2.
????? ????????? ?? ??????? 1 ???????? ??? 3 ?? ???-?? ???????? ?? ?????? ?????????(over_type).
??????? ???????? ??????????, ???????? ?????????, ???-?? ????????
*/

/*
??????? 3.
????? ????????? ?? ??????? 1 ???????? ??? 3 ?? ???-?? ???????? ?? ?????? ?????????(over_type),
?? ??? ???? ?? ????? ? ???? ??????????, ??????? ?? ???????? ? ??? 5 ????? ??????? ????????? ?? ???-?? ????????.
??????? ???????? ??????????, ???????? ?????????, ???-?? ????????
*/