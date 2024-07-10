PROCEDURE initrec;
var i:integer;
  begin
   fillchar(sheet1^,sizeof(sheet1^),0);
with sheet1^ do
     begin
     	actcode:='.....';
	code:='';
        activity:='';
	length:=0;
	breadth:=0;
	height:=0;
        subQ:=0;
        addQ:=0;
	quantity:=0;
	qdone:=0;
        sc_rate:=0;
        c_rate:=0;
        munit:='';
        sd[1]:=0;
        sd[2]:=0;
        sd[3]:=0;
        fd[1]:=0;
        fd[2]:=0;
        fd[3]:=0;
        sub_id:='';
        stat:=0;
        pres:=0;
        prev:=0;
        tapno:=0;
	for i:=1 to 3 do
                 begin
                      cd[i]:=0;
                      ed[i]:=0;
                      sd[i]:=0;
                      fd[i]:=0;
                      ad[i]:=0;
                 end;
	a:=NIL;
	tap:=NIL;
	end;
end;

PROCEDURE appendrec(var last:psheettype1);
begin
if overflow then exit;
new(sheet1);
memdisp;
initrec;
sheet1^.a:=NIL;
last^.a:=sheet1;
sheet1^.recno:=last^.recno+1;
last:=sheet1;first^.tap:=last;
inc(No_act);
inc(TN);
sflag:=TRUE;
end;

PROCEDURE takerec(rn:integer);
begin
outrec:=FALSE;
sheet1:=first^.a;
while (sheet1^.recno<>rn) and (sheet1^.a<>NIL) do
                                               sheet1:=sheet1^.a;
if sheet1^.recno=rn
	then
                outrec:=FALSE
	else
               	begin
                        outrec:=TRUE;
                        smsg('Record search failure at '+strint(rn,1)+'. Press ESC.');
                        waitfor(ESC);
                end;
end;

PROCEDURE delrec(var first,last:psheettype1;rn:integer);
var
	temp,dummy:psheettype1;

begin
if (No_act=1) then
          if (rn=1) then
              begin
                 msg('Sheet should not be empty.'+noise);
                 exit;
              end
              else
                  begin
                  smsg('Problem (1) : Report to programmer. Press ESC.');
                  waitfor(ESC);
                  end;

if (No_act<1) or (rn>No_act) then
                                    begin
                                    smsg('Problem : Record number mismatch. Press ESC.');
                                    waitfor(ESC);
                                    exit;
                                    end;

sheet1:=first;
while (sheet1^.a<>NIL) and (sheet1^.recno<>rn-1)  do
			sheet1:=sheet1^.a;
if sheet1^.a<>NIL then
                 begin
                  temp:=sheet1^.a;
		  temp:=temp^.a;
		  dummy:=sheet1^.a;
                  memdisp;
		  sheet1^.a:=temp;
		  dec(No_act);
		  if sheet1^.a=NIL then
				begin
				last:=sheet1; first^.tap:=last;
				if hl>1 then dec(hl);
				if (No_act<>0) and (m+hl-1>No_act) then
						dec(m);
				end
		      else
			  begin
			       temp:=sheet1;
			       while (sheet1^.a<>NIL) do
					begin
					sheet1:=sheet1^.a;
					dec(sheet1^.recno);
					end;
			       sheet1:=temp;
			  end;
		end;
sflag:=TRUE;
end;

PROCEDURE insrec(var first,last:psheettype1;rn:integer);
var
   temp:psheettype1;
begin
if (rn>No_act+1) then
                     begin
                     smsg('ERR3...'+noise);
                     waitfor(ESC);
                     exit;
                     end;
sheet1:=first;
while (sheet1^.a<>NIL) and (sheet1^.recno<>rn-1)  do
			sheet1:=sheet1^.a;
if (sheet1^.a<>NIL) or (rn-1=0) then
               begin
		  temp:=sheet1;
		  if overflow then exit;
                  new(sheet1);
                  memdisp;
                  initrec;
                  sheet1^.recno:=rn;
		  sheet1^.a:=temp^.a;
                  temp^.a:=sheet1;
                  inc(No_act);
                  if sheet1^.a=NIL then
				begin
				last:=sheet1;first^.tap:=last;
                                hl:=1;
				end
			  else
				begin
				temp:=sheet1;
				while (sheet1^.a<>NIL) do
				      begin
					sheet1:=sheet1^.a;
					inc(sheet1^.recno);
				      end;
				sheet1:=temp;
				end;
		       end;
		     {  else msg(noise);}
sflag:=TRUE;
end;

PROCEDURE copyrec(var sheet1,temp:psheettype1);
{There is some problems with copying tap pointer. So do it in main program }
begin
	with sheet1^ do        { # Caution : ERRORPRONE ZONE }
	     begin
		actcode:=temp^.actcode;
		code:=temp^.code;
		activity:=temp^.activity;
                c_rate:=temp^.c_rate;
                sc_rate:=temp^.sc_rate;
		length:=temp^.length;
		breadth:=temp^.breadth;
		height:=temp^.height;
		subQ:=temp^.subQ;
		addQ:=temp^.addQ;
		if flags[1] then
                   quantity:=temp^.quantity
                else
                   quantity:=0;
		munit:=temp^.munit;
		sd:=temp^.sd;
		fd:=temp^.fd;
		sheet1^.tap:=NIL;
end;
end;
