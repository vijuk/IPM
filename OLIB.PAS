{ OPERATING SYSTEM LIBRARY }

unit olib;
interface

Uses Crt,lib,Dos,printer;

Function  GetLoggedDrive:Char;
Function  CurrentDirectory(Drive:Char):String;
{
Procedure Shell(Parent:String);
Function  Lead0(W:Word):String;
Function  FileName(DirInfo:Searchrec; ShowSize,ShowDate:Boolean):String;
}

PROCEDURE call_shell(parent:string);
PROCEDURE copyf(source,target:string);
PROCEDURE renamef(source,target:string);
PROCEDURE deletef(filename:string);
PROCEDURE printf(filename:string);
PROCEDURE dirf;

implementation

type 	block=array[1..128] of byte;
const
	months:array[1..12] of string[9]=
       ('January  ',
	'February ',
	'March    ',
	'April    ',
	'May      ',
	'June     ',
	'July     ',
	'Augest   ',
	'September',
	'October  ',
	'November ',
	'December '
	);

PROCEDURE copyf(source,target:string);
var
	sf,tf:file;
	startingblock:longint;
	buf:array[1..40] of block;
	NumRead, Numwritten: Word;
        flag:boolean;

PROCEDURE verifyblocks(numblocks,startingblock:integer);
var
	testblock:block;
	i,j:integer;
	svalue:string;
begin
str(numblocks,svalue);
write('Verifying '+svalue+' blocks');
{$I-}
seek(sf,startingblock);
for i:=1 to numblocks do
	begin
		blockread(tf,testblock,i);
		for j:=1 to 128 do
			if (testblock[j] <> buf[i,j]) then
			begin
			msg('Copy failed. Press any key to resume ....');
			waitfor(any);
			end;
	end;
{$I+}
end;

begin
excode:=#0;
if (source='') and (target='') then
               flag:=TRUE else flag:=FALSE;

if flag then
   readstrbox(1,7,14,40,'Source file name',source,excode);

if excode=ESC then exit;
	upstring(source);
	if aborted then exit;
	if not exist(source) then
		begin
		if flag then
			begin
			msg('File '+source+' not found.'+noise);
			wait;
			aborted:=TRUE;
			end;
		exit;
		end;

if flag then
        begin
        readstrbox(1,7,14,40,'Copy file name',target,excode);
        if excode=ESC then exit;
	end;
        upstring(target);
	if aborted then exit;
	if exist(target) then
		begin
                resp:='N';
		if flag then
                     readchar(54,'File '+target+' exists. Overwrite ? (Y/N)  ',resp)
                     else resp:='Y';
				if resp='Y' then
					begin
					windows(wmsg,cls);
					{$I-}
					assign(tf,target);
					erase(tf);
					{$I+}
					if flag and (ioresult<>0) then
						begin
                                                msg('Invalid command.'+noise);
                                                wait;
                                                end;
					end
					else aborted:=TRUE;
		end;

	if not aborted then
		   begin
		   {$I-}
			assign(sf,source);
			assign(tf,target);
			reset(sf,1);
			rewrite(tf,1);
		   {$I+}
		if ioresult=0 then
			begin
			if flag then msg('Copying...');
			repeat
			   startingblock:=filepos(tf);
	{ Input error zone }
			   blockread(sf,buf,sizeof(buf),Numread);
			   if Numread>0 then
				begin
				blockwrite(tf,buf,Numread,Numwritten);
				{
				verifyblocks(Numwritten,startingblock);
				}
				end;
		       until (Numread =0) or (Numread<>Numwritten);
		       if flag then
                          begin
                          msg(source+' copied to  '+target);
                          wait;
                          end;
		       close(sf);
		       close(tf);
		       end
			else if flag then
                                begin
                                msg('Invalid command.'+noise);
                                wait;
                                end;

		end;
	end;

PROCEDURE renamef(source,target:string);
var
	sf,tf:file;
        flag:boolean;
begin
if (source='') then flag:=TRUE;
if flag then readstrbox(1,7,15+1,40,'Present file name',source,excode);
if excode=ESC then exit;
    upstring(source);
    if aborted then exit;
	    if not exist(source) then
		begin
		msg('File '+source+' not found.'+noise);
                wait;
		aborted:=TRUE;
		end;
if flag then readstrbox(1,7,15+1,40,'New file name',target,excode);
if excode=ESC then exit;
    upstring(target);
if aborted then exit;
	if exist(target) then
	begin
        resp:='N';
        if flag then
           readchar(57,'File '+target+' exists . Erase it ? (Y/N) ',resp)
           else resp:='Y';
	if resp='Y' then
		begin
			{$I-}
			assign(tf,target);
			erase(tf);
			{$I+}
                        if flag then
                        begin
			if ioresult=0 then
				      msg('File '+source+' renamed as '+target)
				else
				      msg('Invalid command.'+noise);
                        wait;
                        end;


		end
		else aborted:=TRUE;
	end;

if not aborted
	then
		begin
		windows(wmsg,cls);
		{$I-}
		assign(sf,source);
		rename(sf,target);
		{$I+}
		if flag then
                begin
                if ioresult=0 then
				msg('File '+source+' renamed as '+target)
			else
				msg('Invalid command.'+noise);
		wait;
                end;
                end;
	end;

PROCEDURE deletef(filename:string);
var
	f:file;
	{filename:string[12];}
        flag:boolean;
begin
if filename='' then
begin
flag:=TRUE;
filename:='';
readstrbox(1,7,15,40,'Delete file name',filename,excode);
if excode=ESC then exit;
end
   else flag:=FALSE;

     upstring(filename);
     if aborted then exit;
if not exist(filename) and flag
     then
          begin
	  msg('File '+filename+' does not exist.'+noise);
          wait;
          end
     else
     begin
     resp:='N';
     if flag then readchar(59,'File '+filename+' will be deleted. Are you sure ? (Y/N) ',resp)
     else resp:='Y';
if resp='Y'
	   then
		begin
		     windows(wmsg,cls);
		     assign(f,filename);
		     {$I-}
                     erase(f);
                     {$I+}
		     if (ioresult<>0) and flag then
                        begin
                        msg('File  '+filename+' deleted .');
                        wait;
                        end;
		end;
     end;
end;

PROCEDURE printf(filename:string);
var
	f:text;
        flag:boolean;
        s:string;
begin
if filename='' then
begin
flag:=TRUE;
readstrbox(1,7,17,40,'Print file name',filename,excode);
if excode=ESC then exit;
end
   else flag:=FALSE;
upstring(filename);

if aborted then exit;
if not exist(filename) and flag
     then
          begin
	  msg('File '+filename+' does not exist.'+noise);
          wait;
          end
     else
     begin
	     windows(wmsg,cls);
		     assign(f,filename);
                     reset(f);
                     if printerready then
                        while not eof(f) do
                              begin
                              readln(f,s);
                              writeln(lst,s);
                              end;
             close(f);
     end;
end;

Procedure dirf;
var
	inpdir :string;
	dirfiles:files;
	numfiles:integer;
	fname:string[12];
begin
{
if flag then
begin
inpdir:='';
readstr(60,'Path ?  ',inpdir);
if aborted then exit;
windows(wmsg,cls);
inpdir:=inpdir+'\*.*';
end;
}
inpdir:=GetLoggedDrive+':'+CurrentDirectory(GetloggedDrive);
readstrbox(1,7,15+2,40,'Directory name',inpdir,excode);
if excode=ESC then exit;
selfromdir(5,10,inpdir,fname,excode);
end;

Function GetLoggedDrive:char;
Begin
Regs.ah:=$19; Msdos(Regs); GetLoggedDrive:=Chr(65+Regs.al);
End;

Function  CurrentDirectory(Drive:Char):String;
Var P:Array[1..64] Of Char; J:Byte; S:String;
Begin
Regs.ah:=$47;
Regs.ds:=Seg(P); Regs.si:=Ofs(P);
Drive:=Upcase(Drive); Regs.dl:=Ord(Drive)-64;
{ IN MSDOS INTERRUPTS DRIVE 0 IS LOGGED DRIVE WHILE A=1, B=2 etc }
Msdos(Regs);
S:='\'; J:=1; While P[J]<>#0 Do Begin S:=S+P[J]; Inc(J); End;
CurrentDirectory:=S;
End;

Procedure call_Shell(parent:string);
Var
   Path,Fncc:String; Drive:Char;
   Label ExitShell;
Begin
Drive:=GetLoggedDrive;
Path:=Drive+':\';
Fncc:=GetEnv('COMSPEC');
While Not Exist(Fncc) Do Begin
Writeln(Fncc,' Not Found. Type In Path Or ','<',#196,#196,#217,' To Exit.. ');
Readln(Path);
If Path='' Then Goto ExitShell;
If Path[Length(Path)]<>'\' Then Path:=Path+'\';
Fncc:=Path+'Command.com';
End;
windows(wglob,cls);
Writeln('DOS Shell. Type EXIT to return to ',Parent);
SwapVectors;
Exec(Fncc,'');
SwapVectors;
If Doserror=8 Then Begin
		   Writeln('Not enough memory. Press ESC.');
		   waitfor(ESC);
                   End;
ExitShell:
End;

Function  FileName(DirInfo:Searchrec; ShowSize,ShowDate:Boolean):String;
Var J:Byte; Dt:Datetime; Monthstr,S1,S2:String; D:Dirstr; N:Namestr; E:Extstr;
Begin
Fsplit(Dirinfo.name,D,N,E);
While Length(N) < 8 Do N:=' '+N;
While Length(E) < 4 Do E:=E+' ';
S1:=N+E;

if DirInfo.Attr=Directory then S1:=S1+'  <Dir>  '
                          else S1:=S1+'         ';
if ShowSize then begin
                 Str(Dirinfo.size:6,S2);
                 S1:=S1+S2;
                 end;

If ShowDate Then
	Begin
	Unpacktime(Dirinfo.time,Dt);
	Str((Dt.year-1900):2,S2);
	Monthstr:=Copy(Months[Dt.month],1,3);
	S1:=S1+'   '+p0i(Dt.day,2)+'-'+Monthstr+'-'+S2+'  '+p0i(Dt.hour,2)+':'+p0i(Dt.min,2);
	End;
FileName:=S1;
End;
end.