%macro _loop(_offset=0, _chunk=100);
data seeds(keep=seedfr seedto seedrng seed) rules(keep=_dest _source _range _destto _sourceto type);
 length row $500 _dest _source _range _destto _sourceto seedfr seedrng seed 8;
 infile '/home/xxxx/dec5_in.txt' delimiter= '0a'x;

 input row;

 retain type;

 if scan(row,1,':') = 'seeds' then do;
 	i = 2;
 	do while(scan(row,i,': ') ne '');
		seedfr = input(scan(row,i,': '),12.);
		i + 1;
		seedrng = input(scan(row,i,': '),12.);
		seedto = seedfr + seedrng - 1;
		do q = seedfr + &_offset to seedfr + &_offset + &_chunk;
			if q le seedto then do;
				seed = q;
				output seeds;
			end;
			else leave;
		end;
		i + 1;
	end;
 end;
 else do;
 	if not findc(substr(row	,1,1),'0123456789') then do;
		type = scan(row,1,': ');
	end;
	else do;
		_dest = input(scan(row,1),12.);
		_source = input(scan(row,2),12.);
		_range = input(scan(row,3),12.);
		_sourceto = _source + _range - 1;
		_destto = _dest + _range - 1; 
		output rules;
	end;
 end;
run;


/* SOILS */
proc sql;
 create table _join as 
  select a.*, b.* from seeds as a
  left join rules as b
  on a.seed between b._source and b._sourceto
  and b.type in ('seed-to-soil','')
 ;
quit;

data soils;
 set _join;
 length soil 8;

 if not missing(_source) then soil = seed - _source + _dest;
 else soil = seed;

run;

/* FERTILIZERS */
proc sql;
 create table _join as 
  select a.seed, a.soil, b.* from soils as a
  left join rules as b
  on a.soil between b._source and b._sourceto
  and b.type in ('soil-to-fertilizer','')
 ;
quit;

data ferts;
 set _join;
 length fert 8;

 if not missing(_source) then fert = soil - _source + _dest;
 else fert = soil;

run;

/* WATERS */
proc sql;
 create table _join as 
  select a.seed, a.soil,a.fert, b.* from ferts as a
  left join rules as b
  on a.fert between b._source and b._sourceto
  and b.type in ('fertilizer-to-water','')
 ;
quit;

data waters;
 set _join;
 length water 8;

 if not missing(_source) then water = fert - _source + _dest;
 else water = fert;

run;

/* LIGHTS */
proc sql;
 create table _join as 
  select a.seed, a.soil,a.fert,a.water, b.* from waters as a
  left join rules as b
  on a.water between b._source and b._sourceto
  and b.type in ('water-to-light','')
 ;
quit;

data lights;
 set _join;
 length light 8;

 if not missing(_source) then light = water - _source + _dest;
 else light = water;

run;

/* TEMPERATURES */
proc sql;
 create table _join as 
  select a.seed, a.soil,a.fert,a.water,a.light, b.* from lights as a
  left join rules as b
  on a.light between b._source and b._sourceto
  and b.type in ('light-to-temperature','')
 ;
quit;

data temps;
 set _join;
 length temp 8;

 if not missing(_source) then temp = light - _source + _dest;
 else temp = light;

run;

/* HUMIDITIES */
proc sql;
 create table _join as 
  select a.seed, a.soil,a.fert,a.water,a.light,a.temp, b.* from temps as a
  left join rules as b
  on a.temp between b._source and b._sourceto
  and b.type in ('temperature-to-humidity','')
 ;
quit;

data humids;
 set _join;
 length humid 8;

 if not missing(_source) then humid = temp - _source + _dest;
 else humid = temp;

run;

/* LOCATIONS */
proc sql;
 create table _join as 
  select a.seed, a.soil,a.fert,a.water,a.light,a.temp,a.humid, b.* from humids as a
  left join rules as b
  on a.humid between b._source and b._sourceto
  and b.type in ('humidity-to-location','')
 ;
quit;

data locs;
 set _join;
 length loc 8;

 if not missing(_source) then loc = humid - _source + _dest;
 else loc = humid;

run;

proc sql;
 create table _min_part as 
  select min(loc) from locs
  where loc ne 0
  ;
quit;

proc append base=_min new=_min_part;
run;
%mend _loop;

proc sql;
 drop table _min;
quit;

%macro _run;
 %let chunk = 100000;
 %let numloops = 5500;
/* %let chunk = 10;*/
/* %let numloops = 1;*/

 %do a = 1 %to &numloops;
 	%put ********************************************************************************************;
    %put *** LOOP(&a) av &numloops;
 	%put ********************************************************************************************;
 	%let off = %eval(%eval(&a - 1) * &chunk);
	%_loop(_offset=&off, _chunk=&chunk);
 %end;
%mend;
%_run;

proc sort data=_min out=itlag._fen_min_;
 by _temg001;
run;

/*
%_loop(_offset=0, _chunk=100);
%_loop(_offset=100, _chunk=100);
%_loop(_offset=200, _chunk=100);
*/