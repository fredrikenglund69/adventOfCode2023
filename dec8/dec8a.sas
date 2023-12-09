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
  
%put &instruct.;

data final;
 set trans;
 length dir $1 insval $2 next $3 inspos steps 8;
 insval = 'LR';
 inspos = 1;
 next = 'AAA';
 steps = 1;

 do until(next = 'ZZZ');
 	dir = indexc(insval,substr("&instruct.",inspos,1));
	if dir = 0 then do;
		inspos = 1;
	 	dir = indexc(insval,substr("&instruct.",inspos,1));
	end;

	next = scan(vvaluex(next),dir);
	output;
	inspos + 1;
	steps + 1;
 end;
run;