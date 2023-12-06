data in;
 infile '/home/xxxx/dec4_in_test.txt' delimiter=';';

 length row winstr mystr $200 winpart mypart $3 score total 8;
 
 input row;
 retain total;

 winstr = scan(row,2,':|');
 mystr = scan(row,3,':|');

 score = 0;
 i = 1;
 do while (scan(mystr,i) ne '');
 	mypart = scan(mystr,i);

	o = 1;
 	do while (scan(winstr,o) ne '');
		winpart = scan(winstr,o);

		if mypart = winpart then do;
			if score = 0 then score = 1;
			else score = 2 * score;
		end;

		o + 1;
	end;

 	i + 1;
 end;

 total + score;

run;