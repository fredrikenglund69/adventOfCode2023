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
 create view soils as 
  select a.*
		, case 
			when(not missing(_source)) then (seed - _source + _dest)
			else seed
		  end 
		as soil 
  from seeds as a

  left join rules as b
  on a.seed between b._source and b._sourceto
  and b.type in ('seed-to-soil','')
 ;
quit;


/* FERTILIZERS */
proc sql;
 create view ferts as 
  select a.seed, a.soil
		, case 
			when(not missing(_source)) then (soil - _source + _dest)
			else soil
		  end 
		as fert 
  from soils as a

  left join rules as b
  on a.soil between b._source and b._sourceto
  and b.type in ('soil-to-fertilizer','')
 ;
quit;


/* WATERS */
proc sql;
 create view waters as 
  select a.seed, a.soil,a.fert
		, case 
			when(not missing(_source)) then (fert - _source + _dest)
			else fert
		  end 
		as water 
  from ferts as a
  left join rules as b
  on a.fert between b._source and b._sourceto
  and b.type in ('fertilizer-to-water','')
 ;
quit;


/* LIGHTS */
proc sql;
 create view lights as 
  select a.seed, a.soil,a.fert,a.water
		, case 
			when(not missing(_source)) then (water - _source + _dest)
			else water
		  end 
		as light 

  from waters as a
  left join rules as b
  on a.water between b._source and b._sourceto
  and b.type in ('water-to-light','')
 ;
quit;


/* TEMPERATURES */
proc sql;
 create view temps as 
  select a.seed, a.soil,a.fert,a.water,a.light
		, case 
			when(not missing(_source)) then (light - _source + _dest)
			else light
		  end 
		as temp 

  from lights as a
  left join rules as b
  on a.light between b._source and b._sourceto
  and b.type in ('light-to-temperature','')
 ;
quit;



/* HUMIDITIES */
proc sql;
 create view humids as 
  select a.seed, a.soil,a.fert,a.water,a.light,a.temp
		, case 
			when(not missing(_source)) then (temp - _source + _dest)
			else temp
		  end 
		as humid 

  from temps as a
  left join rules as b
  on a.temp between b._source and b._sourceto
  and b.type in ('temperature-to-humidity','')
 ;
quit;


/* LOCATIONS */
proc sql;
 create view locs as 
  select a.seed, a.soil,a.fert,a.water,a.light,a.temp,a.humid
		, case 
			when(not missing(_source)) then (humid - _source + _dest)
			else humid
		  end 
		as loc 

  from humids as a
  left join rules as b
  on a.humid between b._source and b._sourceto
  and b.type in ('humidity-to-location','')
 ;
quit;


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
 %let chunk = 10000000;
/* %let numloops = 5;*/
/* %let numloops = 5500;*/
/* %let chunk = 100;*/
 %let numloops = 50;

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
31635041 - högt
24261545 -
%_loop(_offset=0, _chunk=100);
%_loop(_offset=100, _chunk=100);
%_loop(_offset=200, _chunk=100);
*/