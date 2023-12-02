data in;
 length row $200;
 infile '/home/xxxx/dec2_in.txt' delimiter=':;';
 length game blue red green 8; 
 retain game;

 input row @@;
 if scan(row,1) = 'Game' then game = input(scan(row,2),best.);

 i = 1;
 do while(scan(row,i,',') ne '');
 	part = scan(row,i,',');
	if scan(part,2) = 'blue' then blue = input(scan(part,1),best.);
	if scan(part,2) = 'red' then red = input(scan(part,1),best.);
	if scan(part,2) = 'green' then green = input(scan(part,1),best.);
	i + 1;
 end;

 run;

proc summary data=in nway missing;
  class game;
  var blue red green;
  output out=out max=;
run;

/* only 12 red cubes, 13 green cubes, and 14 blue cubes */
data valid;
 set out;
 if 1<=red<=12 and 1<=green<=13 and 1<=blue<=14;
run;

proc summary data=valid nway missing;
 var game;
 output out=final sum=;
run;

/* part 2 */
data part2;
 set out;
 power = blue*red*green;
run;

proc summary data=part2 nway missing;
 var power;
 output out=final2 sum=;
run;