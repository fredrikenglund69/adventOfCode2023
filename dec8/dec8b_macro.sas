%global noelem steps;

data in;
 infile '/home/xxxx/dec8_in.txt' delimiter=';';

 length row $300 element $3 choice $7;
 
 input row;
 if _n_ = 1 then do;
 	call symput('instruct',row);
 end;
 else do;
  	element = scan(row,1);
	choice = tranwrd(compress(scan(row,2,'(')),',','|');
	call symputx(cats('_',element), choice,G);
 end;
 run;
%put Length of instructions: %length(&instruct.);

proc sql;
 select element into :nexts separated by '|' 
 from in
 where substr(element,3,1) = 'A';
quit;
%put &nexts.;
 
%macro a;
	%let i = 1;
	%let elem = %scan(&nexts.,&i.,|);
	%do %while(&elem ne );
		%global next&i.;
		%let next&i. = &elem;
		%let i = %eval(&i. + 1);
		%let elem = %scan(&nexts.,&i.,|);
	%end;
	%let noelem = %eval(&i. - 1);
%mend;
%a;
%put Number of elements: &noelem.;

options nomprint nomlogic nosymbolgen;
%macro calc;
	%let done = N;
	%let inspos = 1;
	%let steps = 1;
	%do %until(&done. = Y);
		%if &inspos. = %eval(%length(&instruct.) + 1) %then %let inspos = 1;
		%let dir = %substr(&instruct.,&inspos.,1);
/*		%if &dir. = %then %do;*/
/*			%let inspos = 1;*/
/*			%let dir = %substr(&instruct.,&inspos.,1);*/
/*		%end;*/

		%if &dir. = L %then %let dirn = 1;
		%else %let dirn = 2;

		%*put ************************;
		%*put dir    : &dir.;
		%*put steps  : &steps.;
		%*put inspos : &inspos.;

		%let allZ = ;
		%do x = 1 %to &noelem.;
			%let _tmp = _&&next&x.;
			%let next&x. = %scan(&&&_tmp.,&dirn.,|);
			%*put &_tmp -> &&next&x.;
			%if %substr(&&next&x.,3,1) = Z and &allZ. ne N %then %let allZ = Y;
			%else %let allZ = N;
			%*put allZ: &allZ.;
		%end;

		%let inspos = %eval(&inspos. + 1);
		%let steps = %eval(&steps. + 1);

		%if &allZ = Y %then %let done = Y;
	%end;
%mend;
%calc;

%put Totalt antal steg: %eval(&steps. - 1);