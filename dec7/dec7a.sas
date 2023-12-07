data in;
 infile '/home/xxxx/dec7_in.txt' delimiter=';';

 length row $200 _cards $5 _bid 8;
 
 input row;

 _cards = scan(row,1);
 _bid = scan(row,2);

 _cardindex = reverse('AKQJT98765432');

 do i = 1 to 5;
 	_card = substr(_cards,i,1);
 	_cardvalue = indexc(_cardindex,_card);
	output;
 end;

 run;

 proc summary data=in nway missing;
  class _cards _card _bid;
  var _cardvalue;
  output out=stats sum=;
 run;

 proc sort data=stats;
  by _cards _bid descending _freq_;
run;

proc transpose data=stats out=stats2 prefix=_cnt;
 by _cards _bid;
 var _freq_;
run;

data stats3;
 set stats2;
 length _cnt1 - _cnt5 8;
 array _cardvalues(5) _cardvalue1-_cardvalue5;                                                                                                                      

 _cardindex = reverse('AKQJT98765432');

 do i = 1 to 5;
 	_card = substr(_cards,i,1);
 	_cardvalues(i) = indexc(_cardindex,_card);
 end;

run;

proc sort data=stats3 out=stats4;
 by _cnt1 - _cnt5 _cardvalue1 - _cardvalue5;
run;

data stats5;
 set stats4;
 length _score 8;
 _score = _n_ * _bid;
run;

proc summary data=stats5 nway missing;
 var _score;
 output out=final sum=;
run;

/*
proc sort data=stats3 out=stats4;
 by descending _cnt1
	descending _cnt2
	descending _cnt3
	descending _cnt4
	descending _cnt5
	descending _cardvalue1
	descending _cardvalue2
	descending _cardvalue3
	descending _cardvalue4
	descending _cardvalue5
;
run;
*/