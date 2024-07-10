PROCEDURE help(h:integer);
label 100;
const noh=13;
type
	hptype=record
		hp:array[1..16] of string;
		end;
var
	hfile:file of hptype;
	hprec:hptype;
	tx,ty,i,j,k:integer;
	screen2:image;
	m:integer;
	NHigh,NPage:integer;
	sx,sy:integer;
        sattr:byte;
        scursor:char;
        intx,code:integer;

begin
sw(1);
scursor:=lastcursor;
sattr:=textattr;

put(screen2);
setc('I');
{$I-}
	assign(hfile,'IPM.HLP');
	reset(hfile);
{$I+}
if ioresult<>0 then
   begin
   smsg('IPM.HLP not found.'+ESC);
   exit;
   end;

textcolor(yellow);
textbackground(cyan);

m:=h;
100:



{$I-}
	seek(hfile,m-1);
	read(hfile,hprec);

if (ioresult<>0) then
                 begin
                 m:=m-1;
                 goto 100;
                 end;
{$I+}
with hprec do
begin

{

hp[1][k]-    line
hp[1][k+1]-  start col
hp[1][k+2]-  start col

}

{
	hp[1]:= #2+#10+#15+#1 + #3+#12+#18+#1 +#2;
	hp[1][0]:=#2;
}

        s:=nospace(hp[1]);
        while pos('*',s)<>0 do delete(s,pos('*',s),1);

        hp[1]:='';
        i:=1;
    while pos(',',s)>0 do
        begin
        val(copy(s,1,pos(',',s)-1), intx, code);
        insert(chr(intx),hp[1],length(hp[1])+1);
        inc(i);
        delete(s,1,pos(',',s));
        write(intx);
        end;

        val(s, intx, code);
        insert(chr(intx),hp[1],length(hp[1])+1);

	NHigh:=length(hp[1]) div 4;           { No. of high areas }
	NPage:=ord(hp[1][NHigh*4+1]);     { No. of pages to display
                                            at current F1 }
        if length(hp[1]) mod 4 <> 1 then smsg(strint(m,1)+'Error in help file!'+ESC);

	rev:=FALSE;
	dbox(9,4,72,21,single,53);
        vs(38,4,'Help',53);
	window(10,5,71,20);
	clrscr;

k:=1;
repeat
	tx:=9+wherex;
	ty:=4+wherey;
	for i:=2 to 16 do
			begin
			j:=1;
			inc(tx);
		while j<=length(hp[i]) do
		begin
	        attr:=textattr;
                if NHigh>0 then
		if (i=ord(hp[1][k])) and (j>=ord(hp[1][k+1])) and (j<=ord(hp[1][k+2]))
				then
					attr:=106;
			case hp[i][j] of
				#9:     tx:=tx+7;
				else   	vc(tx,ty,hp[i][j],attr);
				end;
		inc(tx);
		inc(j);
		end;
		ty:=ty+1;
		tx:=10;
		end;
resp:=readkey;
case resp of
	#0:
		begin
		resp:=readkey;
		if resp in [LEFT,UP] then  { shift b/n high areas }
			if k>1 then
					k:=k-4
				else
					k:=(NHigh-1)*4+1;

		if resp in [RIGHT,DOWN] then
			if k=(NHigh-1)*4+1 then
					k:=1
					else
					k:=k+4;


		if (resp=PgUp) and (m>h) then
					begin
					m:=m-1;
					goto 100;
					end;

		if (resp=Pgdn) and (m<noh)
					then
					begin
					m:=m+1;
					goto 100;
					end;
		end;
	ESC:
		begin
		get(screen2);
		rw(1);
		end;
	ENTER:            { goto page no m }
		if NHigh>0 then
                begin
		m:=ord(hp[1][k+3]);
		goto 100;
		end;
	end;
if resp<>ESC then msg(' Press PgUp/PgDn/ESC.');
until resp=ESC;
end;
close(hfile);
textattr:=sattr;
setc(scursor);
end;
