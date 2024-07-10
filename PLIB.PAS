unit plib;
interface
uses crt,lib,dos;
const
	menupath:string[25]='IMS-PM';
type
	headtype = array[1..8] of string[10];
const
	HN:integer=5;
	on='On ';
	off='Off';
	sbset:string[3]=on;
	wset:string[3]=on;
var
        head:headtype;
	lasto:array[1..6] of integer;


PROCEDURE hpix(t,l,r:integer; head:headtype; var opt:integer;var hpixcode:char);
PROCEDURE save;
PROCEDURE setinpfile;
PROCEDURE setoutfile;
PROCEDURE setinsfile;
PROCEDURE bottombar;
PROCEDURE sideborder;
implementation
PROCEDURE bottombar;
var
	hour,min,sec,sec100:word;
	year,month,day,dayofweek:word;
	pathstr:string;
begin
if sbset=on then
	begin
{
		gotoxy(1,25);
		video(reversed);
                getdir(0,pathstr);
                fastwrite(' ',80,63);
                textattr:=63;
                gotoxy(2,25);
		write(pathstr);


                gotoxy(20,25);
		write('º Inp: ',inpname);

		gotoxy(40,25);
		write('º Out: ',outname);

		gotoxy(60,25);
		write('º Menu: ',menupath);
		video(normal);


                gettime(hour,min,sec,sec100);
		getdate(year,month,day,dayofweek);
                }
                daytimes;
                { msg(' <Ä>: Move   <ÄÙ: Select   ESC:  Exit   '); }
{		gotoxy(43,25);

write('Login Time: ',p0i(hour,2),':',p0i(min,2),':',p0i(sec,2),
              ' Date: ',p0i(day,2),'/',p0i(month,2),'/',p0i(year mod 100,2));

write('Login Time: ',time,'  ',date);
                textattr:=Norm;
                video(normal);
}
msg('');
end
	else
		begin
		if wset=on then
			begin
			hline(2,25,79,220,Norm);
			vc(1,25,#178,Norm);
			vc(80,25,#178,Norm);
			end
			else
			begin
			hline(1,25,79,32,Norm);
			vc(80,25,#32,Norm);
			end;
		end;
end;

PROCEDURE sideborder;
var
	l,r,b,t,x,y:integer;
begin
if wset=on then
	begin
		windows(wglob,nocls);
		l:=1;
		t:=2;
		r:=80;
		b:=25;
		hline(l,b,r,220,Norm);
		vline(l,t+1,24,177,Norm);
		vline(r,t+1,24,177,Norm);
		vc(l,t,#178,Norm);
		vc(r,t,#178,Norm);
		video(normal);
		vc(1,21,chr(178),123);
		gotoxy(2,21);
		fastwrite(#176,78,123);
		vc(80,21,chr(178),123);
	end
else
	begin
		vline(1,2,24,32,Norm);
		vline(80,2,24,32,Norm);
	end;

end;

PROCEDURE writehead(head:headtype;ron:boolean);
var
   i,tx:integer;
   flag:boolean;
begin
if ron=FALSE then
	begin
		video(reversed);
		flag:=TRUE;
		for i:=1 to HN do
			if (wherex=(i-1)*10+1) and flag then
				begin
                                {
                                textcolor(Yellow);
                                textbackground(White);
                                }

                                textattr:=123;
				write('  ',fixlength(head[i],8,LEFT));
                                textattr:=Norm;
				flag:=FALSE;
				end;
		video(normal);
		tx:=wherex;
		for i:=1 to HN do
			vc((i-1)*10+3,1,head[i][1],110);
		gotoxy(tx,1);
	end
	else
	begin
video(normal);
flag:=TRUE;
for i:=1 to HN do
	if (wherex=(i-1)*10+1) and flag then
		begin
		gotoxy(wherex+1,wherey);
                                textcolor(Yellow);
                                textbackground(Blue);
		write('Û',head[i],'Û');
                textattr:=Norm;
		gotoxy(i*10+1,wherey);
		flag:=FALSE;
		end;
end;
end;

PROCEDURE hpix(t,l,r:integer; head:headtype; var opt:integer;var hpixcode:char);
label 100;
var
	tx,ty:integer;
	i,a,b:integer;
	c:char;
begin
{
if inpname<>'CON' then readln(inp,opt)
else
}
windows(wglob,nocls);
gotoxy(1,1);
fastwrite(' ',80,123);
video(reversed);
{
textcolor(yellow);
textbackground(white);
}
textattr:=123;
for i:=1 to HN do write('  ',fixlength(head[i],8,LEFT));
textattr:=Norm;
if opt=0 then exit;
repeat
gotoxy(opt*10-9,t);
writehead(head,TRUE);
a:=wherex;
b:=wherey;
if wherey>1 then
		gotoxy(71,1)
            else
                gotoxy(wherex-10,wherey);
tx:=wherex;
ty:=wherey;
repeat
if (hpixcode=NOREAD)
	then
		begin
		c:=NOREAD;
		end
	else
	    begin
	    c:=readkey;
	    if c=#0 then
		begin
		c:=readkey;

                Speckey:=TRUE;
		if keyed(altstate) and (c in globalalt) then
			begin
			REQ:=c;
                        hpixcode:=chr(altstate);
   case REQ of
        #25:begin c:='P'; opt:=1; end;
        #23:begin c:='I'; opt:=2; end;
        #19:begin c:='R'; opt:=3; end;
        #24:begin c:='O'; opt:=4; end;
     end;
     goto 100;
			end
				else req:=#0;

		if c=chr(59) then help(1);
		end
		else
100:		for i:=1 to HN do    {#}
			if head[i,1]=upcase(c)
					then
					begin
					tx:=(i-1)*10+1;
					c:=ENTER;
					end;
	if c<>ESC then
		begin
		video(reversed);
		gotoxy(1,1);
{
textcolor(Yellow);
textbackground(white);
}
textattr:=123;
		for i:=1 to HN do
			write('  ',fixlength(head[i],8,LEFT));
                        textattr:=Norm;
		video(normal);
		for i:=1 to HN do
			vc((i-1)*10+3,1,head[i][1],red);
		end;
end;
until (c in [LEFT,RIGHT,ENTER,ESC]) or (hpixcode in [NOREAD,chr(altstate)]);

gotoxy(tx,ty);
writehead(head,FALSE);
if wherey>1 then
		gotoxy(71,1)
            else
		gotoxy(wherex-10,wherey);
case c of
LEFT    :if ((wherex=1)) then gotoxy((HN-1)*10+1,t) else gotoxy(wherex-10,wherey);
RIGHT   :if ((wherex=(HN-1)*10+1)) then gotoxy(l,t) else gotoxy(wherex+10,wherey);
ESC     :begin
		msg(' Really want to exit  <Y/N>  ? ');
		(*
                if yes then
		*)
                     begin

			{   #
			  close(inp);
			  close(out);
			  close(ins);
			  windows(wglob,cls);
			  gotoxy(12,35);
			  video(flashing);
			  msg('GOOD BYE ! ...VKS');
			  gotoxy(1,1);
			  halt;
			}
			  hpixcode:=ESC;
		     end;

                     msg('');
		end;
	end;
opt:=(wherex+9) div 10;
if c=ENTER then hpixcode:=ENTER;
{ else hpixcode:=NOREAD;}
until (c in [ENTER,NOREAD]) or (hpixcode in [ESC,chr(altstate)]);

{LEFT,RIGHT,ENTER,NOREAD];}
writehead(head,TRUE);
end;

PROCEDURE editf;
var
	filename:string;
begin
		readstr(51,'Edit file name ?   ',filename);
		upstring(filename);
		if aborted then exit;
		if exist(filename)
			then
				begin
				msg('Time to display - Loading File '+filename+'...');
				end
			else
				begin
				{	assign(f,filename);
  				 	rewrite(f);
				}	{EDITOR TO BE LOADED}
				msg('Sorry !, Editor is not available now. Process aborted.');
				{
				msg('New file '+filename+' created.');
				}
				windows(wout,cls);
				end;
end;


PROCEDURE save;
begin
if insname<>'' then flush(ins);
if outname<>'CON' then flush(out);
end;


PROCEDURE setinpfile;
var
	temp:string;
begin
	readstr(61,'Input File   ?  ',temp);
	if aborted then exit;
	if not exist(temp) then
		if not aborted
			then
			begin
			msg('File '+temp+' does not exist. Process aborted.');
			exit;
			end
			else exit;

if (inpname=temp) or (outname=temp)
	then
	begin
	msg('Input, Output & Save Input files should be different.'+noise);
	exit;
	end;

	close(inp);
	inpname:=temp;
	assign(inp,inpname);
	reset(inp);
	end;

PROCEDURE setoutfile;
var temp:string;
begin
readstr(62,'Output File  ?  ',temp);
if aborted then exit;
if temp='CON' then
	begin
	outname:=temp;
	assign(out,outname);
	assigncrt(out);
	rewrite(out);
	exit;
	end;
if (inpname=temp) or (outname=temp)
	then
	begin
	msg('Input, Output & Save Input files should be different.'+noise);
	exit;
	end;
if not exist(temp) then
	if not aborted
	then
	begin
		close(out);
		outname:=temp;
		assign(out,outname);
		rewrite(out);
	end else exit;
if exist(temp) and not aborted
	then
	begin
		if (temp='CON') then resp:='Y'
		else
		readchar(64,'File '+temp+' exists. Overwrite it  <Y/N> ? ',resp);
		if resp='Y' then
			begin
			close(out);
			outname:=temp;
			assign(out,outname);
			rewrite(out);
			end;
	end;
end;

PROCEDURE setinsfile;
var temp:string;
begin
readstr(65,'File name to Save Input  ?  ',temp);
if aborted then exit;
if temp='' then
	begin
	insname:=temp;
	exit;
	end;
if temp='CON' then
	begin
	msg('Illegal input data.Process aborted.'+noise);
	exit;
	end;

if (inpname=temp) or (outname=temp)
	then
	begin
	msg('Input, Output & Save Input files should be different.'+noise);
	exit;
	end;
if not exist(temp)
	then
		resp:='Y'
	else
		readchar(66,'File '+temp+' exists. Overwrite it ?  ',resp);
if not aborted and (resp='Y')
	then
		begin
		insname:=temp;
		assign(ins,insname);
		rewrite(ins);
		end;
end;

end.
