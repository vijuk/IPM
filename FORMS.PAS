unit forms;
interface
uses
    crt,math,dos,lib,editor;
type
    svrtype=array[1..26] of string[80];
    svltype=array[1..26] of real;
var
    daytimer:datetime;
    inpform,outform:string;
    svr:svrtype;
    svl:svltype;
    repvar:string[80];
    temps:string;
    reps:array[1..25] of string;
const
    repno:integer=0;
    repcnt:integer=0;
    control:string[12]='';
    formresult:byte=0;

procedure formstar(inpform,outform:string;svr:svrtype;svl:svltype);
implementation
type
	comrectype=
	  record
	   ps,os,ms:string;
	   lv,rv,fv,ts:string;
	   svar:svrtype;
	   uvar:svrtype;
	   sval:svltype;
	   uval:svltype;

           sx,ux:array[1..26] of byte;

	   sc,uc:array[1..26] of char;

	 end;

var
   com:^comrectype;
   a,b:real;
   c:char;
   inf:text;
   s:string;
   p:integer;
   x:integer;
   value:real;
   att:word;
   i,tp:integer;
   lcnt:integer;
   varno,st_varno:byte;
   error:integer;
   erno:integer;

procedure fillvar;
var
   j:integer;
begin
with com^ do
begin
lv:='';
rv:='';
fv:='';
ts:='';
for i:=1 to 26 do
	begin
                if pos('''',svr[i])>0 then
			 begin
svar[i]:=upstringf(copy(svr[i],1,pos('''',svr[i])));
svar[i]:=svar[i]+copy(svr[i],pos('''',svr[i])+1,length(svr[i])-pos('''',svr[i]));
sc[i]:=LEFT;
                         end
                else
                    svar[i]:=upstringf(svr[i]);
                sval[i]:=svl[i];
	end;
end;
end;

procedure analyse_eqn;
var
	ks,temps:string;
	got:boolean;
        sepset:set of char;
        len:integer;
        strflag:boolean;
{        srino:integer;}

{
 a:='asdsdsa sada',12,L;
  b:='asdadas sada',12;
  c:='adad da dasd,L;
  i:=2.34,2,R;
  j:=2.34,2;
  k:=2.34,R;
}

begin

{ srino:=0;      No of mixed data items }

strflag:=FALSE;
sepset:=['+','-','*','/','(',')',',','^','=',';',' ',#13,^Z];
with com^ do
begin
lv:=upstringf(nospace(copy(s,1,pos(':=',s)-1)));                                 {LHS}
if pos(';',s)>pos(':=',s) then
                   begin
                        tp:=pos(':=',s)+2;
                        rv:=copy(s,tp,pos(';',s)-tp);        {RHS}
                   end
                else
                   rv:=copy(s,pos(':=',s)+2,length(s)-1);    {RHS}

while rv[1]=' ' do delete(rv,1,1);

if rv[1]='''' then
                  begin
                       strflag:=TRUE;
                       inc(varno);
		       uvar[varno]:=lv;
                       ks:=rv;                          { temp process }
                       delete(ks,1,1);
                       ks:=copy(ks,1,pos('''',ks)-1);
		       uvar[varno]:=uvar[varno]+''''+ks+'''';
		  end
                  else
                       begin
                       if pos(rv,'''')>1 then msg('ERR'+noise);
                       ks:='';
                       end;

len:=length(ks);
repeat
     if pos('''',rv)>0 then
      delete(rv,1,pos('''',rv));
until pos('''',rv)=0;

if pos(',',rv)>0 then
		begin
                        tp:=pos(',',rv);
			fv:=nospace(copy(rv,tp+1,length(rv)));
                        rv:=copy(rv,1,tp-1);

		end
		else
			fv:='';

x:=0;

tp:=pos(',',fv);
if tp>0 then
	begin
		ts:=nospace(copy(fv,1,tp-1));
		val(ts,x,error);
		fv:=copy(fv,tp+1,length(fv));
	end
                else
		    if (fv<>'') then
		    if not (fv[1] in ['L','R','N']) then
			begin
			val(fv,x,error);
			fv:='';
			end;

if ks='' then                   { Defaults }
             c:=Right
         else
             c:=Left;

if fv<>'' then
case upcase(fv[1]) of
     'L':c:=Left;
     'R':c:=Right;
     'N':c:='N';
      end;

if strflag  then
                  begin
		     if x=0 then x:=length(ks);
                     ux[varno]:=x;
                     uc[varno]:=c;
                     exit;
                  end;

upstring(rv);
if (lv<>'') then
          begin
             inc(varno);
	     uvar[varno]:=lv;
             for i:=1 to 26 do
                 begin
                 if uvar[varno]=svar[i] then uval[varno]:=sval[i];
                 if pos('''',svar[i])>0 then

if copy(svar[i],1,pos('''',svar[i])-1)=rv then
   begin
   uvar[varno]:=lv+copy(svar[i],pos('''',svar[i]),length(svar[i])-pos('''',svar[i])+1);
   x:=length(svar[i])-length(rv)-2;
   end;
		 if uvar[varno]=uvar[i] then uval[varno]:=uval[i];
		 if pos('''',uvar[i])>0 then

if copy(uvar[i],1,pos('''',uvar[i])-1)=rv then
   begin
   uvar[varno]:=lv+copy(uvar[i],pos('''',uvar[i]),length(uvar[i])-pos('''',uvar[i])+1);
   x:=length(uvar[i])-length(rv)-2;
   end;
                 end;

	     ux[varno]:=x;
             uc[varno]:=c;

{ Scannig for user variables for right hand eqn}
     temps:=rv;
	     repeat
	     got:=FALSE;
	     for i:=1 to 26 do
                 begin
		 if pos(uvar[i],rv)>0 then
                     begin
                       tp:=pos(uvar[i],rv);
                       if ((tp=1) or (rv[tp-1] in sepset)) and
                          ((tp+length(uvar[i])>length(rv)) or (rv[tp+length(uvar[i])] in sepset)) then
                          begin
	               delete(rv,tp,length(uvar[i]));
		       insert(justify(uval[i],1,5,LEFT),rv,tp);
		       got:=TRUE;
                           end;
                     end;

	 if pos('''',uvar[i])>0 then
		  if copy(uvar[i],1,pos('''',uvar[i])-1)=rv then
                     begin
	               rv:=copy(uvar[i],pos('''',uvar[i])+1,length(uvar[i])-pos('''',uvar[i])-1);
		       got:=TRUE;
                     end;
		 end;

{ Scannig for software variables for right hand eqn}
             for i:=1 to 26 do
                 begin
		 if pos(svar[i],rv)>0 then
                                  begin
                                    tp:=pos(svar[i],rv);
                       if ((tp=1) or (rv[tp-1] in sepset)) and
                          ((tp+length(svar[i])>length(rv)) or (rv[tp+length(svar[i])] in sepset)) then
                                  begin
				    delete(rv,tp,length(svar[i]));
				    insert(justify(sval[i],1,5,Left),rv,tp);
				    got:=TRUE;
			          end;
                          end;

		 if pos('''',svar[i])>0 then
		  if copy(svar[i],1,pos('''',svar[i])-1)=rv then
                     begin
		       rv:=copy(svar[i],pos('''',svar[i])+1,length(svar[i])-pos('''',svar[i])-1);
		       got:=TRUE;
		     end;
		 end;
           until (nospace(temps)='') or not(got);
	end;

rv:=nospace(rv);
if varno>0 then
begin
if pos('''',uvar[varno])=0 then
                           begin
                           uval[varno]:=parse(rv,att);

{                           if att=0 then
                                    begin
uvar[26-srino]:=uvar[varno]+''''+uvar[varno]+rv+'''';
writeln(uvar[26-srino]);
srino:=srino+1;
                                    end;
}

                           end
                        else
                           att:=1;
if att=0 then
	begin
        writeln('Error in line '+strint(lcnt,3)+' : Illegal expression.');
        inc(erno);
        end;
end;
end;
end;

procedure parse_eqn;
label 100;

var
   m,n,i:integer;
   nojust,got:boolean;
   strin:string;

begin
with com^ do
begin
ps:=s;
s:='';     { s is the empty working string }

repeat
value:=0;
if (pos('{',ps)>pos('}',ps)) then
                           begin
			   writeln('Error in line '+strint(lcnt,3)+' : Opening brace is missing.');
                           inc(erno);
			   end;
if pos('{',ps)>0 then
                    begin
                    value:=(-maxint);
                    p:=pos('{',ps);
                    os:=copy(ps,1,p-1);    { os - Upto left of "{" }

                    delete(ps,1,p);        { -1 in ps }
		    m:=pos('}',ps);

		    if m=0 then
			   begin
			   writeln('Error in line '+strint(lcnt,3)+' : Closing brace is missing.'+noise);
                           inc(erno);
			   end;

                    ms:=copy(ps,1,m-1);
                    upstring(ms);         { Str variable stored in ms }

		    if nospace(ms)='' then
			begin
				writeln('Error in line '+strint(lcnt,3)+' : Identifier expected within braces.'+noise);
                                inc(erno);
			end;
strin:='';
got:=FALSE;


{ check for value of str-var in userdefined varlist }
for i:=1 to 26 do        
if not got and (pos('''',uvar[i,length(uvar[i])])>0) then
   begin                                      { var is str-var }
   { temp: Copy existing str-var to strin }
   strin:=copy(uvar[i],1,pos('''',uvar[i])-1);
   if (strin=nospace(ms)) then  { if matches strin= value of str-var }
	begin
		strin:=copy(uvar[i],  pos('''', uvar[i])+1, length(uvar[i])- pos('''',uvar[i])-1);
		got:=TRUE;
		x:=ux[i];
		if x=255 then x:=length(strin);
		c:=uc[i];
        end
	else strin:='';
   end;

if not got then  { check for value of str-var in userdefined varlist }

for i:=1 to 26 do
if not got and (pos('''',svar[i,length(svar[i])])>0) then
begin                                           { var is str-var }
strin:=copy(svar[i],1,pos('''',svar[i])-1);
if (strin=nospace(ms)) then
      begin
	strin:=copy(svar[i],pos('''',svar[i])+1,length(svar[i])-pos('''',svar[i])-1);
	got:=TRUE;
	x:=length(strin);       { appl.prg. should provide format for this }
	c:=Left;
      end
	else strin:='';
end;

	    for i:=1 to 26 do
		     if (svar[i]=nospace(ms)) then
                                                 begin
                                                 value:=sval[i];
						 x:=2;
                                                 c:=Right;
                                                 end;

	    for i:=1 to 26 do        {  Do not combine these 2 loops }
		     if (uvar[i]=nospace(ms)) then
                                                 begin
                                                 value:=uval[i];
                                                 x:=ux[i];
                                                 c:=uc[i];
                                                 end;

	    if c='N' then
				begin
                                 nojust:=TRUE;
                                 {c:=RIGHT;}
				end
				 else nojust:=FALSE;
100:
if got {string} then
		begin
		case c of
                LEFT:begin
                          if x=0 then excode:=#0 else excode:=#1;
                          if m>x then x:=m;
			  delete(ps,1,x-1);
                          if excode=#0 then ps[1]:=' ';
                     end;
                RIGHT:begin
                            delete(ps,1,m);
                            if m>x then x:=m;
                            delete(os,length(os)-(x-m-1),x-m-1);
                            {# 28/12/95 x-m-1 > x-m }
                            os:=os+' ';
                      end;
                'N':begin
                    delete(ps,1,m);
                    x:=length(strin);
                    end;
                   end;
                ms:=fixlength(strin,x,c);
		{ Do nothing }
		end
else
if value=(-maxint)
     then
	begin
	writeln('Error in line '+strint(lcnt,3)+' : Unknown identifier.');
	inc(erno);
        {delete(ps,1,m);}
	end
		else
			    begin
			      ms:=justify(value,1,x,c);
			      if nojust then
					begin
                                        ms:=nospace(ms);
                                        delete(ps,1,m);
                                        end
				else
					if c=RIGHT then
					 begin
                                         i:=length(ms)-(m+1);
                                         if i>0 then
                                                delete(os,length(os)-i+1,i)
                                            else
                                            if (i<0) and (os<>'') then  {# i<0 > i<=0 }
						insert(fixlength(' ',abs(i),LEFT),os,length(os)+1);
					 delete(ps,1,m);
                                         end
				else
				      if c=Left then
                                         begin
                                         i:=length(ms)-(m+1);
                                         delete(ps,1,m);
                                         if i<0 then
                                                insert(fixlength(' ',abs(i),LEFT),ps,1)
                                             else
                                                delete(ps,1,abs(i));
                                         end;
			      end;
			    s:=s+os+ms;
		    end;
until pos('{',ps)=0;
s:=s+ps;
end;
end;

procedure compile(sfname,tfname:string);
label 500;
begin

{$I-}
windows(wout,cls);
gotoxy(1,1);
if control='OPEN' then
begin
setfile(inf,sfname,sfname,'R',excode);
if excode=ESC then
		begin
			msg('File '+sfname+' not found.'+ESC);
			exit;
		end;
excode:=#0;
if printmode and printerready then
                 out_2_prn
             else
                 setfile(out,tfname,tfname,'W',excode);

if excode=ESC then
		begin
			msg('File write error.'+ESC);
			exit;
		end;

varno:=0;
lcnt:=0;
for i:=1 to 26 do
    begin
        com^.uval[i]:=0;
        com^.uvar[i]:='~';
    end;

daytimes;
svr[25]:='Date'''+date+'''';
svr[26]:='Time'''+time+'''';
end;

fillvar;
while not eof(inf) do
	begin
        if Ubreak then goto 500;

        if (control='END')  then
                begin
                  inc(repno);
                  s:=reps[repno];
		end
        else
           begin
           readln(inf,s);
	   inc(lcnt);
           end;
	temps:=nospace(s);
        upstring(temps);
        repvar:='';
	if control='REPEAT' then
                            begin
                                 inc(repno);
                                 reps[repno]:=s;
                            end;
	if not(pos(';',nospace(s))=1) then
        if pos('.REPEAT',temps)=1 then
                              begin
                                   control:='REPEAT';
                                   st_varno:=varno;
                              end
	else
		if pos('.END',temps)=1 then
                              begin
                                   repcnt:=repno;
                                   repno:=0;
                                   control:='END';
                                   varno:=st_varno;
                                   formresult:=2;
                                   exit;
                              end
        else
		if pos(':=',s)>0
			then
				analyse_eqn
			else
				begin
					parse_eqn;
                                        {$I-}
					writeln(out,s);
                                        {$I+}
				end;
	end;
500:
{$I-}
close(inf);
close(out);
{$I+}

outname:='CON'; {# new addition 27/12/95 }
end;

procedure formstar(inpform,outform:string;svr:svrtype;svl:svltype);
begin
erno:=0;
x:=2;
c:='N';
formresult:=0;
new(com);
compile(inpform,outform);
dispose(com);
if excode=ESC then exit;
if formresult=2 then exit;
if erno>0 then
	begin
             {gotoxy(1,4);}
             writeln;
             writeln('Lines compiled: ',strint(lcnt,4));
	     textattr:=red+blink;
	     writeln(strint(erno,1)+' errors detected.'+noise);
	     textattr:=Norm;
             writeln;
             formresult:=1;
             msg('Press any key to continue');
             waitfor(any);
             end;
end;

{
begin
formstar('FORM.PAS','FORM.OUT',svr,svl);
}
end.
