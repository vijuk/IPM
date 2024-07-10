 {
proname.MAT   : material ratio file
Note: If MathCoprocessor is used real=Extended
}

unit ilib;
interface
uses
     lib,crt,graph,editor,olib,plib,forms,dos,printer;
const
     memdispflag:boolean=TRUE;

{$I ilibvars}

implementation

PROCEDURE pushmem(fname:string);forward;
PROCEDURE popmem(fname:string;x:integer);forward;

{ Align strings in fixed width columns }
procedure align(s:string;var ss:astring;var col:integer);
var
   i,j,k:integer;
begin
k:=0;
repeat
inc(k);
ss[k]:='';
i:=0;
j:=0;
repeat
inc(i);
if s[i]=' ' then j:=i;
until (i=col+1) or (i+1>length(s));
if col>length(s) then j:=length(s) else
                 if j=0 then j:=col;
ss[k]:=copy(s,1,j);
delete(s,1,j);
until (s='') or (k=5);
col:=k;
end;

procedure editfile(s:string);
begin
editf(s);
if memerror then
   begin
        smsg('Memory shortage. Unload project file ? Y/N ');
        if yes then
           begin
                   if sflag then save(proname);
		   release(heap);
		   editf(s);
		   flags[9]:=TRUE;
		   load(proname+'.DAT');
	   end;
   end;
end;

PROCEDURE ff;
begin
  if outname='PRN' then writeln(out);
  {  writeln(out);}
end;

PROCEDURE memdisp;
var
   tx,ty:integer;
begin
if memdispflag=FALSE then exit;
tx:=wherex;
ty:=wherey;
vs(50,23,' '+strint(memavail div 1000,3)+'.'
                      +p0i(memavail mod 1000,3)+' KiloBytes Free ',126);
gotoxy(tx,ty);
end;

FUNCTION overflow:boolean;
begin
if memok(sizeof(sheet1^)) then overflow:=FALSE else overflow:=TRUE;
end;

PROCEDURE fileinfo(fname:string);
var info:text;
begin
textattr:=Norm;
gotoxy(1,15);
findfirst(fname+'.DAT',$3F,filerecord);
unpacktime(filerecord.time,daytimer);

with daytimer do
   begin
       dbox(40,3,80,23,0,54);
       vs(56,3,'File Info',54);
       window(41,4,79,22);
       clrscr;

if fname='' then exit;
textcolor(lightgreen);
writeln;
writeln('  File name     :'+fname+'.DAT ');
writeln('  File size     :',filerecord.size,' Kilobytes');
writeln('  Last modified :');
writeln('           Date :',p0i(day,2),'/',p0i(month,2),'/',p0i(year,2));
writeln('           Time :',p0i(hour,2),':',p0i(min,2),':',p0i(sec,2));
writeln;

{$I-}
assign(info,fname+'.INF');
reset(info);
{$I+}

if ioresult=0 then
   begin
      repeat
         readln(info,s);
         writeln(' ',chklen(s,37));
      until eof(info);
      close(info);
   end;
window(1,1,80,25);
end;
end;

{$I rec.pas}


FUNCTION gt(as:char;d:datetype;flag:boolean):real;
{ as='A' actual ; as='S' scheduled ; flag=TRUE qty. upto a date only }
var
	tsheet:psheettype1;
	gtotal:real;
        i:integer;
begin
msg('');
tsheet:=sheet1;
gtotal:=0;
for i:=1 to No_act do
      begin
      takerec(i);
      with sheet1^ do quantity:=length*breadth*height+addQ-subQ;
      if ( (as='A') and (sheet1^.stat=1) ) or (as='S') then
                     begin
                             dater:=0;
                             if flag then
                             with sheet1^ do
                                   begin
                                   datecheck(cd[1],cd[2],cd[3],d[1],d[2],d[3],dater);
{
writeln(cd[1],'/',cd[2],'/',cd[3],' : ',d[1],'/',d[2],'/',d[3],' = ',dater);
                                   waitfor(ESC);
}
                                   end;

                             if dater>=0 then
                                gtotal:=gtotal+sheet1^.quantity;
                     end;
      end;
gt:=gtotal;
sheet1:=tsheet;
end;

PROCEDURE bymenu(sheettype:integer);
begin
if sheettype in [SC_A,SC_D] then exit;

textattr:=126;
box(1,16,45,24,0,textattr);
box(47,17,80,24,0,textattr);
vs(30,16,'Rec.No: '+p0i(m+hl-1,3)+'/'+p0i(No_act,3),textattr);
vs(70,18,'Copy     ',textattr);

if purpose=0 then
begin
vs(54,18,'Insert   ',textattr);
vs(54,19,'Delete   ',textattr);
vs(54,21,'Edit     ',textattr);
vs(70,20,'Exit     ',textattr);
end
   else

       begin
       case sheettype of
            SR:vs(54,21,'Mark     ',textattr);
            SA:
               begin
               vs(47,16,'******** Select  Activity ********',91);
               vs(54,21,'Select   ',textattr);
               end;
            end;
       end;

vs(70,19,'Print    ',textattr);
vs(54,20,'Save     ',textattr);
vs(70,21,'Prev Menu',textattr);

vs(48,18,'   F5',127);vs(66,18,' F6',127);
vs(48,19,'   F7',127);vs(66,19,' F8',127);
vs(48,20,'   F9',127);vs(66,20,'F10',127);
vs(48,21,' <CR>',127);vs(66,21,'ESC',127);
end;

PROCEDURE selfile(x,ch:integer;var prgname:string;extname:string;chstart:integer);
var i:integer;
begin
prgname:='';
hv[1]:=1;  { added on 7/6/96 }
chstart:=1;

for i:=1 to 13 do
               menus^[i]:=fixlength('',30,left);
		   i:=0;
                   repeat
			 inc(i);
			 filerecord.name:='';
                         if i=1 then
				findfirst('*'+extname,$3F,filerecord)
			 else
				findnext(filerecord);
			 fsplit(filerecord.name,path,name,ext);
			 menus^[i]:=' '+fixlength(name,29,LEFT);
		   until filerecord.name='';
		   dec(i);

                   ch:=1;
		   if i>0 then
		   repeat
                        shadow:=TRUE;
			     box(x,5+chstart-1,x+31,5+chstart+12+1,single,28);
                             vs(x+9,5+chstart-1,'Bill Format File',28);

			     scode[7]:=NOCHECK;
			     boxpix(1,menus,'',x+1,5+chstart,x+32,5+chstart+12,hv[1],ch,scode[7],1);
                             urgentservice(scode[7]);

		   case scode[7] of
			up: if (ch=13) and (hv[1]>1) then
					begin
					dec(hv[1]);
					ch:=1;
					end
					else
                                        if (ch=13)
                                             then ch:=1;

		     down: if (ch=1) then
                           if (hv[1]+13{+1}<=i) then
					begin
					inc(hv[1]);
					ch:=13;
					end
					else
                                        ch:=13;
		       end;

                   if (nospace(menus^[hv[1]+ch-1])='') and
                                                  (ch>1) then ch:=i;
		   until scode[7] in [ESC,ENTER];


		   if (scode[7]=ENTER)  then
		   if (i>0) and exist(nospace(menus^[hv[1]+ch-1])+extname) then
				prgname:=nospace(menus^[hv[1]+ch-1]);


                   {
		   else
				smsg('File not found.'+ESC);
                   }
end;

{$I date.pas}
PROCEDURE moveup;
begin
        if (hl=1) and (m>1) then
                            begin
                            dec(m);
                            dec(n);
                            end
                            else
                      if (hl>1) then dec(hl);
end;

PROCEDURE movedown;
begin
if (purpose=1) and (m+hl>No_act) then exit;
if (hl=10) then
             begin
               inc(m);
               inc(n);
             end
     else
	if (hl<10) then	inc(hl);
if (purpose=0) and (m+hl-1>no_act) then
                                   appendrec(last);
end;



PROCEDURE menufill(sheettype:integer);
var s:string;
begin

with sheet1^ do
case sheettype of
SA:
	begin
	menus^[1]:=' '+fixlength(activity,25,LEFT);
	menus^[2]:=' '+fixlength(munit,25,LEFT); { unit }
	date2str(sd,s);
	menus^[3]:=' '+fixlength(s,25,LEFT);
	date2str(fd,s);
	menus^[4]:=' '+fixlength(s,25,LEFT);
	end;
QS:
	begin
	menus^[1]:=' '+fixlength(code,25,LEFT);
	menus^[2]:=' '+fixlength(strreal(length,5,3),25,LEFT);
	menus^[3]:=' '+fixlength(strreal(breadth,5,3),25,LEFT);
	menus^[4]:=' '+fixlength(strreal(height,5,3),25,LEFT);
	menus^[5]:=' '+fixlength(strreal(addQ,5,3),25,LEFT);
	menus^[6]:=' '+fixlength(strreal(subQ,5,3),25,LEFT);
	end;
TR:
	begin
	menus^[1]:=' '+fixlength(activity,25,LEFT);
	menus^[2]:=' '+fixlength(strreal(c_rate,5,3),25,LEFT);
	menus^[3]:=' '+fixlength(strreal(sc_rate,5,3),25,LEFT);
	end;
end;
end;

PROCEDURE selectread(sheettype:integer);
label 100;
var
	rdura:real;
	dura,err:integer;
        temp:psheettype1;
        heap2:pointer;
        tlen:integer;
        s:string;

begin


sflag:=TRUE;
mark(heap2);
new(temp);

copyrec(temp,sheet1);
temp^.tap:=sheet1^.tap;

with temp^ do
case sheettype of
SA:
begin
case choice[7] of
     1:readstr(1,' Edit : ',activity);
     2:readstr(1,' Edit : ',munit);   { unit }
     3: begin
	date2str(sd,s);
	repeat
           nabt;
	   readstr(1,' Edit : ',s);
	   str2date(s,sd[1],sd[2],sd[3]);
	   readKSbuff:=#0;
           errorflag:=FALSE;      { # Check for side effects }
	until not errorflag or escf or aborted;
       end;

    4: 	begin
	date2str(fd,s);
	repeat
	errorflag:=FALSE;
        nabt;
	readstr(1,' Edit : ',s);
        upstring(s);
        if nospace(s)='' then str2date(s,fd[1],fd[2],fd[3])
            else
	if (pos('/',s)=0) and (pos('-',s)=0) then
		begin
                   myval(s,rdura,err);
                   dura:=round(rdura);
	   if err=0 then
			dura_2_days(sd[1],sd[2],sd[3],dura,fd[1],fd[2],fd[3])
		   else
			errorflag:=TRUE;
		end
	     else
		begin
		   str2date (s,fd[1],fd[2],fd[3]);
		   readKSbuff:=#0;
		   datecheck(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3],dater);
		end;

                errorflag:=FALSE;      { # Check for side effects }

	until not errorflag or escf or aborted;
        end;
	end;
    end;

QS:
begin
100:
if sheet1^.stat=1 then
                     smsg('Can''t modify marked items.'+ESC)
   else
begin
case choice[7] of
     1:readstr (1,' Edit : ',code);
     2:readreal(1,' Edit : ',Length);
     3:readreal(1,' Edit : ',Breadth);
     4:readreal(1,' Edit : ',Height);
     5:
       begin
       activity:=fixlength(activity,actlen,LEFT);
       s:=nospace(copy(activity,1,addlen));
       tlen:=buflen;
       buflen:=addlen;
       readstr(1,' Edit : ',s);
       buflen:=tlen;
       readKSbuff:=NOREAD;
       addQ:=0;
       readreal(1,'Edit : ',AddQ);
       readKSBuff:='E';
       s:=KSBuff;
       activity:=concat(fixlength(s,addlen,LEFT),copy(activity,addlen+1,actlen));
       end;

     6:
     begin
       activity:=fixlength(activity,actlen,LEFT);
       s:=nospace(copy(activity,addlen+1,actlen));
       tlen:=buflen;
       buflen:=dedlen;
       readstr(1,' Edit : ',s);
       buflen:=tlen;
       readKSbuff:=NOREAD;
       subQ:=0;
       readreal(1,'Edit : ',subQ);
       readKSBuff:='E';
       s:=KSBuff;
       activity:=concat(copy(activity,1,addlen),fixlength(s,dedlen,LEFT));
       end;
      end;
if ((length<0) or (breadth<0) or (height<0) or
              (addQ<0) or (subQ<0) ) and not aborted then goto 100;
Quantity:=Length*Breadth*Height+addQ-subQ;
end;
end;

TR:
begin
if st_sheet^.stat>0 then
         smsg('Can''t modify marked items.'+ESC)
else
case choice[7] of
     1:readstr(1,' Edit : ',activity);
     2:readreal(1,' Edit : ',c_rate);
     3:readreal(1,' Edit : ',sc_rate);
     end;
end;
end;

if not aborted then
   begin
	copyrec(sheet1,temp);
	sheet1^.tap:=temp^.tap;
   end;

	release(heap2);
	readKSbuff:=#0;
	if not errorflag and not aborted and (hc=1)
		then
		if choice[7]<num then inc(choice[7])
			else
			     begin
			      scode[7]:=ESC;
			      movedown;
			     end;
      errorflag:=FALSE;

end;

PROCEDURE writetable(sheettype:integer);
var
   matrec:matrectype;
   matfile:file of matrectype;
   i,j:integer;

   PROCEDURE high(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10:byte);
   begin
   if (purpose=0) and (sheettype in [SA,QS,TR]) then exit;
   for x:=(hl+3)*160 to (hl+4)*160-2 do
                    begin
                    if (odd(x) and
                       not(x mod 160=c1) and
                       not(x mod 160=c2) and
		       not(x mod 160=c3) and
		       not(x mod 160=c4) and
		       not(x mod 160=c5) and
		       not(x mod 160=c6) and
		       not(x mod 160=c7) and
		       not(x mod 160=c8) and
		       not(x mod 160=c9) and
		       not(x mod 160=c10)
                       )
                       then mem[Vseg:x]:=barco;
                    end;
   end;

begin
textattr:=11;
window(2,5,79,22);
gotoxy(1,1);


case sheettype of
SA:
   begin
   for i:=m to m+9 do
	if i<=No_act then
	begin
	takerec(i);
	with sheet1^ do
             begin
	    write('  ',p0i(recno,3),'  ³ ',fixlength(activity,40,LEFT),'³ ',fixlength(munit,5,LEFT),'³ ');
            if (sd[1]=0) and (sd[2]=0) and (sd[3]=0) then
             write(' ':8)
             else
            write(    p0i(sd[1],2),'/',
                      p0i(sd[2],2),'/',
		      p0i(sd[3],2));
           write(' ³ ');

             if (fd[1]=0) and (fd[2]=0) and (fd[3]=0) then
             write(' ':8)
             else
            write(    p0i(fd[1],2),'/',
                      p0i(fd[2],2),'/',
		      p0i(fd[3],2));
            write(' ');
            end
	end
    else
	    write(' ':7,'³',' ':41,'³',' ':6,'³',' ':10,'³',' ':10);
    high(1,159,137,115,101,17,1,1,1,1);
        if purpose=0 then
                begin
                textattr:=126;
	        window(1,1,80,25);
               	vs(3,17,' Activity      :                          ',textattr);
                vs(3,18,' Unit          :                          ',textattr);
	        vs(3,19,' Start date    :                          ',textattr);
	        vs(3,20,' End date      :                          ',textattr);
                end;

        takerec(m+hl-1);

   if (purpose=1) and flags[2] then
      begin
        assign(matfile,TD+proname+'.MAT');
        {$I-}
        reset(matfile);
        {$I+}
        if ioresult<>0 then rewrite(matfile);
        matrec.desc:='~~~~~~~~~~~~~~~~~';
        if ioresult=0 then
                 begin
                 while not eof(matfile) and
                         not (sheet1^.activity=matrec.desc) do
                                         read(matfile,matrec);

if (sheet1^.activity=matrec.desc) then
                           begin
                              textattr:=126;
	                      window(1,1,80,25);
                              for j:=1 to 10 do
                              with matrec do
                                  if (sx[j]<>'') and (j<9) then
                                  vs(3,16+j,sx[j]+'='+justify(sv[j],6,2,RIGHT)+su[j],textattr);
                           end
                   else
                          if  eof(matfile) then
                              begin
                                   window(2,17,44,23);
                                   textattr:=126;
                                   clrscr;
                                   window(1,1,80,25);
                              end;
                close(matfile);
                end;
            end;
	end;
QS,SR:
begin
for i:=m to m+9 do
    if i<=No_act then
	begin
	takerec(i);

	with sheet1^ do
             begin
             if (stat=1) then
                       begin
                              attr:=textattr;
                              textcolor(lightgreen);

			      if (cd[1]=d[1]) and (cd[2]=d[2])
                                 and (cd[3]=d[3]) then write(' û')
                                 else
                                        write(' *');

			      textattr:=attr;
                       end
          else
                   write('  ');

    write(p0i(recno,3),' ³ ',fixlength(code,8,LEFT));
            write(' ³',length:8:3,
	    ' ³',breadth:8:3,' ³',height:8:3,' ³',
			addQ:8:3,' ³',subQ:8:3,' ³',quantity:9:3,' ');
            end;
	end
    else
write(' ':6,'³',' ':10,'³',' ':9,'³',' ':9,'³',' ':9,'³',' ':9,'³',' ':9,'³',' ':10);
high(1,15,37,57,77,97,117,137,1,1);

if sheettype=QS then
begin
     textattr:=126;
     window(1,1,80,25);
     gotoxy(67,16);
     write(gt('S',d,FALSE):12:3,'  ');
     vs(3,17,' Code          :                          ',textattr);
     vs(3,18,' Length        :                          ',textattr);
     vs(3,19,' Breadth       :                          ',textattr);
     vs(3,20,' Depth         :                          ',textattr);
     vs(3,21,' (+) Qty       :                          ',textattr);
     vs(3,22,' (-) Qty       :                          ',textattr);
end
else
  begin
     textattr:=126;
     window(1,1,80,25);
     gotoxy(67,16);
     write(gt('S',d,FALSE):12:3);

     vs(3,19,'                                          ',textattr);
     vs(3,20,'                                          ',textattr);
     vs(3,21,'                                          ',textattr);
     vs(3,22,'Press <Enter> to mark/demark completion.  ',textattr);
     vs(3,23,'Completed activities prefixed by û or *.  ',textattr);
  end;
msg(footer);
end;

TR:
begin
for i:=m to m+9 do
	if i<=No_act then
	begin
	takerec(i);
	with sheet1^ do
write(recno:5,'  ³ ',fixlength(activity,41,LEFT),' ³',
c_rate:8:2,' ³',sc_rate:8:2,' ³',fixlength(munit,5,Right),' ');
	end
    else
        write(' ':7,'³',' ':43,'³',' ':9,'³',' ':9,'³',' ':6);
high(1,17,105,125,145,1,1,1,1,1);

window(1,1,80,25);
textattr:=126;
vs(3,17,' Activity      :                          ',textattr);
vs(3,18,' C-Rate        :                          ',textattr);
vs(3,19,' S-Rate        :                          ',textattr);
vs(3,21,' C-Rate  =  Contractor''s rate             ',textattr);
vs(3,22,' S-Rate  =  Subcontractor''s rate          ',textattr);
vs(3,23,' NB:Measurement unit must be same for both.',textattr);

end;

BM:
begin
{
writeln('Software variables');
writeln;
writeln('   i            ');
writeln('   Activity     ');
writeln('   Unit         ');
writeln('   Quantity     ');
}

Control:='OPEN';
for i:=1 to 26 do
	begin
        svl[i]:=0;
	svr[i]:='~';
	end;

takerec(1);
push;

for i:=1 to No_act do
  begin
    takerec(i);
    svl[1]:=i;
    svr[2]:='Activity'+''''+sheet1^.activity+'''';
    svr[3]:='Unit'+''''+sheet1^.munit+'''';
    svl[4]:=sheet1^.quantity;
    svr[1]:='I';
    svr[4]:='Quantity';
    formstar('SUBBILL.IPM','FORM.OUT',svr,svl);
  end;

    control:='';
    formstar('SUBBILL.IPM',TD+'TEMP.IPM',svr,svl);
    window(1,2,80,24);
    clrscr;
    if (formresult=0) and not printmode then
                          editfile(TD+'TEMP.IPM');
pop;
end;
end;
end;

PROCEDURE breakstring(s:string);
var
  i,j,k,error:integer;
  matrec:matrectype;
  matfile:file of matrectype;
  t:byte;

begin
{
  f:text;
assign(f,'debug.pas');
rewrite(f);
writeln(f,s);
close(f);
waitfor(ESC);
}
assign(matfile,TD+proname+'.MAT');
{$I-}
reset(matfile);
{$I+}

if ioresult=0 then
      begin
      while not eof(matfile) and (matrec.desc<>sheet1^.activity) do
                        read(matfile,matrec);
     if not eof(matfile) then
          if filepos(matfile)>0 then seek(matfile,filepos(matfile)-1);
     end
   else
       rewrite(matfile);

{
if not eof(matfile) then
		smsg('Error appending material file.'+ESC);
}

delete(s,1,pos('=',s));
with matrec do
begin
desc:=sheet1^.activity;
u:=sheet1^.munit;

     j:=0;
     repeat
	   inc(j);
	   t:=pos(',',s);
	   if (t<>0) and (j<=10) then
		begin
			sx[j]:=nospace(copy(s,1,pos(',',s)-1));
			delete(s,1,t);
		end;
     until (t=0) or (j=11);

     if j=11 then smsg('Problem : Input file format error.'+ESC);

sx[j]:=s;
for k:=1 to 10 do
    begin
    if k<=j then
	begin
	     s:=sx[k];
             sx[k]:=nospace(copy(s,1,pos('-',s)-1));
             delete(s,1,pos('-',s));
	     i:=0;
	     repeat
	     inc(i)
	     until not (s[i] in ['0'..'9','.']);
	     val(copy(s,1,i-1),sv[k],error);
             delete(s,1,i-1);
             su[k]:=nospace(s);
	end
	else
		sx[k]:='';
    end;
end;
write(matfile,matrec);
close(matfile);
sflag:=TRUE;
end;

procedure sel_line(var matinp:stringlines;fname:string;var select:string);
label 100;
var
   hvp:integer;
   maxlines:integer;
   seekno:integer;
   stgotline,gotline:longint;
   ss:string;
   temps:array[1..12] of string[120];

PROCEDURE seekfrom(no:longint);
var
	j,k:integer;
begin
seek(matinp,no);
j:=0;
while (not eof(matinp)) and (j<125) do
      begin
         inc(j);
         if (j<=hvp) then menus^[j]:=menus^[99-hvp+j]
                else
                    begin
                       read(matinp,s);
                       menus^[j]:=' '+fixlength(s,120,LEFT);
                    end;
      end;

if eof(matinp) and (j<125) then
   begin
   menus^[j+1]:=' '+fixlength('End of file',120,LEFT);
   for k:=j+2 to 125 do menus^[k]:=' '+fixlength(' ',120,LEFT);
   end;
end;

begin
assign(matinp,fname);
{$I-}
reset(matinp);
{$I+}
if ioresult<>0 then
                 begin
                   smsg('File '+fname+'  not found.'+ESC);
                   exit;
                 end;
maxlines:=filesize(matinp);
seekno:=0;
hvp:=0;
seekfrom(seekno);
ss:='';
   choice[7]:=1;

   repeat
	 box(1,5-1,80,5+12+1,single,28);
         scode[7]:=NOCHECK;
         for i:=1 to 13 do
             begin
             temps[i]:=menus^[hv[1]+i-1];
             menus^[hv[1]+i-1]:=fixlength(menus^[hv[1]+i-1],78,LEFT);
             end;

         boxpix(1,menus,'',2,5,78,5+12,hv[1],choice[7],scode[7],1);
         for i:=1 to 13 do menus^[hv[1]+i-1]:=temps[i];
         urgentservice(scode[7]);
         gotoxy(1,22);
         textattr:=28;
         writeln(fixlength(menus^[hv[1]+choice[7]-1],160,LEFT));
         textattr:=norm;



if choice[11]<>0 then
begin
    if (hv[1]=101) and (scode[7]=DOWN) and ((seekno+100)<=maxlines-1) then
			begin
				hv[1]:=1;
                                choice[7]:=13;
				seekno:=seekno+100;
                                hvp:=0;
				seekfrom(seekno);
                                choice[11]:=-1;
			end;

    if (hv[1]=1) and (scode[7]=UP) and (seekno-100>=0) then
			begin
				hv[1]:=100;
                                choice[7]:=1;
				seekno:=seekno-100;
                                hvp:=0;
				seekfrom(seekno);
                                choice[11]:=-1;
			end;
end;

if choice[11]<>-1 then
    case scode[7] of
         ENTER:
               begin
               if (pos('=',menus^[hv[1]+choice[7]-1])>0) or (select='MATLIST')
               then
                  begin
                       select:=menus^[hv[1]+choice[7]-1];
                       close(matinp);
                       exit;
                  end
                            else  scode[7]:=#0;
               end;
	       up:if (choice[11]=1) and (hv[1]>1) then
				begin
				dec(hv[1]);
				choice[7]:=1;
				end
			else
                                if (choice[11]=1)
                                      then
                                           choice[7]:=1;

	     down: if (choice[11]=13) then
			 if (hv[1]<=100) then
					begin
					     inc(hv[1]);
					     choice[7]:=13;
					end
					else
                                             choice[7]:=13;
 space :
	begin
	      gotline:=-1;
              {ss:='';}{upcase(scode[7]);}
	      reset(matinp);
	repeat
        ss:='';
	      stgotline:=gotline;
              readstrbox(1,20,20,60,'Type string to search',ss,excode);
	      if excode<>ESC then
                 begin
			     while (not eof(matinp)) do
				begin
				   inc(gotline);
				   read(matinp,s);
			   if (s<>'') and (pos('=',s)=0) then
					begin
					s:=upstringf(nospace(s));
					if pos(upstringf(ss),s)>0 then
						goto 100;
					end;
				end;
gotline:=-1;
100:
	if (gotline>stgotline) and (pos(upstringf(ss),s)>0) then
			      begin
				choice[7]:=1;
				hvp:=0;
				seekno:=gotline div 100;
				hv[1]:=gotline mod 100+1;
				seekfrom(seekno);
                                seek(matinp,gotline+1);
                                choice[11]:=-1;
		                scode[7]:=NOREAD;
         for i:=1 to 13 do
             if hv[1]+i-1<125 then
             begin
             temps[i]:=menus^[hv[1]+i-1];
             menus^[hv[1]+i-1]:=fixlength(menus^[hv[1]+i-1],78,LEFT);
             end;
         boxpix(1,menus,'',2,5,78,5+12,hv[1],choice[7],scode[7],1);
         for i:=1 to 13 do
             if hv[1]+i-1<125 then
             menus^[hv[1]+i-1]:=temps[i];
			      end
			else
			    begin
                                smsg(' Search string "'+ss+'" not found. Press any key.');
				waitfor(any);
				msg('');
                                excode:=ESC;
			    end;
                        end;
                until (excode=ESC);
                end;
       end;
   until scode[7] in [ESC,ENTER];
hv[1]:=1;
close(matinp);
end;


PROCEDURE drawtable(sheettype:integer);
var
   matinp:stringlines;
   tprev,tpres,total:real;
   prgname:string[12];
   ss:astring;
   colno,cnt:integer;
   flag:boolean;
   s1,s2:string;
   tot_quantity:real;

begin
window(1,1,80,25);
gotoxy(1,2);
case sheettype of
SA:
begin
     msg('Schedule of activities');
write('ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿');
write('³ Code  ³  Activity                               ³ Unit ³Start Date³ End Date ³');
write('ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´');
for i:=1 to 10 do
write('³                                                                              ³');
write('ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ');
end;

QS,SR:
begin
write('ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿');
write('³  No  ³ Code     ³ Length  ³ Breadth ³ Height  ³ (+)Qty  ³ (-)Qty  ³ TotalQty ³');
write('ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´');
for i:=1 to 10 do
write('³                                                                              ³');
write('ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ');
textattr:=126;
write('                                                     Grand Total =',gt('S',d,FALSE):12:3,'  ');
textattr:=62;
end;

TR:
begin
msg('Rates of contractor and subcontractor');
write('ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ¿');
write('³ SL No.³ Activity                                  ³  C-Rate ³  S-Rate ³ Unit ³');
write('ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄ´');
for i:=1 to 10 do
write('³                                                                              ³');
write('ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÙ');
end;

SC_D:
begin
msg('Subcontractor''s bill');

if printmode and printerready then
                    begin
                    out_2_prn;
                    writeln(out,ESC,#15);     { Set Compressed mode }
                    end
             else
                    begin
                         assign(out,TD+proname+'.SBL');
                         rewrite(out);
                    end;

{$I-}

  writeln(out);
  writeln(out,' ':46,'Working Notes for Subcontractors bill');
  writeln(out,' ':46,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

  date2str(d,s);
  writeln(out,fixlength(' Name  : '+subname,50,LEFT));
  writeln(out,fixlength(' Closing Date : '+s,25,LEFT));
  writeln(out,fixlength(' Project : '+proname,80,LEFT));
  writeln(out,fixlength(' Bill Date : '+date,40,LEFT));
  writeln(out);

  write(out,'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ');
  writeln(out,'ÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  write(out,'³ SL. ³                          ³      ³           ');
  writeln(out,'³    Previous    ³      Present     ³     Total  Upto date    ³');
  write(out,'³     ³      Items of work       ³ Unit ³    Rate   ');
  writeln(out,'³   Measurement  ³    Measurement   ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ´');
  write(out,'³ No. ³                          ³      ³           ');
  writeln(out,'³     Quantity   ³     Quantity     ³  Quantity  ³ Cost (Rs.) ³');
  write(out,'ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ');
  writeln(out,'ÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´');

  tprev:=0;
  tpres:=0;
  total:=0;

for i:=1 to No_act do
begin
if (ioresult<>0) or Ubreak then exit;

takerec(i);
tot_quantity:=0;
with sheet1^ do
if (pres+prev)>0 then
 begin

 colno:=25;
 align(activity,ss,colno);
 write(out,'³ ',i:3,' ³',' ',fixlength(ss[1],25,LEFT),
    '³ ',munit:3,'  ³',justify(sc_rate,7,2,RIGHT),' ³');
   writeln(out,justify(prev,11,3,RIGHT),' ³',justify(pres,13,3,RIGHT),' ³',
   justify(prev+pres,7,3,RIGHT),' ³',justify((prev+pres)*sc_rate,8,2,RIGHT),' ³');

for cnt:=2 to colno do
begin
   write(out,'³',' ':5,'³',' ',fixlength(ss[cnt],25,LEFT),
    '³',' ':6,'³',' ':11,'³');
   writeln(out,' ':16,'³',' ':18,'³',' ':12,'³',' ':12,'³');
end;

   tprev:=tprev+prev*sc_rate;
   tpres:=tpres+pres*sc_rate;
   total:=total+(pres+prev)*sc_rate;

 end;
end;

write(out,'ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ');
writeln(out,'ÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ');
writeln(out,fixlength('Present bill amount      = Rs.'+justify(tpres,10,2,RIGHT),119,RIGHT));
writeln(out,fixlength('Upto date bill amount    = Rs.'+justify(total,10,2,RIGHT),119,RIGHT));
writeln(out);


{ Detailed measurements }
for i:=1 to No_act do
	begin
        if (ioresult<>0) or (Ubreak) then exit;
	takerec(i);
        flag:=TRUE;
push;

tot_quantity:=0;
for j:=1 to No_act do
	begin
		takerec(j);
		with sheet1^ do
		    begin
if (stat=1) and (uns(sub_id)=uns(subname)) and (d[1]=cd[1])  and (d[2]=cd[2])
  and (d[3]=cd[3]) then
begin

if flag then
begin
writeln(out,strint(st_sheet^.recno,3),'.  ',fixlength(st_sheet^.activity+' ('+st_sheet^.munit+')',70,LEFT));
writeln(out);
flag:=FALSE;
end;

writeln(out,'   ',fixlength(code,8,LEFT),' ':4,': ',length:1:2,'*',breadth:1:2,'*',height:1:2);
s1:=nospace(copy(activity,1,addlen));
if (s1<>'') then if  (realstr(s1)<>0) then writeln(out,' ':5,' Add    : '+s1);
s2:=nospace(copy(activity,addlen+1,actlen));
if (s2<>'') then if  (realstr(s2)<>0) then writeln(out,' ':5,' Deduct : '+s2);
writeln(out,' ':60,'  = ',quantity:10:3);
writeln(out);
tot_quantity:=tot_quantity+quantity;

end;
    end;
	end;
pop;

if tot_quantity<>0 then
   begin
   writeln(out,' ':50,'Total       = ',tot_quantity:10:3);
   writeln(out,' ':65,'----------' );
   end;

end;  { End Detailed measurements }

if printmode then writeln(out,#18);          { Release compressed mode }
close(out);
if not printmode then editfile(TD+proname+'.SBL');
{$I+}

end;

SC_A:           { Subcontractor's bill in Abstract form }

begin
control:='OPEN';
msg('Subcontractor''s bill');
get(screen);

if printmode and printerready then
                    out_2_prn
             else
                    begin
                         assign(out,TD+proname+'.SBA');
                         rewrite(out);
                    end;

for i:=1 to 26 do
	begin
             svl[i]:=0;
	     svr[i]:='~';
	end;

   svr[1]:='prev_Amount';
   svr[2]:='pres_Amount';
   svr[3]:='upto_Amount';

   date2str(d,s);
   svr[4]:='Cdate'''+s+'''';
   i:=0;
   repeat inc(i) until (nospace(s)=nospace(datelist[i]));
   svr[5]:='BILLNO';
   svl[5]:=i;


for i:=1 to No_act do
begin
takerec(i);
with sheet1^ do
begin
   svl[1]:=svl[1]+prev*sc_rate;
   svl[2]:=svl[2]+pres*sc_rate;
   svl[3]:=svl[3]+(pres+prev)*sc_rate;
end;
end;

selfile(40,6,prgname,'.PRG',1);
if nospace(prgname)='' then exit;
{
if not exist(prgname+'.PRG') then
                      begin
                          smsg('Can''t find '+prgname+'.PRG.'+ESC);
                          exit;
                      end;
}

{$i-}
formstar(prgname+'.PRG',TD+prgname+'.SBA',svr,svl);
window(1,2,80,24);
clrscr;
if not printmode then editfile(TD+prgname+'.SBA');
{$i+}
end;


CB:
begin
control:='OPEN';
msg('Contractor''s bill');
get(screen);

for i:=1 to 26 do
	begin
             svl[i]:=0;
	     svr[i]:='~';
	end;

   date2str(d,s);
   svr[4]:='Cdate'''+s+'''';
   i:=0;
   repeat inc(i) until (nospace(s)=nospace(datelist[i]));
   svr[5]:='BILLNO';
   svl[5]:=i;

for i:=1 to No_act do
begin
takerec(i);
with sheet1^ do
begin
   svl[1]:=svl[1]+prev*sc_rate;
   svl[2]:=svl[2]+pres*sc_rate;
   svl[3]:=svl[3]+(pres+prev)*sc_rate;
   svr[1]:='prev_Amount';
   svr[2]:='pres_Amount';
   svr[3]:='upto_Amount';
end;
end;

{
writeln;
writeln('  Variables            Values   Explanation                       ');
writeln;
writeln('  prev_Amount   :=   ',justify(svl[1],5,2,Right),'   Amount upto previous closing date');
writeln('  pres_Amount   :=   ',justify(svl[2],5,2,Right),'   Amount from previous to present closing date');
writeln('  upto_Amount   :=   ',justify(svl[3],5,2,Right),'   Amount upto present closing date');
writeln;
writeln;
writeln;
writeln('           To make use of the above output you need to have created a data');
writeln('    file using the "Edit" menu option or preferably with a standard editor');
writeln('    like NE or Edit . See the chapter on "Programming using IMS-PM+ for');
writeln('    customizing IMS-PM outputs" in your referance manual.');
}

selfile(4,1,prgname,'.PRG',1);
if nospace(prgname)='' then exit;

{$I-}
formstar(prgname+'.PRG',TD+prgname+'.OUT',svr,svl);

window(1,2,80,24);
clrscr;
if not printmode then editfile(TD+prgname+'.OUT');
{$I+}
end;

MR:
begin
windows(wout,cls);
{
smsg('Changing file format');
assign(out,PD+'TEXT.MRF');
reset(out);
assign(matinp,PD+'IPM.MRF');
rewrite(matinp);
while not eof(out) do
      begin
      readln(out,s);
      write(matinp,s);
      end;
close(matinp);
close(out);
}

sel_line(matinp,TD+'IPM.MRF',s);
if scode[7]=ENTER then
                       breakstring(s);
end;
    end;
end;

PROCEDURE checkpost;
begin
     i:=0;
     repeat
          nextkeys(c1,c2);
          if (chr(c1)<>ENTER) and (chr(c2)<>ENTER) then
                 begin
                     inc(i);
                     passwd[i]:=readkey;
                     if passwd[i]=#0 then              { error }
                                         begin
                                         passwd[i]:=readkey;
                                         if passwd[i]=F1 then help(1);
                                         end;
                 end;
     until (chr(c1) in [ENTER,ESC,'~']) or (i=10);
end;

PROCEDURE push;
var
   nilflag:boolean;

begin
pushed:=TRUE;
if memdrive then mark(heap0);
	footer:=sheet1^.activity;
        store1:=first;
        store2:=last;
	storeno:=No_act;
        strec:=sheet1^.recno;
        st_sheet:=sheet1;
        st_m:=m;
        st_hl:=hl;
        m:=1;
	hl:=1;
	qd:=sheet1^.qdone;
	if not memdrive and (sheet1^.tap<>NIL) then
		begin
                     first:=sheet1^.tap;
		     last:=first^.tap;
		     No_act:=sheet1^.tapno;
		end
		else
		   begin
			{strec:=sheet1^.recno;}
			sheet1^.tapno:=0;{Noact[sheet1^.recno]:=1;}
			No_act:=1;
                        if overflow then
                                        halt;
                        new(temp);
                        sheet1^.tap:=temp;
                        first:=sheet1^.tap;
			first^.recno:=0;
			first^.tap:=NIL;
			if overflow then halt;
                        new(sheet1);
                        memdisp;
                        initrec;
                        first^.a:=sheet1;
                        last:=sheet1;
                        last^.a:=NIL;
                        first^.tap:=last;
                        first^.tapno:=0;
			sheet1^.recno:=1;
if memdrive and (length(st_sheet^.actcode)=3) then
                     popmem(TD+proname+'.'+st_sheet^.actcode,1);
	   end;
flags[1]:=TRUE;
end;

PROCEDURE pop;
begin
pushed:=FALSE;
if length(st_sheet^.actcode)<>3
                               then
                                   begin
                                   inc(mfno);
                                   st_sheet^.actcode:=p0i(mfno,3);
                                   end;
    if (memdrive) then
                       pushmem(TD+proname+'.'+st_sheet^.actcode);

    flags[1]:=FALSE;
    Act_Q:=gt('S',d,FALSE);

    first:=store1;
    last:=store2;
    sheet1:=st_sheet;
    sheet1^.tapno:=No_act;                           { Noact[strec]:=No_act }
    sheet1^.quantity:=Act_Q;
    No_act:=storeno;
    sheet1^.qdone:=qd;
    m:=st_m;
    hl:=st_hl;
    if memdrive then release(heap0);		{1}
    memdisp;
end;

PROCEDURE init_tables;
begin
  m:=1;
  hl:=1;
  if overflow then exit;
  new(last);
  last^.a:=NIL;
  if overflow then exit;
  new(sheet1);
  initrec;
  sheet1^.a:=NIL;
  sheet1^.recno:=0;
  first:=sheet1;
  if overflow then exit;
  new(sheet1);
  initrec;
  sheet1^.a:=NIL;
  sheet1^.recno:=1;
  first^.a:=sheet1;
  last:=sheet1;
  first^.tap:=last;
  No_act:=1;
end;

PROCEDURE save(fname:string);
var
   sfile,bfile:file of sheettype1;
   i,j:integer;
   s:string;

begin
{if sflag then fname:=fname+'.DAT' else fname:=fname+'.BAK';}

if not sflag then
   begin
        assign(bfile,fname+'.BAK');
        {$I-}
        rewrite(bfile);
        {$I+}

        if ioresult=0 then
           begin
              smsg('Taking Backup...');
              for i:=1 to No_act do
	        begin
		takerec(i);
                write(bfile,sheet1^);
                if sheet1^.tapno>0 then
			begin
                        push;
			for j:=1 to No_act do
			   begin
				takerec(j);
                                write(bfile,sheet1^);
			   end;
		        pop;
                        end;
	       end;
               if sflag then close(bfile);
               copyf(proname+'.MAT','c:\pascal\BAK\'+proname+'.MAT');
           end
                else
                     smsg('Internal Error(1).'+ESC);
           exit;
   end;


smsg('Saving '+upstringf(fname)+'.DAT ...');

assign(sfile,TD+fname+'.DAT');
{$I-}
rewrite(sfile);
{$I+}

if ioresult<>0 then
       begin
	smsg('Can''t write to '+fname+'.DAT.'+ESC);
	exit;
       end;

if (diskfree(0)<500000) then     { Do it in some other intelligent way }
                     begin
                     smsg('Disk space not sufficient.'+ESC);
                     exit;
                     end;

(*
if not memok(50) then     { Do it in some other intelligent way }
                     begin
                     smsg('Memory not sufficient.'+ESC);
                     exit;
                     end;
*)

for i:=1 to No_act do
	begin
		takerec(i);
		write(sfile,sheet1^);
                if sheet1^.tapno>0 then
			begin
                        push;
			for j:=1 to No_act do
			   begin
				takerec(j);
				write(sfile,sheet1^);
			   end;
		        pop;
                        end;
	end;
close(sfile);
if memerror then exit;
copyf(TD+fname+'.DAT',fname+'.DAT');

{
copyf(TD+proname+'.RAT',proname+'.RAT');
copyf(TD+proname+'.SPD',proname+'.SPD');
}
sflag:=FALSE;
end;

PROCEDURE pushmem(fname:string);
var
   sfile:file of sheettype1;
   i,j:integer;

begin
assign(sfile,fname);
{$I-}
rewrite(sfile);
{$I+}
if ioresult<>0 then
   begin
        smsg('Fatal error : Can''t open '+fname+'.'+ESC);
        halt;
   end;

for i:=1 to No_act do
     begin
		takerec(i);
                if (i<>sheet1^.recno) then
                                    begin
                                    smsg('Fatal error : Correpted data!'+noise);
                                    halt;
                                    end;
                write(sfile,sheet1^);
	end;
close(sfile);
end;

PROCEDURE popmem(fname:string;x:integer);
var
	Lfile:file of sheettype1;
	stap,sa:pointer;
	i,j,k:integer;
        temp:boolean;
begin

{$I-}
assign(Lfile,fname);
reset(Lfile);
{$I+}

if ioresult<>0 then
               begin
               smsg('Fatal Error. Can''t open '+fname+ESC);
               No_act:=1;
               halt;
               end;
i:=x-1;
No_act:=x;
while not eof(Lfile) do
	begin
                inc(i);

                temp:=sflag;
                if i>1 then appendrec(last);
                if overflow then
                            begin
                            close(Lfile);
                            exit;
                            end;
                sflag:=temp;

                sa:=sheet1^.a;
	 	read(Lfile,sheet1^);
                if i<>sheet1^.recno then
                                    smsg(' ERR...'+ESC);
		sheet1^.a:=sa;
		sheet1^.tap:=NIL;
	end;
close(Lfile);
end;

PROCEDURE load(fname:string);
label 100;
var
	Lfile:file of sheettype1;
	stap,sa:pointer;
	i,j,k:integer;
        timer:longint;
        df:file;

begin
smsg('Loading '+upstringf(fname)+' ...');
saveguard;
sflag:=FALSE;

{$I-}
assign(Lfile,fname);
reset(Lfile);
{$I+}

if ioresult<>0 then
               begin
                    smsg('Can''t open file '+fname+'.'+ESC);
                    exit;
               end;

{***** Free diskspace for scratch files }
   findfirst(TD+'*.*',$20,filerecord);
   while doserror=0 do
         begin
             assign(df,TD+filerecord.name);
             erase(df);
             findnext(filerecord);
         end;

copyf(PD+'IPM.MRF',TD+'IPM.MRF');

memdrive:=FALSE;

release(heap);
init_tables;
No_act:=1;
i:=0;
while not eof(Lfile) do
	begin
                inc(i);
                if i>1 then appendrec(last);
                sa:=sheet1^.a;
                {$I-}
	 	read(Lfile,sheet1^);
                {$I+}

                if ioresult<>0 then
                   begin
                   smsg('Illegal file format.'+ESC);
                   halt;
                   end;

		sheet1^.a:=sa;
		k:=sheet1^.tapno;
		sheet1^.tap:=NIL;
                sheet1^.recno:=i;
                if k>0 then
                begin
                if optmem then mark(heap0);              {MEMHANDLER}
                sheet1^.actcode:=p0i(sheet1^.recno,3);
                sheet1^.stat:=0;

                     push;
                     if k>0 then No_act:=1;
                       for j:=1 to k do
			   begin
                               if j>1 then appendrec(last);
                               if overflow then

                                  begin
                                  if flags[9] then
                                     begin
                                          close(Lfile);
                                          optmem:=TRUE;
                                          sflag:=FALSE;
					  smsg('Optimizing memory...');
                                          delay(3000);
					  flags[9]:=FALSE;
                                          load(fname);
					  exit;
                                     end
                                     else
                                     begin
                                     smsg('Not Enough memory. Could not load '+fname+ESC);
                                             close(Lfile);
					     release(heap);
					     proname:='';
					     exit;
                                     end;
                                  end;

                             sa:=sheet1^.a;
{$I-}
 			     read(Lfile,sheet1^);
{$I+}
if ioresult<>0 then
100:                              begin
                                     smsg('Illegal file format.'+ESC);
                                     release(heap);
                                     proname:='';
                                     exit;
                                  end;

{ **************************** Begin Data file update }

                              with sheet1^ do
                                  begin
if stat=1 then st_sheet^.stat:=st_sheet^.stat+1;

{ remove the next line : Added on 26/10/96 }
if (cd[1]=0) then begin cd[2]:=0; cd[3]:=0; end;

                                  end;

{ **************************** End Data file update }



		    sheet1^.a:=sa;
		   end;
                           			{MEMHANDLER}
                  if optmem then
                           pushmem(TD+proname+'.'+p0i(strec,3));
		  pop;
		  if optmem then release(heap0);    	{MEMHANDLER}
		end;
           end;

close(Lfile);
sflag:=FALSE;
window(1,2,80,24);

copyf(proname+'.MAT',TD+proname+'.MAT');
smsg(upstringf(fname)+': File successfully loaded into memory.');

vs(60,1,'                   ',123);
vs(60,1,fixlength(upstringf(proname+'.DAT'),19,RIGHT),123);

wait;
msg('');
if optmem then memdrive:=TRUE;

mfno:=No_act;
end;
                       { *** End of Sheet PROCEDURE *** }

procedure pixel(col1,col2:byte);
var
   i:integer;
begin
for i:=(hl+3)*160+col1*2-1 to (hl+3)*160+col2*2-1 do
           begin
           if odd(i) then mem[Vseg:i]:=106;
           end;
end;

procedure pixcols(sheettype:integer;var lim:integer);
begin
case sheettype of
               SA:lim:=5;
               QS:lim:=7;
               TR:lim:=4;
            end;

        case sheettype of
               SA:case hc of
                       1:begin col1:=2; col2:=8; end;
                       2:begin col1:=10; col2:=50; end;
                       3:begin col1:=52; col2:=57; end;
                       4:begin col1:=59; col2:=68; end;
                       5:begin col1:=70; col2:=79; end;
                       end;
               QS:case hc of
                       1:begin col1:=2; col2:=7; end;
                       2:begin col1:=9; col2:=18; end;
                       3:begin col1:=20; col2:=28; end;
                       4:begin col1:=30; col2:=38; end;
                       5:begin col1:=40; col2:=48; end;
                       6:begin col1:=50; col2:=58; end;
                       7:begin col1:=60; col2:=68; end;
                       8:begin col1:=70; col2:=79; end;
                       end;
               TR:case hc of
                       1:begin  col1:=2;  col2:=8; end;
                       2:begin col1:=10; col2:=52; end;
                       3:begin col1:=54; col2:=62; end;
                       4:begin col1:=64; col2:=72; end;
                       end;
               end;

end;

procedure interchange(var x1,x2:integer);
var
   t:integer;
begin
     t:=x1;
     x1:=x2;
     x2:=t;
end;

procedure copyactrec(sn,rn:integer);
begin
if sn>No_act then exit;
if (purpose=0) and (sn<=No_act) then
	begin
		takerec(sn);
                if excode<>ESC then
                begin
		if rn>No_Act+1 then rn:=No_act+1;
		if rn<1 then rn:=1;
		temp:=sheet1;
		insrec(first,last,rn);
		copyrec(sheet1,temp);
                sheet1^.actcode:='.....';
                end
                else excode:=#0;
        end;

     if (purpose=1) and (sn<=No_act) then
	begin

	        takerec(sn);
                if excode<>ESC then
                begin
		if rn>No_Act+1 then
                               begin
                               rn:=No_act+1;
                               insrec(first,last,rn);
                               end;

		if rn<1 then rn:=1;
		temp:=sheet1;

                takerec(rn);

                if temp<>sheet1 then
                {
                takerec(rn);
                temp2:=sheet1;
                push;
                if sheet1^.a<>NIL then
                repeat
                      sheet1:=sheet1^.a
                until sheet1^.a=NIL;
                sheet1^.a:=temp^.tap;
                temp2^.tapno:=temp2^.tapno+temp^.tapno;
                sheet1:=first^.a;
                if sheet1^.a<>NIL then
                repeat
                      sheet1:=sheet1^.a
                until sheet1^.a=NIL;
                first^.tap:=sheet1;
                pop;
                }

                if (temp<>sheet1) and (length(temp^.actcode)=3) then
                begin
                {
                smsg('Copy contents ? Y/N');
                if yes then
                   begin
                }

                   sheet1^.tap:=temp^.tap;
                   sheet1^.tapno:=temp^.tapno;
                   inc(mfno);
                   sheet1^.actcode:=p0i(mfno,3);
if optmem then
           copyf(TD+proname+'.'+temp^.actcode,TD+proname+'.'+sheet1^.actcode)
           else
           smsg('Can''t do this operation while ''Optimize Speed'' is set ON.'+noise);

                end;
	end
                        else excode:=#0;
        end;
end;

PROCEDURE moveoresc(sheettype:integer);
label 	200,300;

var
   x1,x2:integer;
   z,cn,sn:integer;
   s1,s2:string[18];

var
   s:string;
   specialkey:boolean;
   lim,rn,k:integer;
   temp,temp2,tsheet:psheettype1;

begin
excode:=#0;
if purpose=0 then
   begin
   if sheettype in [BM,SC_A,SC_D,SR] then
                                  purpose:=1
                              else
                                  purpose:=0;
   end;

300:
specialkey:=FALSE;
if not (sheettype in [BM,MR])  then bymenu(sheettype);
if purpose=0 then
   begin
   pixcols(sheettype,lim);
   pixel(col1,col2);
   end;

if (sheettype=SR) then
begin
tsheet:=sheet1;
takerec(m+hl-1);
     with sheet1^ do
          begin
          s1:=subname;
          date2str(cd,s2);
     vs(3,17,'Subcontractor''s Name : '+fixlength(sub_id,18,Left),textattr);
     vs(3,18,'Closing date         : '+fixlength(s2,18,LEFT),textattr);
     end;
sheet1:=tsheet;
end;

if (sheettype in [SC_A,SC_D]) then c:=ESC else KSreadkey(1,c,specialkey);
200:

errorflag:=FALSE;
{if purpose=0 then sflag:=TRUE;}
if c=ESC then
          begin
          excode:=ESC;
          exit;
          end;

if specialkey then
case c of
	  F8   : printinput;
          F9   : if (sheettype in [SA,TR]) then save(proname)
                    else
                     begin
                          msg(' Option disabled. Press "ESC" + "F9".'+noise+noise);
                          wait;
                     end;
     Up   : moveup;
     Down : movedown;

     Left : if (purpose=0) and (sheettype in [SA,QS,TR])  then
                   if hc>1 then dec(hc) else hc:=lim;
     Right: if (purpose=0) and (sheettype in [SA,QS,TR]) then
                   if hc<lim then inc(hc) else hc:=2;
     F6   :
     begin
          sn:=m+hl-1;
          rn:=m+hl-1;
          s:=strint(sn,1)+'..'+strint(sn,1);
                readstr(1,'Copy from range : ',s);
                if excode<>ESC then
                begin
                if pos('..',s)=0 then
                   begin
                     val(s,x1,error);
                     x2:=x1;
                   end
                else
                    begin
                      val(copy(s,1,pos('..',s)-1),x1,error);
                      val(copy(s,pos('..',s)+2,length(s)-pos('..',s)+2),x2,error);
                      if x2<x1 then interchange(x1,x2);
                      if (x1<0) then x1:=1;
                      if (x2>No_act) then x2:=No_act;
                    end;
                    readint(1,'Copy to record no : ',rn);

                      for k:=x1 to x2 do
                         begin
                         if (purpose=0) and (rn<=x1) then sn:=k-x1 else sn:=0;
                         copyactrec(k+sn,rn+k-x1);
                         end;

                      if purpose=0 then
                      begin
                      smsg(' Copy contents ? Y/N ');
                       if yes then
                          begin
                             purpose:=1;
                              for k:=x1 to x2 do
                              begin
                              copyactrec(k+sn,rn+k-x1);
                              end;
                             purpose:=0;
                          end;
                      end;
                    end;
     end;

     F3   :
     begin
     if (purpose=0) and (m+hl-1<=No_act) then
	begin
		takerec(m+hl-1);
		rn:=m+hl-1;
                temp:=sheet1;

                if hc>1 then cn:=hc-1;

                s:='';
                readstr(1,'Copy to range : ',s);

                if excode<>ESC then
                begin
                if pos('..',s)=0 then
                   begin
                     val(s,x1,error);
                     x2:=x1;
                   end
                else
                    begin
                      val(copy(s,1,pos('..',s)-1),x1,error);
                      val(copy(s,pos('..',s)+2,length(s)-pos('..',s)+2),x2,error);
                      if x2<x1 then interchange(x1,x2);
                    end;

                if (x1<0) then x1:=1;
                if (x2>No_act) then x2:=No_act;

                takerec(x1);

                if sheettype =QS then
                for z:=x1 to x2 do
                    begin
                    takerec(z);
                    case cn of
                         1: sheet1^.code:=temp^.code;
                         2: sheet1^.length:=temp^.length;
                         3: sheet1^.breadth:=temp^.breadth;
                         4: sheet1^.height:=temp^.height;
                         5: sheet1^.AddQ:=temp^.AddQ;
                         6: sheet1^.SubQ:=temp^.SubQ;
                    end;
                    with sheet1^ do Quantity:=Length*Breadth*Height+addQ-subQ;
                    end;

IF SHEETTYPE=SA THEN
                for z:=x1 to x2 do
                    begin
                    takerec(z);
                    case cn of
                         1: sheet1^.activity:=temp^.activity;
                         2: sheet1^.munit:=temp^.munit;
                         3: sheet1^.sd:=temp^.sd;
                         4: sheet1^.fd:=temp^.fd;
                    end;
                    end;
                end
                   else excode:=#0;
        end;
        end;

     F7: if purpose=0 then delrec(first,last,m+hl-1);
     F5: if purpose=0 then insrec(first,last,m+hl-1);

     pgdn:
		if (No_act>10) then
		if (m+9)<No_act then
			begin
                        m:=m+9;
                        if No_act-m<10 then hl:=No_act-m+1;
                        end
			else
				begin
                                     m:=No_act;
                                     hl:=1;
                                end;
     pgup:
	     if (m-9)>1 then
			m:=m-9
			else
                            begin
                            m:=1;
                            hl:=1;
                            end;
end
else
begin
if (sheettype=SR) and (c=ENTER) then
	begin
        sflag:=TRUE;
	if No_act>0 then
                begin
                 takerec(m+hl-1);
		 with sheet1^ do
		 if stat=0 then
			begin
				stat:=1;
                                {# Assumed st_sheet^.stat is free }
                                st_sheet^.stat:=st_sheet^.stat+1;
                                sub_id:=subname;
				qd:=qd+quantity;
				cd[1]:=d[1];
				cd[2]:=d[2];
				cd[3]:=d[3];
			end
                 else
          if (passwd[1]='I') and (passwd[1]='M') and (passwd[1]='S')
             then
                    begin
                    smsg('Are you sure what you are doing. Confirm ? Y/N');
		       if yes then
				begin
				sheet1^.stat:=0;
                                if st_sheet^.stat>0 then
                                   st_sheet^.stat:=st_sheet^.stat-1;
                                sub_id:='';
                                cd[1]:=0;
				cd[2]:=0;
                                cd[3]:=0;
				qd:=qd-sheet1^.quantity;
				end;
                    end
                    else
                    begin
                         box(29,11,51,13,0,white);
                         vs(31,12,'Enter your password',NBlink);

msg('Be sure about what you are doing. Press ESC to cancel.');
checkpost;
     if (chr(c1)<>ESC) and (chr(c1)<>'~') then
               begin
                    clearbuffer;
                    passwd[0]:=chr(i);
                    if passwd='IMS' then
				       begin
				       sheet1^.stat:=0;
                                       if st_sheet^.stat>0 then
                                          st_sheet^.stat:=st_sheet^.stat-1;

                                       sub_id:='';
                                       cd[1]:=0;
				       cd[2]:=0;
                                       cd[3]:=0;
				       qd:=qd-sheet1^.quantity;
				       end
                                     else
                    begin
                    vs(30,12,'   Intruder Alert!   ',RBlink);
                    repeat
                    smsg('You are not authorized to perform current task'+noise);
                    nextkeys(c1,c2);
                    if keypressed then KSreadkey(1,c,speckey);
                    until (chr(c1)='~') or (chr(c2)='~') ;
              end;
           end;
           end;
	  end;
end;

if (purpose=1) and (sheettype=SA) then
               begin
		   takerec(m+hl-1);
		   c:=#255;
                   excode:=ENTER;
		   exit;
               end;

if purpose=0 then
begin
if (not specialkey and (c in alphaset)) or (c=#13) then
     begin
     if No_act>0 then takerec(m+hl-1) else insrec(first,last,1);
     with sheet1^ do
     begin

     if hc>1 then choice[7]:=hc-1 else choice[7]:=1;
     if (hc=1) and (sheettype=TR) then choice[7]:=2;
     if hc<>1 then scode[7]:=#13;

     repeat
        nabt;
	menufill(sheettype); { #}
	if hc=1 then
	begin
        SCODE[7]:=nocheck;
        if not((not specialkey and (c in alphaset)) {and (choice[7]=1)}) then
		begin
		msgno:=0;
		boxpix(1,menus,'',19,17,44,17+num-1,1,choice[7],scode[7],1);
                urgentservice(scode[7]);
		if speckey then
			if (scode[7] in [F5,F6,F7]) then
					begin
					c:=scode[7];
					goto 200;
					end;
		end
		else
			begin
			scode[7]:=c;
                        c:=#0;
			speckey:=FALSE;
			end;
	end
        else scode[7]:=c;
        buflen:=26;

        if (hc=1) and (scode[7] in alphaset) and not Speckey then
                    begin
			gotoxy(19,17+choice[7]-1);
			fastwrite(' ',26,Norm);

			if not errorflag then
			    begin
                                readksbuff:='A';
			        KSbuff:=scode[7];
			    end
                            else
                                KSbuff:='';

                           KSread(29,'CON',KSBuff,excode);
                           readKSbuff:=NOREAD;
		        if excode<>ESC then selectread(sheettype);
		    end
                     else
		    if (scode[7]=#13) or (hc<>1) then
			begin
                        buflen:=70;
                        textcolor(white);
                        textbackground(black);
                        vs(1,25,FIXLENGTH(' Edit : ',80,LEFT),textattr);
                        if (hc<>1) and (scode[7]<>#13) then
                        begin
                        gotoxy(9,25);
			if not errorflag then
			    begin
                                readksbuff:='A';
			        KSbuff:=scode[7];
			    end
                              else KSbuff:='';

                           lotread:=TRUE;
                           KSread(29,'CON',KSBuff,excode);
                           lotread:=FALSE;

                           case excode of
                                Left : if hc>2 then dec(hc) else hc:=lim;
                                Right: if hc<lim then inc(hc) else hc:=2;
                                Up:if hl>1 then dec(hl);
                                Down:if hl<9 then inc(hl);
                                 end;

                           readKSbuff:=NOREAD;

                        end
                           else
                               readksbuff:='E';

                        if excode<>ESC then selectread(sheettype) else msg('');
                        textattr:=Norm;
                        end;

        until (scode[7]=ESC) or aborted or (hc<>1);
        end
        end
     end;
end;
buflen:=78;
window(2,5,79,21);
end;

PROCEDURE sheet(sheettype:integer);
var
   i,j:integer;
begin
if not (sheettype in [SC_A,SC_D]) then
   begin
   textattr:=11;
   window(1,2,80,24);
   clrscr;
   textattr:=126;
   window(1,16,80,24);
   clrscr;
   textattr:=11;
   end;

if nospace(proname)='' then exit;
case sheettype of
     SA:num:=4;
     QS:num:=6;
     TR:num:=3;
     end;

drawtable(sheettype);
if sheettype in [CB,MR] then  exit;
repeat
      nabt;
      writetable(sheettype);
      memdisp;
      moveoresc(sheettype);
until (c=ESC) {or (excode=ESC)} or (c=#255) or (sheettype in [BM]);
end;

		     {  Starting procedures and functons  }

PROCEDURE writedes_string(s:string);
var i,j,k:integer;
begin
k:=length(s);
for i:=1 to (k div 15+1) do
         begin
             for j:=1 to 15 do
                 if (i-1)*15+j<=k then write(s[(i-1)*15+j]);
             writeln;
         end;
end;

PROCEDURE notnow;
begin
smsg('Sorry!. Unable to execute your command at present.');
wait;
end;

PROCEDURE sel_name_date(x,y:byte;prompt:string;namelist:atype1;no_names:integer;var sels:string);
var
   screen:image;
   sattr:integer;
   ch,st_no_names:integer;
begin
put(screen);
scode[9]:=#0;
choice[9]:=1;
hv[1]:=1;
ch:=1;
st_no_names:=no_names;
if no_names>10 then no_names:=10;

if st_no_names=0 then
                   scode[9]:=ESC
else
begin
      shadow:=TRUE;
      box(x,y,x+37,y+no_names+1,single,28);
      gotoxy(x+(37-length(prompt)) shr 1,y);
      sattr:=textattr;
      textcolor(white);
      textbackground(blue);
      write(prompt);
      textattr:=sattr;

      for i:=1 to st_no_names do       { move out of loop }
               menus^[i]:=' '+fixlength(namelist[i],35,LEFT);
               menus^[st_no_names+1]:='';
repeat
      nabt;

      {repeat}
      {scode[9]:=#0;}
      msgno:=0;
      scode[9]:=NOCHECK;
{     boxpix(1,menus,'',x+1,y+1,x+36,y+no_names,1,choice[9],scode[9],1);}
      boxpix(1,menus,'',x+1,y+1,x+36,y+no_names,hv[1],ch,scode[9],1);
      urgentservice(scode[9]);
                   {**}
		   case scode[9] of
		       up: if (ch=10) and (hv[1]>1) then
					begin
					dec(hv[1]);
					ch:=1;
					end
					else
                                        if (ch=10)
                                             then ch:=1;
		     down: if (ch=1) then
                           if (hv[1]+10<=st_no_names) then
					begin
					inc(hv[1]);
					ch:=10;
					end
					else
                                        ch:=10;
		       end;

                   if (nospace(menus^[hv[1]+ch-1])='') and
                                              (ch>1) then ch:=no_names;

      if scode[9]=ENTER then
		sels:=upstringf(nospace(namelist[hv[1]+ch-1]));
                { change on 26/10/96 ch => hv[1]+ch-1 }

until (scode[9] in [ESC,ENTER]);
end;
get(screen);
end;

PROCEDURE sel_date(sheettype,x,y:byte);
var
	found:boolean;
	z:integer;
        index,errindex:integer;
        d1,d2:datetype;
        i,j:integer;

begin
scode[9]:=#0;
for i:=1 to 150 do
            datelist[i]:='';

k:=1;
no_dates:=0;
errindex:=0;

for i:=1 to No_act do
	begin
		takerec(i);
		push;
             	for j:=1 to No_act do
		         begin
			      takerec(j);
		   with sheet1^ do
                   begin

                   { Check mismatch in subcontractor name list }
                   if DataCheck and (uns(sub_id)<>'') then
                             begin
                             found:=FALSE;
                             for index:=1 to no_names do
                                if uns(sub_id)=uns(namelist[index]) then found:=TRUE;

                             if not found then
                                begin
                                if errindex>0 then
                                   for index:=150 downto 151-errindex do
                                       if sub_id=namelist[151-errindex] then
                                               found:=TRUE;
                                if not found then
                                   begin
                                   if errindex<150 then inc(errindex);
           smsg('E.100 : '+sub_id+' not found in '+proname+'.SNL'+ESC);
                                namelist[151-errindex]:=sub_id;
                                   end;
                                end;
                             end;


                   { Fill datelist }
		   if   (checkvaldate(cd[1],cd[2],cd[3]) and (stat=1)
                   and ((sheettype=100) or (not(sheettype in [SC_A,SC_D]) or
                   ((sheettype in [SC_A,SC_D]) and (uns(sub_id)=uns(subname)))))) then
			      begin
				date2str(cd,s);
				found:=FALSE;
				for z:=1 to k do
					if datelist[z]=s then found:=TRUE;
				if not found then
					begin
					     datelist[k]:=s;
					     inc(k);
					     inc(no_dates);
					end;
			      end;
			end;
                        end;
		pop;
	end;

{ Sort }
for i:=1 to no_dates-1 do
    for j:=i+1 to no_dates do
    begin
    str2date(datelist[i],d1[1],d1[2],d1[3]);
    str2date(datelist[j],d2[1],d2[2],d2[3]);

    datecheck(d1[1],d1[2],d1[3],d2[1],d2[2],d2[3],dater);
    if dater<0 then
               begin
               s:=datelist[i];
               datelist[i]:=datelist[j];
               datelist[j]:=s;
               end;
    end;
    errorflag:=FALSE;

sel_name_date(x,y,'Closing Date',datelist,no_dates,s);
end;

PROCEDURE mybackground(x,y:byte);
var
	mode:byte;
begin
if lastmode<>mono then textbackground(x) else textbackground(y);
end;

PROCEDURE update_namelist;
{ Load latest subcontractors's names from PROJECT.SNL }
  var
     snlfile:text;
     excode:char;
     i:integer;
  begin

  no_names:=0;

(*  if not exist(proname+'.SNL') then
			begin
			setfile(snlfile,s,proname+'.SNL','W',excode);
			if excode=ESC then  exit;
                        close(snlfile);
			end;
*)

  setfile(snlfile,s,proname+'.SNL','R',excode);

  if excode<>ESC then
       begin
            i:=1;
              while not eof(snlfile) do
			begin
			readln(snlfile,namelist[i]);
                        namelist[i]:=uns(namelist[i]);
			if namelist[i]<>'' then inc(i);
			end;
	      close(snlfile);
	      no_names:=i-1;
       end
          else
              msg('E.3: Can''t not open '+proname+'.SNL.'+ESC);
  end;

PROCEDURE saveguard;
begin
if sflag then
    begin
	msgattr:=Norm;
	smsg(' Current project file not saved. Save (Y/N)? '+noise);
	msgattr:=rvse;
	if yes then
                  save(proname);
	msg('');
    end;
end;

PROCEDURE urgentservice(var request:char);
begin
if not flags[10] then exit;
if Speckey then
case request of
F9: save(proname);
F10:
    begin
         if PUSHED then pop;
         saveguard;
         halt;
    end;
end;
excode:=#0;
end;

PROCEDURE printinput;
label EXITPRO;
var
   i:integer;

procedure printsingle;
var
   j:integer;

begin
writeln(lst,ESC,chr(69));
with st_sheet^ do  writeln(lst,p0i(recno,3),' ',
		      fixlength(activity,36,LEFT),' ',
		      fixlength(munit,4,LEFT),' ',
		      p0i(sd[1],2),'/',
                      p0i(sd[2],2),'/',
		      p0i(sd[3],2),' ',
                      p0i(fd[1],2),'/',
                      p0i(fd[2],2),'/',
		      p0i(fd[3],2),' ',c_rate:6:2,' ',sc_rate:6:2);

writeln(lst,ESC,chr(64));
writeln(lst);

for j:=1 to No_act do
	begin
		takerec(j);
		with sheet1^ do
		    begin
		    if (stat=1) then write(lst,'û') else write(lst,' ');
writeln(lst,fixlength(code,8,LEFT),' ',length:8:2,
			' ',breadth:8:2,' ',height:8:2,' ',
				addQ:8:2,' ',subQ:8:2,' ',quantity:10:2);
		    end;
        if Ubreak then exit;
	end;
	writeln(lst);
writeln(lst,' ':70,gt('S',d,FALSE):10:2);
end;

begin
if (proname='') or not PrinterReady then exit;
msg('Printing...');
{$I-}

if pushed then       { Inside QA sheet F8 = Print items for single ACT. }
          begin
               printsingle;
               exit;
          end;

n:=length('Printout of input data for '+upstringf(proname)+'.DAT'+' taken on '+date+' at '+time);
writeln(lst,ESC,chr(13));
writeln(lst,ESC,chr(69));
writeln(lst,'Printout of input data  for '+upstringf(proname)+'.DAT'+' taken on '+date+' at '+time);
writeln(lst,ESC,chr(64));
writeln(lst);

for i:=1 to No_act do
	begin
        if (ioresult<>0) or Ubreak then exit;
	takerec(i);

with sheet1^ do
     begin
writeln(lst,ESC,chr(69));
writeln(lst,p0i(recno,3),' ',fixlength(activity,36,LEFT),' ',fixlength(munit,4,LEFT),' ',
		      p0i(sd[1],2),'/',
                      p0i(sd[2],2),'/',
		      p0i(sd[3],2),' ',
                      p0i(fd[1],2),'/',
                      p0i(fd[2],2),'/',
		      p0i(fd[3],2),' ',c_rate:6:2,' ',sc_rate:6:2);
writeln(lst,ESC,chr(64));
writeln(lst);
push;
printsingle;
pop;
if Ubreak then goto EXITPRO;
end;
end;

EXITPRO:
{$I+}
msg('');
end;


begin
{Config}
optmem:=TRUE;
printmode:=FALSE;
col80:=TRUE;
adjust:=FALSE;
end.


{ # While copying scan source record for error making fields  }
{ # Check validity of dates before generating reports         }
{ # gt true only when used inside a push - pop }
