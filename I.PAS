(*
{$F+}
*)

{****               PROJECT MANAGEMENT SOFTWARE FOR IMS                 ****}

  {
        This program is valid from 1950 to 2050 years
	Use linked records for manipulations
	Use record files to Save & Retreive Data
  }

program IMS_PROJECT;
uses
    crt,lib,graph,plib,editor,dos,ilib,inputs,olib,printer,extra,cash,
    outputs,t;
label 100;

var
   path:pathstr;
   name:namestr;
   ext:extstr;
   filerec:Searchrec;

const
     msg1=' No project loaded!'+#7;

(*
        procedure lockinit(msg: string); external;
        procedure locker(msg: string); external;

	{$L plock.obj}
	{$L pltp.obj}
*)

                { ***********  MAIN PROGRAM ************  }

{$I Files}
{$I Options}

begin

(*
    writeln('This is a test program to PORTLOCK OBJ modules');
    lockinit('123456');
    locker('234567');
    writeln('Test completed successfully');
*)

  OldExitProc := ExitProc;                { save previous exit proc }
  ExitProc := @MyExitProc;                { insert our exit proc in chain }

{
  Ovrsetbuf(20);
  writeln(OvrResult);waitfor(ESC);
  writeln(OvrgetBuf);waitfor(ESC);
  OvrInit('c:\pascal\editor.tpu');
  writeln(OvrResult);waitfor(ESC);
}

  proname:=paramstr(1);

  sfname:='';
  rfname:='';


  heading;

  txtmode:=TRUE;
  globalalt:=[#23,#24,#25,#19];
  subname:='';
  normvideo;

  mark(heap);              { Mark Beginnig of Heap }

  init_tables;
  directvideo:=TRUE;
  textattr:=norm;

{  mybackground(11,0);}
{textbackground(lightmagenta);}
{textattr:=33;}

{
for i:= 0 to 255 do
begin
  clrscr;
}

if lastmode=co80 then
   begin
   textattr:=112;
   for j:=1 to 24*80 do write('°');
   end
   else clrscr;

{
gotoxy(25,1); write(i);
c:=readkey;
end;
}

  HN:=4;
  head[1]:='Project';
  head[2]:='Input';
  head[3]:='Reports';
  head[4]:='Options';
  head[5]:='';

  opt:=1;
  bottombar;
  hpixcode:=#0;
  hline(1,2,80,196,5);
  textattr:=9;
  Centre('IMS TRICHUR');
  textattr:=Norm;
  flags[10]:=TRUE;

if paramstr(1)<>'' then  flags[2]:=TRUE;

repeat

      scode[9]:=#0;
      scode[10]:=#0;                         { 63,123,126,127 }
      nabt;
      if flags[2] then hpixcode:=NOREAD;
      hpix(1,1,80,head,opt,hpixcode);
      vs(60,1,'IMS Project Manager',123);

if hpixcode=ESC then
		      begin
                           smsg('Realy want to quit ? Y/N ');
                           if yes then
                              begin
		                   saveguard;
		                   exit;
                              end;
                      end;

if hpixcode<>ESC then
                           put(screen)
                       else
                           get(screen);

if flags[2] then
                begin
                 load(paramstr(1)+'.DAT');
                 flags[2]:=FALSE;
                end;

case opt of
     1:  FileMenus;
     2: InputMenus;
     3:OutputMenus;
     4:OptionMenus;
end;

if (scode[10]=chr(altstate)) or (hpixcode=chr(altstate)) then
   case REQ of
        #25:opt:=1;
        #23:opt:=2;
        #19:opt:=3;
        #24:opt:=4;
     end;



get(screen);
hpixcode:=NOREAD;
case  scode[10] of
      Left:  if opt>1 then dec(opt) else opt:=HN;
      Right: if opt<HN then inc(opt) else opt:=1;
      chr(altstate):;
         else if hpixcode<>chr(altstate) then hpixcode:=#0;
      end;

until hpixcode=ESC;
end.

Definitions  :
Activity     : Work has a unique character and independant rate.

