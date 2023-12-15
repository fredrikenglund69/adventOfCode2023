data indata;
 infile '/home/xxxx/dec15_in.txt' delimiter=',';

 length step $10 lbl $10 oper $1 foc len currval pos val 8 form pattern valstr $100;
 array boxes(256) $200;

 retain boxes;
 
 input step @@;

 len = length(step);
 lbl = scan(step,1,'=-');
 if countc(step,'-') then oper = '-';
 if countc(step,'=') then oper = '=';
 foc = input(substr(reverse(strip(step)),1,1),8.);
 if oper = '=' then form = cats('(',lbl,'_',foc,')');
 if oper = '-' then form = '';


 i = 1;
 currval = 0;
 do until (substr(lbl,i,1) = '');
 	currval = currval + rank(substr(lbl,i,1));
	currval = currval * 17;
	currval = mod(currval,256);
	*put currval=;
 	i + 1;
 end;
 currval + 1;

 pos=prxmatch(cats('/',lbl,'/'),boxes(currval));
 if pos = 0 and oper = '=' then boxes(currval) = cats(boxes(currval),form);
 else do;
	pattern= cats('s/\(',lbl,'_\d\)/');

 	if oper = '=' then do;
		boxes(currval) = compress(prxchange(cats(pattern,form,'/'),-1,boxes(currval)));
	end;
	else do;
		boxes(currval) = compress(prxchange(cats(pattern,'','/'),-1,boxes(currval)));
	end;
 end;

 if _n_ =4000 then do;
	tot = 0;
 	do z = 1 to 256;
		put boxes(z)=;
		a = 2;
		nu = 0;
		do until (scan(boxes(z),a,'_') = '');
			valstr = substr(scan(boxes(z),a,'_'),1,1);
			val = input(valstr,8.);
			if not missing(val) then nu + 1;
			tot = sum(tot, val * nu * z);
		put a= valstr= val= tot= nu=;
			a + 1;
		end;
	end;
 end;

run;

proc summary data=indata nway missing;
 var currval;
 output out=final sum=;
run;

/*
3640 - to low
Determine the ASCII code for the current character of the string.
Increase the current value by the ASCII code you just determined.
Set the current value to itself multiplied by 17.
Set the current value to the remainder of dividing itself by 256.
*/