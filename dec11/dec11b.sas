%let gridsize = 140;
%let gridsize2 = %eval(&gridsize.*2);
%let gridsizexy = %eval(&gridsize.*&gridsize.);
%let expand = 999999;

%macro printgrid(grid=gridnewx);
	put '*** Grid as for now: ';
	do yp = 1 to dim(&grid.);
	 	do xp = 1 to dim(&grid.);
			put &grid.(xp,yp) @@;
		end;
		put '0a'x;
	end;
%mend;
%*printgrid;

data indata(drop=dashes: grid: spacex: spacey:);
 infile '/home/xxxx/dec11_in.txt' end=done;

 length row $200 dashno _fromx _fromy _tox _toy _distx _disty _dist 8;
 array dashes{&gridsizexy.} $10;
 array gridorg{&gridsize.,&gridsize.} $1;
 array spacex{&gridsize.} 8;
 array spacey{&gridsize.} 8;

 retain dashes dashno gridorg;

 input row;

 if _n_ = 1 then dashno = 1;

 /* read grid and populate array */
 do i = 1 to length(row);
 	gridorg(i,_n_) = substr(row,i,1);
 end;

 if done then do;
 	%printgrid(grid=gridorg);

	/* find missing y-rows */
 	y2 = 1;
 	do y = 1 to &gridsize.;
		finddash = 0;
		do x = 1 to dim(gridorg);
			if gridorg(x,y) = '#' then finddash = 1;
		end;

		if not finddash then do;
			spacey(y2) = y;
			y2 + 1;
		end;
	end;

	/* find missing x-cols */
 	x2 = 1;
 	do x = 1 to dim(gridorg);
		finddash = 0;
		do y = 1 to dim(gridorg);
			if gridorg(x,y) = '#' then finddash = 1;
		end;

		if not finddash then do;
			spacex(x2) = x;
			x2 + 1;
		end;
	end;


	put 'Missing # in y-row:';
	do q = 1 to dim(spacey);
		put spacey(q) ',' @@;
	end;

	put 'Missing # in x-col:';
	do q = 1 to dim(spacex);
		put spacex(q) ',' @@;
	end;

	/* find dashes */
	dashno = 0;
	do y = 1 to dim(gridorg);
		do x = 1 to dim(gridorg);
			if gridorg(x,y) = '#' then do;
				dashno + 1;
				dashes(dashno) = cats(put(x,8.),'|',put(y,8.));
			end;
		end;
	end;

 	do _from = 1 to dashno;
		do _to = 1 to dashno;
			_fromx = input(scan(dashes(_from),1,'|'),8.);
			_fromy = input(scan(dashes(_from),2,'|'),8.);
			_tox = input(scan(dashes(_to),1,'|'),8.);
			_toy = input(scan(dashes(_to),2,'|'),8.);

			/* check if expanding space is between from and to */
			nospacex = 0;
			do q = 1 to dim(spacex);
				if min(_fromx,_tox) < spacex(q) < max(_fromx,_tox) then nospacex + 1;
			end;

			nospacey = 0;
			do q = 1 to dim(spacey);
				if min(_fromy,_tomy) < spacey(q) < max(_fromy,_toy) then nospacey + 1;
			end;

			_distx = abs(_fromx - _tox) + nospacex * &expand.;
			_disty = abs(_fromy - _toy) + nospacey * &expand.;
			_dist  = _distx + _disty;
			if _from ne _to then output;
		end;
	end;
 end;
run;

data trim;
 set indata;
 length _fromlow _tohigh 8;

 _fromlow = min(_from,_to);
 _tohigh = max(_from,_to);
run;

proc sort data=trim out=sort nodupkey;
 by _fromlow _tohigh;
run;

proc summary data=sort nway missing;
 var _dist;
 output out=final sum=;
run;

