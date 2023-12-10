%let gridsize = 140;
data indata;
 length row $200 currposx currposy starty startx endy endx nextposx nextposy prevposx prevposy steps 8 currval $1;
 array pipes{&gridsize.,&gridsize.} $1;
 infile '/home/xxxx/dec10_in.txt';
 retain pipes currposx currposy;

 input row;

 do i = 1 to &gridsize.;
	pipes{i,_n_} = substr(row,i,1);

	if pipes{i,_n_} = 'S' then do;
	   	currposx = i;
		currposy = _n_;
	end;
 end;


 if _n_ = &gridsize. then do;
	 currval = '';
	 steps = 0;
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

		 currval = pipes(nextposx,nextposy);
		 currposx = nextposx;
		 currposy = nextposy;

		 output;

		 steps + 1;

	end; /* do until*/

	farthest = steps / 2;
 	put farthest=;

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
