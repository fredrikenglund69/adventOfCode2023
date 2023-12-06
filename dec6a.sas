data in;
 length row $200 time1 time2 time3 time4 dist1 dist2 dist3 dist4 8;
 file datalines delimiter='#';

 input row;

 retain time1 time2 time3 time4;

 if _n_ = 1 then do;
 	time1 = scan(row,2);
	time2 = scan(row,3);
 	time3 = scan(row,4);
	time4 = scan(row,5);
 end;

 if _n_ = 2 then do;
 	dist1 = scan(row,2);
	dist2 = scan(row,3);
 	dist3 = scan(row,4);
	dist4 = scan(row,5);
	output;
 end;

datalines;
 Time:        46     80     78     66
Distance:   214   1177   1402   1024
;
run;

%macro calc_race(raceno);
 do i = 1 to time&raceno.;
   speed&raceno. = i * 1;
   race&raceno. = dist&raceno. - speed&raceno.*(time&raceno.-i);
   if race&raceno. < 0 then hit&raceno. + 1;
   hits = hit&raceno.;
   if i = time&raceno. then output;
 end;
%mend;

data out;
 set in;
 length hits hit1 hit2 hit3 hit4 8;

 %calc_race(1);
 %calc_race(2);
 %calc_race(3);
 %calc_race(4);

run;

 /*
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