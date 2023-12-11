%let gridsize = 140;
%let gridsize2 = %eval(&gridsize.*2);
%let gridsizexy = %eval(&gridsize.*&gridsize.);

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

data indata(drop=dashes: gridorg: gridnewy: gridnewx:);
 infile '/home/xxxx/dec11_in.txt' end=done;

 length row $200 dashno _fromx _fromy _tox _toy _distx _disty _dist 8;
 array dashes{&gridsizexy.} $10;
 array gridorg{&gridsize.,&gridsize.} $1;
 array gridnewy{&gridsize2.,&gridsize2.} $1;
 array gridnewx{&gridsize2.,&gridsize2.} $1;

 retain dashes dashno gridorg;

 input row;

 if _n_ = 1 then dashno = 1;

 /* read grid and populate array */
 do i = 1 to length(row);
 	gridorg(i,_n_) = substr(row,i,1);
 end;

 if done then do;
 	%*printgrid(grid=gridorg);

	/* expand grid in y */
 	y2 = 1;
 	do y = 1 to &gridsize.;
		finddash = 0;
		do x = 1 to dim(gridorg);
			gridnewy(x,y2) = gridorg(x,y);
			if gridorg(x,y) = '#' then finddash = 1;
		end;

		if not finddash then do;
			y2 + 1;

			do x = 1 to &gridsize.;
				gridnewy(x,y2) = gridorg(x,y);
			end;
		end;

		y2 + 1;
	end;

	%*printgrid(grid=gridnewy);

	/* expand grid in x */
 	x2 = 1;
 	do x = 1 to dim(gridorg);
		finddash = 0;
		do y = 1 to y2 - 1;
			gridnewx(x2,y) = gridnewy(x,y);
			if gridnewy(x,y) = '#' then finddash = 1;
		end;

		if not finddash then do;
			x2 + 1;
			do y = 1 to y2 - 1;
				gridnewx(x2,y) = gridnewy(x,y);
			end;
		end;

		x2 + 1;
	end;

	%*printgrid(grid=gridnewx);

	/* find dashes */
	dashno = 0;
	do y = 1 to dim(gridnewx);
		do x = 1 to dim(gridnewx);
			if gridnewx(x,y) = '#' then do;
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
			_distx = abs(_fromx - _tox);
			_disty = abs(_fromy - _toy);
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

