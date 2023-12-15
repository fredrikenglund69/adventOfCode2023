data indata;
 infile '/home/xxxx/dec15_in.txt' delimiter=',';

 length step $10 ;
 
 input step @@;

 i = 1;
 currval = 0;
 do until (substr(step,i,1) = '');
 	currval = currval + rank(substr(step,i,1));
	currval = currval * 17;
	currval = mod(currval,256);
	put currval=;
 	i + 1;
 end;

run;

proc summary data=indata nway missing;
 var currval;
 output out=final sum=;
run;

/*
Determine the ASCII code for the current character of the string.
Increase the current value by the ASCII code you just determined.
Set the current value to itself multiplied by 17.
Set the current value to the remainder of dividing itself by 256.
*/