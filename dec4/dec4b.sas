data in;
 infile '/home/xxxx/dec4_in.txt' delimiter=';';

 length row winstr mystr $200 winpart mypart $3 score total hits cardno 8;
 
 input row;
 retain total;

 cardno = input(scan(scan(row,1,':'),2),8.);
 winstr = scan(row,2,':|');
 mystr = scan(row,3,':|');

 score = 0;
 hits = 0;
 i = 1;
 do while (scan(mystr,i) ne '');
 	mypart = scan(mystr,i);

	o = 1;
 	do while (scan(winstr,o) ne '');
		winpart = scan(winstr,o);

		if mypart = winpart then do;
			hits + 1;

			if score = 0 then score = 1;
			else score = 2 * score;
		end;

		o + 1;
	end;

 	i + 1;
 end;

 total + score;

run;

data newcards;
 set in;
 length card $10 cardno_org 8.;

 card = cats('Card',put(cardno,8.));

 keep card cardno hits cardno_org;
run;

%macro create_cards;

 proc sql noprint;
 	select count(*) into :numcards from newcards;
	select max(cardno) into :maxcardno from newcards;
 quit;

 %do a = 1 %to &numcards;
	data cards_tmp;
	 set newcards(where=(cardno = &a.));

	 cardno_org = cardno;
	 do i = 1 to hits;
	 	card = cats('Card',put(cardno_org + i,8.));
		cardno = cardno_org + i;
		output;
	 end;
	run;

	proc sql; 
	  create table cards_tmp2 as 
	    select a.card, a.cardno, a.cardno_org, b.hits from cards_tmp as a
		  inner join in as b
		  on a.cardno = b.cardno
	  ;
	quit;

	proc append base=newcards new=cards_tmp2;
	run;
 %end;
%mend;
%create_cards;

proc summary data=newcards nway missing;
 class card;
 var cardno;
 output out=_freq sum=;
run;

proc summary data=_freq(rename=(_freq_ = _numcards)) nway missing;
 var _numcards;
 output out=final sum=;
run;