%let gridsize = 110;

%macro printgrid(grid=grid);
	put '*** Grid as for now: ';
	do yp = 1 to dim(&grid.);
	 	do xp = 1 to dim(&grid.);
			put &grid.(xp,yp) @@;
		end;
		put '0a'x;
	end;
%mend;

%macro add_trail(x=,Y=,d=);
	lasttrail + 1;
	paths(lasttrail) = paths(currtrail);
	trails(lasttrail) = cats('O,',put(&x.,8.),',',put(&y.,8.),",&d");
%mend;


data indata(drop= grid: paths: visits: trails:);
 infile '/home/kfen01/dec16_in.txt' delimiter=',';

 length row $&gridsize. tile dir $1 xpos ypos currtrail lasttrail 8;
 array grid(&gridsize., &gridsize.) $1;
 array paths(10000) $1000;
 array visits(&gridsize., &gridsize.) $4; /* UDRL */
 array trails(10000) $32; /*x,y,dir,done*/
 array finale(&gridsize., &gridsize.) 8;

 retain grid visits;
 
 input row;

 /* read grid and populate array */
 do i = 1 to input("&gridsize.",8.);
 	grid(i,_n_) = substr(row,i,1);
	visits(i,_n_) = '....';
 end;

 if _n_ = 110 then do;
 	currtrail = 1;
	lasttrail = 1;
/* 	trails(1) = '1,2,D';*/
 	trails(currtrail) = 'O,1,1,R';
	done = 0;

	do until (currtrail > lasttrail);
		xpos= input(scan(trails(currtrail),2),8.); 
		ypos= input(scan(trails(currtrail),3),8.); 
		dir= scan(trails(currtrail),4); 
		tile = grid(xpos,ypos);
		bit = indexc('UDRL',dir);
		if substr(visits(xpos,ypos),bit,1) = '1' then done = 1;
		else do;
			substr(visits(xpos,ypos),bit,1) = '1';
		end;

		paths(currtrail) = cats(paths(currtrail),put(xpos,8.),',',put(ypos,8.),'|');
/*		put xpos= ypos= tile= trails(currtrail)=  paths(currtrail)= visits(xpos,ypos)= currtrail= bit=;*/


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
			else if ypos = input("&gridsize.",8.) then dir = 'U';
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
			substr(trails(currtrail),1,1) = 'C';
			currtrail + 1;
			done = 0;
		end;
		else trails(currtrail) = cats('O,',put(xpos,8.),',',put(ypos,8.),',',dir);
	end;


 /* count visits */
	novisits = 0;
	do yp = 1 to &gridsize.;
	 	do xp = 1 to &gridsize.;
			if countc(visits(xp,yp), '1') then do;
				novisits + 1;
				if grid(xp,yp) = '.' then finale(xp,yp) = put(countc(visits(xp,yp),'1'),8.);
				else finale(xp,yp) = 1;
			end;
		end;
	end;

%printgrid(grid=finale);

   put 'Antal besök:' novisits= lasttrail=;
 end;

run;


/*
3629 - to low
6257 - to low
8479 - to high
8079 - wrong
8029 - wrong
6786 - wrong
7979 - correct!!!!!!

*/