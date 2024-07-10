{ 29/12/95 : Try to replace errorflag with dater -1,0,1 }

procedure date2type(x,y,z:integer;var dt:datetype);
begin
dt[1]:=x;
dt[2]:=y;
dt[3]:=z;
end;

PROCEDURE datecheck(s1,s2,s3,f1,f2,f3:integer;var dater:integer);
label F;
begin
dater:=1;
if not((s3>=51) and (s3<=99) and (f3>=0) and (f3<=50)) then
      if (s3>f3) then goto F;
if (s3>=0) and (s3<=50) and (f3>=51) and (f3<=99)
      then goto F;        { check ? start year and and end year falls in same century }
if (s3=f3) then
   begin
        if s2>f2 then goto F;
	if (s2=f2) and (s1>=f1) then
                   begin
                        if s1=f1 then dater:=0;
                        goto F;
                   end;
   end;
exit;
F:
{if not flags[2] then msg(noise);} { No delete }
errorflag:=TRUE;
if dater<>0 then dater:=-1;
end;

FUNCTION daysIn(month,year:integer):integer;
begin
daysIn:=0;
        case month of
		1,3,5,7,8,10,12:	daysIn:=31;
		       4,6,9,11:	daysIn:=30;
		2:if (year mod 4=0)
			then daysIn:=29
			else daysIn:=28;
              end;
end;

FUNCTION days_In_year(year:integer):integer;
begin
if (year mod 4=0)
		then days_In_year:=366
		else days_In_year:=365;
end;

FUNCTION duradays(day1,month1,year1,day2,month2,year2:integer):integer;
var days:integer;
begin
errorflag:=FALSE;
if day2<>0 then datecheck(day1,month1,year1,day2,month2,year2,dater);
days:=0;

if (dater<0) or (day2=0) then
		begin
			duradays:=0;
                        exit;
		end;
errorflag:=FALSE;

if (year1>=51) and (year2<=50) then year2:=100+year2;
if year2>year1 then days:=days_in_year(year1);
if year2-year1>1 then
for i:= year1+1 to year2-1 do
		days:=days+days_in_year(i);
if month1>1 then
for i:=1 to month1-1 do
	days:=days-daysIn(i,year1);
	days:=days-day1;
if month2>1 then
for i:=1 to month2-1 do
	days:=days+daysIn(i,year2);
	days:=days+day2;
duradays:=days+1;
end;

PROCEDURE dura_2_days(day1,month1,year1,dura:integer;var day2,month2,year2:integer);
var days,t:integer;
begin
day2:=day1;
month2:=month1;
year2:=year1;
if (day1=0) or (dura<=0) then exit;
days:=0;
repeat
if daysIn(month2,year2)-day2+1<=dura-days then
		begin
		days:=days+daysIn(month2,year2)-day2+1;
		if month2<12 then
			begin
				day2:=1;
				inc(month2);
			end
			 else
				begin
					day2:=1;
					month2:=1;
					inc(year2);
				end;
		end
		else
			begin
			if (day2+dura-days)>daysIn(month2,year2) then
                                    begin
                                    inc(month2);
                                    day2:=day2+dura-days-daysIn(month2,year2);
                                    days:=days+dura-days-daysIn(month2,year2);
                                    end
                                    else
                                     begin
                                     day2:=day2+dura-days;
                                     days:=days+dura-days;
                                     end;
			end;
until days>=dura;
t:=duradays(day1,month1,year1,day2,month2,year2);
{
write(day2,'/',month2,'/',year2,'                   ',days,' Days.');
}
year2:=year2 mod 100;
if (t<>dura+1) or (days>dura)
		then
		begin
                     Msg('Date calculation error. Press ESC.');
                     waitfor(ESC); {Check }
                end;
end;


FUNCTION checkvaldate(var day,month,year:integer):boolean;
label getout;
begin
if day<1 then goto getout;
if (month<1) or (month>12) then goto getout;
if year>100 then
            if (year>1950) and (year<2051) then
		                           year:=year mod 100
                                           else
                                           goto getout;

case month of
     1,3,5,7,8,10,12: if day>31 then goto getout;
            4,6,9,11: if day>30 then goto getout;
                   2: if ((year mod 4<>0) and (day>28))
                                     or
			 ((year mod 4=0) and (day>29)) then goto getout;
		end;
checkvaldate:=TRUE;
exit;
getout:
checkvaldate:=FALSE;
end;

PROCEDURE str2date(s:string;var x1,x2,x3:integer);
label getout;
var
   error:integer;
   day,month,year:integer;
   slash:char;
begin
errorflag:=FALSE;
if nospace(s)=''
                then
                 begin
                      x1:=0;
                      x2:=0;
                      x3:=0;
                      errorflag:=TRUE;
                      exit;
                 end;

if pos('/',s)<>0 then slash:='/'
   else
       if pos('-',s)<>0 then slash:='-';

if pos(slash,s)=0 then goto getout
   else
       begin
       val(copy(s,1,pos(slash,s)-1),day,error);
       if error<>0 then goto getout;
       delete(s,1,pos(slash,s));
       if pos(slash,s)=0 then goto getout
          else
              begin
	       val(copy(s,1,pos(slash,s)-1),month,error);
	       if error<>0 then goto getout;
               delete(s,1,pos(slash,s));
               if s='' then goto getout
		  else
		      val(s,year,error);
                  if error<>0 then goto getout;
		  if not checkvaldate(day,month,year) then goto getout;
			x1:=day;
			x2:=month;
			x3:=year;
	      end;
	exit;
	  end;
getout:
	msgattr:=HBlink;
	{msg(' ERROR'+noise);}
	msgattr:=rvse;
	{msg('');}
        errorflag:=TRUE;
end;


PROCEDURE date2str(d:datetype;var s:string);
begin
if (d[1]=0) and (d[2]=0) and (d[3]=0) then
               s:='        '
           else
               s:=p0i(d[1],2)+'/'+p0i(d[2],2)+'/' +p0i(d[3],2);
end;

FUNCTION getsyear:integer;
var
   year:integer;
begin
sheet1:=first^.a;
year:=50;
while sheet1<>NIL do
      begin

      with sheet1^ do
	begin
	errorflag:=FALSE;
	datecheck(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3],dater);
	if dater<0 then
		begin
                smsg('Rec.no : '+p0i(recno,3)+': Error in date assignment.Press ESC'+noise);
                exit;
		end;

	flags[2]:=TRUE;
        datecheck(1,1,year,1,1,sd[3],dater);
	flags[2]:=FALSE;
	if (dater<0) and (sd[1]<>0) then year:=sd[3];
	end;
      sheet1:=sheet1^.a;
      end;
getsyear:=year;
end;

FUNCTION getsmonth:integer;
var
	month:integer;
	flag:boolean;
begin
sheet1:=first^.a;
month:=12;
flag:=FALSE;
while sheet1<>NIL do
      begin
      with sheet1^ do
	if (syear=sd[3]) and (month>=sd[2]) then
					begin
					month:=sd[2];
					flag:=TRUE;
					end;
      sheet1:=sheet1^.a;
      end;
if not flag then month:=1;
getsmonth:=month;
end;

FUNCTION getsday:integer;
var day:integer;
begin
day:=31;
sheet1:=first^.a;
while sheet1<>NIL do
      begin
          with sheet1^ do if (smonth=sd[2]) and (day>sd[1]) then day:=sd[1];
          sheet1:=sheet1^.a;
      end;
getsday:=day;
end;

FUNCTION geteyear:integer;
var year:integer;
begin
sheet1:=first^.a;
year:=syear;
while sheet1<>NIL do
      begin
      with sheet1^ do
	begin
	errorflag:=FALSE;
	datecheck(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3],dater);
	if dater<0 then
		begin
                smsg('Rec.No : '+p0i(recno,3)+' : Error in date assignment. Press ESC.'+noise);
                waitfor(ESC);
		exit;
		end;
	flags[2]:=TRUE;
        datecheck(1,1,fd[3],1,1,year,dater);
	flags[2]:=FALSE;
        if (dater<0) and (sd[1]<>0) then
		       year:=fd[3];
	end;
      sheet1:=sheet1^.a;
      end;
geteyear:=year;
end;

FUNCTION getemonth:integer;
var
	month:integer;
	flag:boolean;
begin
sheet1:=first^.a;
month:=1;
flag:=FALSE;
while sheet1<>NIL do
      begin
      with sheet1^ do
	if (eyear=fd[3]) and (month<fd[2]) then
				begin
					month:=fd[2];
					flag:=TRUE;
				end;
      sheet1:=sheet1^.a;
      end;
if not flag then month:=smonth;
getemonth:=month;
end;

FUNCTION geteday:integer;
var
	day:integer;
	flag:boolean;
begin
flag:=FALSE;
day:=1;
sheet1:=first^.a;
while sheet1<>NIL do
      begin
	  with sheet1^ do if (emonth=fd[2]) and (day<fd[1]) then
					begin
						day:=fd[1];
						flag:=TRUE;
					end;
          sheet1:=sheet1^.a;
      end;
if not flag then eday:=sday;
geteday:=day;
end;
