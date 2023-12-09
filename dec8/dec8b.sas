/* Testar en comment */
data in;
 infile '/home/xxxx/dec8_in.txt' delimiter=';';

 length row $300 element $3 choice $7;
 
 input row;
 if _n_ = 1 then do;
 	call symput('instruct',row);
 end;
 else do;
 	element = scan(row,1);
	choice = compress(scan(row,2,'('));
 end;
 run;

 proc transpose data=in(where=(element ne '')) out=trans;
  id element;
  var choice;
run;

proc sql;
 select element into :nexts separated by ' ' 
 from in
 where substr(element,3,1) = 'A';
quit;
%put &nexts.;
 
data final;
 set trans;
 length dir $1 insval $2 next1 - next6 $3 inspos steps 8;
 insval = 'LR';
 inspos = 1;
 steps = 1;
 done = 'N';
 next1 = 'BBA';
 next2 = 'BLA';
 next3 = 'AAA';
 next4 = 'NFA';
 next5 = 'DRA';
 next6 = 'PSA';

 do until(done = 'Y');
 	dir = indexc(insval,substr("&instruct.",inspos,1));
	if dir = 0 then do;
		inspos = 1;
	 	dir = indexc(insval,substr("&instruct.",inspos,1));
	end;

	next1 = scan(vvaluex(next1),dir);
	next2 = scan(vvaluex(next2),dir);
	next3 = scan(vvaluex(next3),dir);
	next4 = scan(vvaluex(next4),dir);
	next5 = scan(vvaluex(next5),dir);
	next6 = scan(vvaluex(next6),dir);
	if substr(next1,3,1) = 'Z'
	and substr(next2,3,1) = 'Z'
	and substr(next3,3,1) = 'Z'
	and substr(next4,3,1) = 'Z'
	and substr(next5,3,1) = 'Z'
	and substr(next6,3,1) = 'Z'
	then done = 'Y';
	*output;
	inspos + 1;
	steps + 1;
 end;
run;