data in specchar;
 length row $200;
 infile '/home/xxxx/dec3_in.txt';
 length part $5 startpos endpos x y _number 8; 

 input row;
_len=length(row);
 /* first find special chars */
 do x = 1 to length(row);
  specchar = substr(row,x,1);
  if not findc(specchar,'.0123456789') then do;
	y = _n_;
	output specchar; 
  end;
 end;

 /* now find numbers and their surrounging coordinates */
 i = 1;
 do while(scan(row,i,'.#$%&*+-/=@') ne '');
 	part = compress(scan(row,i,'.#$%&*+-/=@'),'=');
	part_no = cats('Part:',part,'_',put(_n_,8.));

	if findc(substr(part,1,1),'123456789') then do;
		_number = input(part,8.);

		startpos = findw(row,strip(part),'.#$%&*+-/=@ ');
		endpos = startpos + length(part) - 1;
		/* clean to be able to find 2 or more of the same number on the same row */
		do w = startpos to endpos; substr(row,w,1) = '!'; end;

		x = startpos - 1;
		y = _n_;
		output in;

		x = endpos + 1;
		y = _n_;
		output in;

		do a = startpos - 1 to endpos + 1;
			x = a;
			y = _n_ -1;
			output in;

			x = a;
			y = _n_ +1;
			output in;
		end;
	end;

	i + 1;
 end;

 run;

proc sql;
  create table bigjoin as
   select b._number, a.specchar, a.x, a.y,b.part_no from specchar as a
   inner join in as b
	on a.x = b.x
	and a.y = b.y
  order by y, x
  ;
quit;

proc summary data=bigjoin nway missing;
 var _number;
 output out=final sum=;
run;



