data in;
 infile '/home/xxxx/dec9_in.txt' delimiter=';';

 length row $300;
 array nums[25] 8;
 array _first[25] 8;
 array last[25] 8;
 array space[25] 8;

 input row;

 i = 1;
 do until(scan(row,i,' ') = '');
 	nums(i) = scan(row,i,' ');
 	i + 1;
 end;

 last(1) = nums(i-1);
 _first(1) = nums(1);
 put 'First:' _first(1) ' Last1:' last(1);

 loop = 0;
 do until(all0 = 'Y' or loop = 25);
	 all0 = '';
	 do x = 1 to (i - 2 - loop);
	 	space(x) = nums(x+1) - nums(x);
		if space(x) = 0 and all0 ne 'N' then all0 = 'Y';
		else all0 = 'N';
	 end;
	 _first(2+loop) = space(1);
	 last(2+loop) = space(x-1);
	 do z = 1 to (i - 1);
	 	if z < (i - 1 - loop) then nums(z) = space(z);
		else nums(z) = .;
		space(z) = .;
	 end;
	loop + 1;
 end;

 nextnum = 0;
 do q = 1 to (i - 1) ;
	nextnum = sum(nextnum,last(q));
 end;

 do w = loop to 1 by -1 ;
	if w = loop then prevnum = _first(loop);
	else prevnum = sum(_first(w), -prevnum);
 end;
run;

proc summary data=in nway missing;
 var nextnum prevnum;
 output out=final sum=;
run;

 /*
 ta ut mellanrum, spar sista talet och spara
fortsätt till alla är 0
 lägg på talen upp i ledet, spara sista värdet

1568124204 - to low
1581679977 - correct

second:
-1979 - wrong
889 - correct
 */