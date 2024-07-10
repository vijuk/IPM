
{
uses scode 1,2
fileflag=1   .MPL       Material purchase
         2   .RAT       Material rates
         3   .CIO       cash inflow outflow
}

{$O+}
unit cash;
interface
uses lib,crt,ilib,olib;
const
        fileflag:byte=1;

type
    raterectype=
		record
                      mat:string[25];
                      muni:string[4];
		      case boolean of
                      TRUE :
                           (
                           pdate:datetype;
                           purchord,delino:integer;
                           qty:real;
                           );
                      FALSE:
                            (
                             rate:real;
                             cashp:array[1..2] of real;
                             days:array[1..2] of integer
                            );
		end;

var
    datamatf:file of raterectype;

const
    datamat:raterectype=
                    (mat:'';
                     muni:'';
                     rate:0;
                     cashp:(0,0);
                     days:(0,0)
                    );

procedure editrec;

implementation
const
	NM:integer=0;
	datano:integer=0;

var
   ext:string[4];

procedure gf(datano:integer);          { Gets file record for reading }
begin
  seek(datamatf,datano);
{$I-}
  read(datamatf,datamat);
{$I+}
if ioresult<>0 then
		begin
		msg(strint(datano,3)+' : File seek error. Press ESC.');
		waitfor(ESC);
		end;
end;

procedure wf(datano:integer);
begin
{$I-}
  seek(datamatf,datano);
  write(datamatf,datamat);
{$I+}
if ioresult<>0 then
		begin
		msg('File seek error. Press ESC.');
		waitfor(ESC);
		end;
end;

        procedure initrec;
        begin
           with datamat do
              begin
                    mat:='';
                    muni:='';
                    if (fileflag in [1,3]) then
                       begin
                       purchord:=0;
                       delino:=0;
                       qty:=0;
                       pdate[1]:=0;
                       pdate[2]:=0;
                       pdate[3]:=0;
                       end
                       else
                           begin
                            rate:=0;
                            cashp[1]:=100;
                            cashp[2]:=0;
                            days[1]:=0;
                            days[2]:=0;
                           end;
              end;
        end;


procedure selectread(choice:integer);
begin
with datamat do
if fileflag=1 then
case choice of
     1: readstr(1,' Edit : ',mat);
     2: readint(1,' Edit : ',purchord);
     3: readint(1,' Edit : ',delino);
     4: begin
             date2str(pdate,s);
             readstr(1,'Edit : ',s);
             str2date(s,pdate[1],pdate[2],pdate[3]);
        end;
     5:
       readreal(1,' Edit : ',qty);
     6:
       begin
       buflen:=4;
       readstr(1,' Edit : ',muni);
       end;
     end
else
if fileflag=2 then
case choice of
     1: readstr(1,' Edit : ',mat);

     2:
       begin
       buflen:=4;
       readstr(1,' Edit : ',muni);
       end;
     3:readreal(1,' Edit : ',rate);
     4:readreal(1,' Edit : ',cashp[1]);
     5: readint(1,' Edit : ',days[1]);
     6:readreal(1,' Edit : ',cashp[2]);
     7: readint(1,' Edit : ',days[2]);
    end
else
if fileflag=3 then
case choice of
     1: begin
             date2str(pdate,s);
             readstr(1,'Edit : ',s);
             str2date(s,pdate[1],pdate[2],pdate[3]);
        end;
     2: readreal(1,' Edit : ',qty); { cash }
     end;
end;


procedure editrec;
label 200;
var
	i,no:integer;
	flag,screenchanged:boolean;
	screen1:image;
	s:string;
        matlist:stringlines;
	stc:integer;

        procedure fillmenu;
        var j:integer;
        begin
        with datamat do
case fileflag of
1:
begin
     date2str(pdate,s);
     menus^[1]:=mat;
     menus^[2]:=strint(purchord,1);
     menus^[3]:=strint(delino,1);
     menus^[4]:=s;
     menus^[5]:=strreal(qty,1,2);
     menus^[6]:=muni;
end;
2:
 begin
       menus^[1]:=mat;
       menus^[2]:=muni;
       menus^[3]:=justify(rate,1,2,LEFT);
       menus^[4]:=strreal(cashp[1],1,2);
       menus^[5]:=strint(days[1],1);
       menus^[6]:=strreal(cashp[2],1,2);
       menus^[7]:=strint(days[2],1);
 end;
3:
begin
     date2str(pdate,s);
     menus^[1]:=s;
     menus^[2]:=strreal(qty,1,2);
end;
end;
        end;

procedure addrec;
begin
inc(NM);
wf(datano);
wf(NM);
datano:=NM;
gf(datano);
initrec;
end;

procedure copyrec;
begin
inc(NM);
wf(datano);
wf(NM);
msg('Data copied to record no: '+p0i(NM+1,3));
end;


procedure delrec;
var
    copymatf:file of raterectype;
    i:integer;

begin
if datano<0 then exit;
msg('Record no: '+p0i(datano+1,3)+' will be deleted. Sure ? (Y/N) ');
		if yes then
			begin
                        reset(datamatf);
                        assign(copymatf,TD+'TEMP.IPM');
                        rewrite(copymatf);
                        for i:=0 to NM do
                            begin
                            read(datamatf,datamat);
                            if i<>datano then write(copymatf,datamat);
                            end;
                        close(datamatf);
                        close(copymatf);
                        copyf(TD+'temp.ipm',TD+proname+ext);
                        assign(datamatf,TD+proname+ext);
                        reset(datamatf);
                        dec(NM);
                        if datano>NM then datano:=NM;
                        gf(datano);
			end;
		msg('');
end;

procedure prevrec;
          begin
		if (datano>0) then
		   begin
		   wf(datano);
                   dec(datano);
		   gf(datano);
                   end
                   else msg(noise);
	  end;

procedure nextrec;
          begin
		if (datano<NM) then
                   begin
			wf(datano);
			inc(datano);
			gf(datano);
                   end
		   else
			msg(noise);
 	  end;

procedure selectrec;
var i,tem:integer;
          begin
          wf(datano);
          assign(matlist,TD+'MAT.LST');
          rewrite(matlist);

case fileflag of
1:s:=' Material     P.O.     Deli.No.     Date       Quantity    Unit ';
2:s:=' Material     Unit     Rate        Cash %      On      Cash %    On ';
3:s:=' Date         Amount ';
  end;

  write(matlist,s);

	  for i:=0 to NM do
                   begin
                         gf(i);
                         fillmenu;
                         s:='';
                         for j:=1 to no do s:=s+'  '+menus^[j];
                   write(matlist,s);
                   end;
          close(matlist);

          s:='MATLIST';
          stc:=choice[7];
          sel_line(matlist,TD+'MAT.LST',s);
          tem:=(hv[1]+choice[7]-3);
          if  (tem>=0) and (tem<=NM) then datano:=tem;
          gf(datano);
          choice[7]:=stc;
          get(screen1);
          {writeln(s);}
          screenchanged:=TRUE;
          end;

procedure service(c:char);
  	begin
if speckey  then
	begin
        screenchanged:=FALSE;
	case c of
		F5: choice[2]:=1;
		F6: choice[2]:=2;
		F7: choice[2]:=3;
		F8: choice[2]:=4;
		F9: choice[2]:=5;
	       F10: choice[2]:=6;
               pgup:choice[2]:=4;
               pgdn:choice[2]:=5;
             end;
	if c in [F5,F6,F7,F8,F9,F10] then
                                         begin
                                         c:=#255;
                                         scode[2]:=LEFT;
                                         end
        else
            if c in [pgup,pgdn] then c:=#255;
end;

if (c=ENTER) or (c=#255) then
       case choice[2] of
	1:      addrec;
        2:      copyrec;
	3:      delrec;
	4:      prevrec;
	5:      nextrec;
	6:      selectrec;
	end;

end;

begin
if proname='' then exit;
initrec;
case fileflag of
     1:ext:='.MPL';
     2:ext:='.RAT';
     3:ext:='.CIO';
end;

if exist(proname+ext) then
   copyf(proname+ext,TD+proname+ext);
assign(datamatf,TD+proname+ext);

{$I-}
reset(datamatf);
{$I+}

if ioresult<>0 then
           begin
              rewrite(datamatf);
              write(datamatf,datamat);
           end;

datano:=0;
NM:=filesize(datamatf)-1;
gf(datano);
choice[1]:=1;
get(screen);
put(screen1);

200:

for i:=1 to 6 do
	box(65,3+(i-1)*3,78,5+(i-1)*3,single,54);
menus^[11]:=' F5 Append  ';
menus^[12]:=' F6 Copy    ';
menus^[13]:=' F7 Remove  ';
menus^[14]:=' F8 Previous';
menus^[15]:=' F9 Next    ';
menus^[16]:='F10 Select  ';

flags[10]:=TRUE;
scode[2]:=#250;
boxpix(1,menus,'ACRPNS',66,4,77,19,11,choice[2],scode[2],3);
choice[2]:=1;
scode[2]:=LEFT;
{window(7,4,57,4);}

scode[1]:=#250;
textcolor(yellow);

case fileflag of
1:
  begin
    vs(3, 4,'Material',textattr);
    vs(3, 7,'    P.O.',textattr);
    vs(3,10,'Deli.No.',textattr);
    vs(3,13,'    Date',textattr);
    vs(3,16,'Quantity',textattr);
    vs(3,19,'    Unit',textattr);
    no:=6;
  end;
2:
  begin
   vs(3,4,'Material',textattr);
   vs(3,7,'    Unit',textattr);
   vs(3,10,'    Rate',textattr);
   vs(3,13,'  Cash %',textattr);
   vs(3,16,'      On',textattr);
   vs(3,19,'  Cash %',textattr);
   vs(3,22,'      On',textattr);
   no:=7;
  end;
3:
  begin
   vs(3,4,'    Date',textattr);
   vs(3,7,'  Amount',textattr);
   no:=2;
  end;
end;

for i:=1 to no do
    box(12,i*3,50,i*3+2,0,brown);

ScreenChanged:=FALSE;

repeat

repeat
buflen:=25;
vs(55,22,'Current page : '+p0i(datano+1,3)+'/'+p0i(NM+1,3),lightred);
fillmenu;
for j:=1 to no do menus^[j]:=' '+fixlength(menus^[j],36,LEFT);
if scode[2]=LEFT then  scode[1]:=NOCHECK;
	boxpix(1,menus,'',13,4,36,4+(no-1)*3,1,choice[1],scode[1],3);
       	if (scode[1] in [#32..#127]) and not Speckey
		then
			begin
			fastwrite(' ',37,textattr);
			readksbuff:='A';
			KSbuff:=scode[1];
                        if ((fileflag=1) and (choice[1]=6)) or
                           ((fileflag=2) and (choice[1]=2)) then buflen:=4;

			KSread(29,'CON',KSBuff,excode);
			readKSbuff:=NOREAD;
			selectread(choice[1]);
			readKSbuff:=#0;
			if choice[1]<7 then
                                       choice[1]:=choice[1]+1;
			end
		else
		if scode[1]=ENTER then
			begin
			readKSbuff:='E';
			selectread(choice[1]);
			readKSbuff:=#0;
                        end
                else
                        begin
                        service(scode[1]);
                        if (scode[1]<>ESC) and screenchanged then goto 200;
                        end;
{
if speckey then
                if scode[1]=pgup then prevrec
            else
                if scode[1]=pgdn then nextrec;
}

aborted:=FALSE;
until (scode[1] in [ESC,RIGHT {,#250}]);

if (scode[1] in [RIGHT {,#250}]) then
	repeat
	scode[2]:=NOCHECK;
	boxpix(1,menus,'ACRPNS',66,4,77,19,11,choice[2],scode[2],3);
        service(scode[2]);
	aborted:=FALSE;

if screenchanged then goto 200;
vs(55,22,'Current page : '+p0i(datano+1,3)+'/'+p0i(NM+1,3),lightred);
fillmenu;
	for i:=1 to no do
			menus^[i]:=' '+fixlength(menus^[i],36,LEFT);
        scode[1]:=#250;
         boxpix(1,menus,'',13,4,36,4+(no-1)*3,1,choice[1],scode[1],3);
	until (scode[2] in [ESC,LEFT]);
until ESC in [scode[1],scode[2]];

wf(datano);
get(screen1);
buflen:=78;
close(datamatf);
{assign(datamatf,TD+proname+ext);}
copyf(TD+proname+ext,proname+ext);
flags[10]:=FALSE;
end;

end.

