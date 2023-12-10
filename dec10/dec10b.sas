%let gridsize = 140;
%let gridsize2 = %eval(&gridsize.*2);

data indata;
 length row $200 currposx currposy starty startx endy endx nextposx nextposy prevposx prevposy steps 8 currval $1;
 array pipes{&gridsize.,&gridsize.} $1;
 array thepipe{&gridsize.,&gridsize.} $1;
 array exppipex{&gridsize2.,&gridsize2.} $1;
 array exppipey{&gridsize2.,&gridsize2.} $1;

 infile '/home/xxxx/dec10_in.txt' end=done;
 retain pipes thepipe exppipe currposx currposy;

 input row;

 do i = 1 to &gridsize.;
	pipes{i,_n_} = substr(row,i,1);
	thepipe{i,_n_} = '.';

	if pipes{i,_n_} = 'S' then do;
	   	currposx = i;
		currposy = _n_;
	end;
 end;


 if done then do;
	 currval = '';
	 steps = 0;
	 thepipe{currposx,currposy} = 'S';
	 prevposx = 0; prevposy = 0;

	 do until (currval = 'S'); /* home again */

		 /* check surroundings */
		 if currposx = 1 then startx = currposx; else startx=currposx - 1;
		 if currposx = &gridsize. then endx = currposx; else endx = currposx + 1;
		 if currposy = 1 then starty = currposy; else starty = currposy - 1;
		 if currposy = &gridsize. then endy = currposy; else endy = currposy + 1;

		 nextposx = 0; nextposy = 0;

		 do y = starty to endy;
		 	do x = startx to endx;
				*put pipes(x,y);

				/* if current position is not previous position */
				if not (x = prevposx and y = prevposy) then do;
	 
					/* check up */
					if nextposx = 0 and x = currposx and y = currposy - 1 and currval in ('','|','L','J') and pipes(x,y) in ('S','|','7','F') then do;
						nextposy = y;
						nextposx = x; 
					end;
					/* check down */
					if nextposx = 0 and x = currposx and y = currposy + 1 and currval in ('','|','7','F') and pipes(x,y) in ('S','|','L','J') then do;
						nextposy = y;
						nextposx = x; 
					end;
					/* check left */
					if nextposx = 0 and x = currposx - 1 and y = currposy and currval in ('','-','7','J') and pipes(x,y) in ('S','-','L','F')  then do;
						nextposy = y;
						nextposx = x; 
					end;
					/* check right */
					if nextposx = 0 and x = currposx + 1 and y = currposy and currval in ('','-','L','F') and pipes(x,y) in ('S','-','7','J') then do;
						nextposy = y;
						nextposx = x; 
					end;
				end;
			end;
		 end; /* check surroundings */

		 *put currposx= currposy= prevposx= prevposy= nextposx= nextposy= x= y=;


		 prevposx = currposx;
		 prevposy = currposy;
		 if steps ne 0 then thepipe(currposx,currposy) = currval;

		 currval = pipes(nextposx,nextposy);
		 currposx = nextposx;
		 currposy = nextposy;

		 output;

		 steps + 1;

	end; /* do until*/

	do y1 = 1 to &gridsize.;
	 	do x1 = 1 to &gridsize.;
			put thepipe(x1,y1) @@;
		end;
		put '0a'x;
	end;


	/* expand matrix in x */
	do y = 1 to &gridsize;	
		do x = 1 to &gridsize.;
			exppipex(x*2-1,y) = thepipe(x,y);
			if thepipe(x,y) in ('S','-','L','F') then exppipex(x*2,y) = '-';
			else exppipex(x*2,y) = ' ';
		end;
	end;


	/* expand matrix in y */
	do y = 1 to &gridsize.;	
		do x = 1 to &gridsize2.;
			exppipey(x,y*2-1) = exppipex(x,y);
			if exppipex(x,y) in ('S','|','7','F') then exppipey(x,y*2) = '|';
			else exppipey(x,y*2) = ' ';
		end;
	end;


	%macro printgrid;
		put '*** Grid as for now: ';
		do y1 = 1 to &gridsize2.;
		 	do x1 = 1 to &gridsize2.;
				put exppipey(x1,y1) @@;
			end;
			put '0a'x;
		end;
	%mend;
	%*printgrid;

	/* mark all . in the border as not in loop # */
	do y1 = 1 to &gridsize2.;
	 	do x1 = 1 to &gridsize2.;
			if (x1=1 or x1=&gridsize2. or y1 = 1 or y1 = &gridsize2.) and exppipey(x1,y1) in ('.',' ') then exppipey(x1,y1) = '#';
		end;
	end;

	%*printgrid;

	/* loop until all # has been evaluated and set to ! */
	nohash = 'N';

	do until(nohash = 'Y');
		nohash = 'Y';
		/* Now loop grid and set all surrounding empty cells to #, mark self as ! when done */
		do y1 = 1 to &gridsize2.;
		 	do x1 = 1 to &gridsize2.;
				if exppipey(x1,y1) = '#' then do;

					 nohash = 'N';

					 /* check surroundings */
					 if x1 = 1 then startx = 1; else startx = x1 - 1;
					 if x1 = &gridsize2. then endx = x1; else endx = x1 + 1;
					 if y1 = 1 then starty = y1; else starty = y1 - 1;
					 if y1 = &gridsize2. then endy = y1; else endy = y1 + 1;

					 do y = starty to endy;
					 	do x = startx to endx;
							/* check up */
							if exppipey(x,y) in ('.',' ') then exppipey(x,y) = '#';
						end;
					 end; /* check surroundings */

					 exppipey(x1,y1) = '!';

				end;
			end;

		end;

		%*printgrid;
	end; /* nohash = Y*/

	/* now count . */
	nodots = 0;
	do y1 = 1 to &gridsize2.;
	 	do x1 = 1 to &gridsize2.;
			if exppipey(x1,y1) = '.' then nodots + 1;
		end;
	end;

	put 'Number of dots or enclosed cells ny loop:' nodots;


 end; /* _n_ = gridsize */


run;


/*
|
-
L
J
7
F


 if _n_ = 5 then do;
	 do y = 1 to 5;
	 	do x = 1 to 5;
		end;
		put '0a'x;
	 end;
 end;

 */
