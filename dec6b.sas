data in;
 length row $200 time1 dist1 8;
 file datalines delimiter='#';

 input row;

 retain time1;

 if _n_ = 1 then time1 = scan(row,2);

 if _n_ = 2 then do;
	dist1 = scan(row,2);
	output;
 end;

datalines;
Time:        46807866
Distance:   214117714021024
;
run;

data out;
 set in;
 length hits hit1 8;
 do i = 1 to time1;
   speed1 = i * 1;
   race1 = dist1 - speed1*(time1-i);
   if race1 <= 0 then hit1 + 1;
   if i = time1 then output;
 end;
run;

 /*
Time:      71530
Distance:  940200

Time:        46807866
Distance:   214117714021024

Time:        46     80     78     66
Distance:   214   1177   1402   1024

Time:      7  15   30 0
Distance:  9  40  200 0

 do i = 1 to time1;
   speed1 = i * 1;
   race1 = dist1 - speed1*(time1-i);
   if race1 <= 0 then hit1 + 1;
   output;
 end;

*/