%let gridsize = 10;

%macro printgrid(grid=grid);
	put '*** Grid as for now: ';
	do yp = 1 to dim(&grid.);
	 	do xp = 1 to dim(&grid.);
			put &grid.(xp,yp) @@;
		end;
		put '0a'x;
	end;
%mend;

%macro trim_trails();
 do t = 2 to 10000;
 	if trails(t-1) = '' and trails(t) ne '' then do;
		trails(t-1) = trails(t);
		trails(t) = '';
		lasttrail = t;
	end;
 end;
%mend;

%macro add_trail(x=,Y=,d=);
	trails(lasttrail) = cats(put(&x.,8.),',',put(&y.,8.),",&d");
	lasttrail + 1;
%mend;

%macro new_path();
	do p = 1 to 10000;
		path(p) = '';
	end;
	pathno = 1;
%mend;

%macro xy_in_path(px=,py=);
	do p = 1 to 5;
		tx= input(scan(path(p),1),8.);
		ty= input(scan(path(p),2),8.);

		if tx = &px. and ty = &py. then done = 1;
	put tx= ty= &px. &py. done= path(1)= path(2)= path(3)=;
	end;
%mend;


data indata(drop= grid: path: visits: trails:);
 infile '/home/xxxx/dec16_in_test.txt' delimiter=',';

 length row $&gridsize. tile dir $1 xpos ypos lasttrail pathno 8;
 array grid(&gridsize., &gridsize.) $1;
 array path(10000) $8;
 array visits(&gridsize., &gridsize.) 8;
 array trails(10000) $32;

 retain grid;
 
 input row;

 /* read grid and populate array */
 do i = 1 to input("&gridsize.",8.);
 	grid(i,_n_) = substr(row,i,1);
 end;

 if _n_ = &gridsize. then do;
/* 	trails(1) = '1,2,D';*/
 	trails(1) = '2,1,R';
	done = 0;
	lasttrail = 2;
	dir = 'D';
	visits(1,1) = 1;
	pathno = 1;
	path(pathno) = '1,1';

	do until (trails(1) = '' or lasttrail = 1000);
		xpos= input(scan(trails(1),1),8.); 
		ypos= input(scan(trails(1),2),8.); 
		tile = grid(xpos,ypos);
		dir= scan(trails(1),3); 
		visits(xpos,ypos) = max(0,visits(xpos,ypos)) + 1;
		put xpos= ypos= path(1)= path(2)= path(3)=;
		%xy_in_path(px=xpos, py=ypos);
		pathno + 1;
		path(pathno) = cats(scan(trails(1),1),',',scan(trails(1),2));
		put xpos= ypos= tile= dir= trails(1)= pathno= path(pathno)=;


		if tile = '/' then do;
			if dir = 'R' then dir = 'U';
			else if dir = 'L' then dir = 'D';
			else if dir = 'U' then dir = 'R';
			else if dir = 'D' then dir = 'L';
		end;

		if tile = '\' then do;
			if dir = 'R' then dir = 'D';
			else if dir = 'L' then dir = 'U';
			else if dir = 'U' then dir = 'L';
			else if dir = 'D' then dir = 'R';
		end;

		if tile = '|' and dir in ('R','L') then do;
			if ypos = 1 then dir = 'D';
			else if ypos = input(&gridsize.,8.) then dir = 'D';
			else do;
				%add_trail(x=xpos,y=ypos+1,d=D);
				dir = 'U';
			end;
		end;

		if tile = '-' and dir in ('U','D') then do;
			if xpos = 1 then dir = 'R';
			else if xpos = input("&gridsize.",8.) then dir = 'L';
			else do;
				%add_trail(x=xpos+1,y=ypos,d=R);
				dir = 'L';
			end;
		end;


		if dir = 'U'  then do;
			if ypos ne 1 then ypos=ypos-1;
			else done = 1;
		end;
		if dir = 'D'  then do;
			if ypos ne &gridsize. then ypos=ypos+1;
			else done = 1;
		end;
		if dir = 'L'  then do;
			if xpos ne 1 then xpos=xpos-1;
			else done = 1;
		end;
		if dir = 'R'  then do;
			if xpos ne &gridsize. then xpos=xpos+1;
			else done = 1;
		end;

		if done then do;
			trails(1) = '';
			%trim_trails;
			%new_path;
			done = 0;
		end;
		else trails(1) = cats(put(xpos,8.),',',put(ypos,8.),',',dir);
		put xpos= ypos= tile= trails(1)= trails(2)= trails(3)=;
	end;
%printgrid(grid=visits);

 /* count visits */
	novisits = 0;
	do yp = 1 to &gridsize.;
	 	do xp = 1 to &gridsize.;
			if visits(xp,yp) = 1 then novisits + 1;
		end;
	end;
 end;

 put 'Antal besök:' novisits= lasttrail=;
run;


/*
3629 - to low
6257 - to low

*/
