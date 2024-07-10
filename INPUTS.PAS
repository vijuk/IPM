
{ uses scode 5,9 }

unit inputs;
interface
uses lib,crt,ilib,cash,extra,olib,editor,outputs;
const
      period:real=30.50;

procedure inputmenus;
implementation

procedure InputMenus;
label 300;

var
   dura,t,z,i,j,k,p,q:integer;
   purchfile:file of purchdatetype;
   flag:boolean;
   var s1,s2:string[80];  { debug var }
   newpurchfile:boolean;
   indx:integer;

begin
repeat
nabt;
shadow:=TRUE;
box(10*(opt-1)+2,3,10*(opt-1)+29,13,single,28);

	menus^[1]:=' Schedule of activities   ';
	menus^[2]:=' Quantity surveying     '+chr(16)+' ';
	menus^[3]:=' Tender rates             ';
        menus^[4]:=' Site report            '+chr(16)+' ';;
	menus^[5]:=' Material ratios          ';
	menus^[6]:=' Scheduled purchase       ';
	menus^[7]:=' Material rates           ';
        menus^[8]:=' Actual purchase          ';
        menus^[9]:=' Cash flow                ';

menus^[21]:='Assign date, duration & measurement unit to activities.';
menus^[22]:='Estimation of quantities involved in each activity.';
menus^[23]:='Assign rates of contractor & subcontractors to each activity.';
menus^[24]:='Mark works completed by a subcontractor.';
menus^[25]:='Specify material ratios for each activity.';
menus^[26]:='Material rates and persent of instalments.';
menus^[27]:='Scheduled purchase dates of materials for each activity.';
menus^[28]:='Details of actual purchase of materials.';
menus^[29]:='Income and expense.';

scode[5]:=FMENU;

msgno:=20;
boxpix(1,menus,'SQTMCC',10*(opt-1)+3,4,10*(opt-1)+28,12,1,choice[5],scode[5],1);
urgentservice(scode[5]);
msgno:=0;
purpose:=0;
                            { A very important statement }

if (scode[5]=ENTER) and (nospace(proname)<>'') then
   case choice[5] of
	1:sheet(SA);             { Schedule of activities }
	2:                       { Quantity Surveying }
	begin
	{  if memavail<1000 then goto 100;}
               repeat
                excode:=#0;
                purpose:=1;
                sheet(SA);
                purpose:=0;
		if (excode=ENTER) and (No_act>0) then
		   begin
			push;
			sheet(QS);
			pop;
                        excode:=#0;
                        window(1,16,80,24);
                        clrscr;
                        window(1,1,80,25);
		   end;
               until (excode=ESC) or aborted;
	 end;
       3:sheet(TR);		 { Tender Rates           }
       4:                        { Site Report Entry }
       begin
{	 if memavail<1000 then goto 100;   }
	 update_namelist;
         textcolor(lightred);
         textbackground(blue);
	 sel_name_date(10*(opt-1)+4,8,'Subcontractor''s Name',namelist,no_names,subname);
         textattr:=Norm;
	 if (scode[9]=ESC) then goto 300;

	 errorflag:=FALSE;

        s:='';
	d[2]:=0;
	repeat
	      readstrbox(1,10*(opt-1)+5,5+choice[5],40,'Closing Date',s,excode);
              if excode=ESC then goto 300;
	      if nospace(s)='' then sel_date(SC_D,4,5+3);
	      if scode[9]=ESC then goto 300;
              str2date(s,d[1],d[2],d[3]);
	until not errorflag or aborted;

	repeat
               	excode:=#0;
                purpose:=1;
                sheet(SA);
		purpose:=0;
		if (excode=ENTER) and (No_act>0) then
			begin
				push;
			        sheet(SR);
				pop;
                                excode:=#0;
                                window(1,16,80,24);
                                clrscr;
                                window(1,1,80,25);
			end;
        until excode=ESC;
       end;
       	5:                    { Material ratios }
	begin
        flags[2]:=TRUE;
               repeat
                excode:=#0;
                purpose:=1;
                sheet(SA);
                purpose:=0;
		if (excode=ENTER) and (No_act>0) then
		   begin
                        purpose:=1;
			sheet(MR);
                        purpose:=0;
                        excode:=#0;
                        window(1,16,80,24);
                        clrscr;
                        window(1,1,80,25);
		   end;
               until (excode=ESC) or aborted;
               flags[2]:=FALSE;
               copyf(TD+proname+'.MAT',proname+'.MAT');
	 end;
	6:                          { Scheduled purchase }
          begin
          if not exist(proname+'.SPD') then
                 begin
                 newpurchfile:=TRUE;
                 indx:=0;
                 smsg('Please wait.. Automatic input generation.');
                 end
                 else
                     begin
                     newpurchfile:=FALSE;
                     end;

          copyf(proname+'.SPD',TD+proname+'.SPD');

	  assign(purchfile,TD+proname+'.SPD');

               repeat
                excode:=#0;
                purpose:=1;
                if newpurchfile then
                                begin
                                indx:=indx+1;
                                takerec(indx);
                                excode:=ENTER;
                                end
                                else
                                sheet(SA);
                
                purpose:=0;
                q:=0;

		if not (sheet1^.sd[1]=0) and (excode=ENTER) and (No_act>0) then
		   begin
                        purpose:=1;
                        window(1,2,80,24);
                        textbackground(black);
                        clrscr;
                        window(1,1,80,25);
                        gotoxy(1,2);
                        centre(sheet1^.activity);
                        msg('Use arrow keys for changing schedule dates');

			if not newpurchfile then reset(purchfile);

                        purchdate.purchact:='~~~~~~~';

          		if newpurchfile then
                                        rewrite(purchfile)
			else
			    while not eof(purchfile) and nomatch
			           do
                                     begin
                                     {$I-}
                                     read(purchfile,purchdate);
                                     {$I+}
       if ioresult<>0 then smsg('Failure in reading SPD file.'+ESC);
                                     end;

			with sheet1^ do
			with purchdate do
			if sd[1]<>0 then
                        begin
                        dura:=duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]);
                        gotoxy(1,24);
			{write(dura,'days   ',no,'spacing');}

			if nomatch then
                                   begin
					flag:=TRUE;
{
                                        writeln('Not matched');

   writeln(upstringf(purchdate.purchact),' = ',upstringf(sheet1^.activity));
   writeln(purchdate.purchunit,'  =  ',sheet1^.munit);
   writeln(purchdate.psd[1],'  =  ',sheet1^.sd[1]);
   writeln(purchdate.psd[2],'  =  ',sheet1^.sd[2]);
   writeln(purchdate.psd[3],'  =  ',sheet1^.sd[3]);
   writeln(purchdate.psd[1],'  =  ',sheet1^.sd[1]);
   writeln(purchdate.psd[2],'  =  ',sheet1^.sd[2]);
   writeln(purchdate.psd[3],'  =  ',sheet1^.sd[3]);

waitfor(ENTER);

}
                                        end
				   else
					begin
                                        flag:=FALSE;
{                                        writeln('Matched');}
                                        end;
{                        waitfor(any);}
                        gotoxy(6,3);

			z:=1;
                        for k:=1 to 70 do
                                 begin
                                 attr:=textattr;
                                 textattr:=126;
				 if k>=round((z*period/dura)*70) then
                                        begin
						write('°');
						inc(z);
                                        end
                                    else
					write('Û');

				 textattr:=attr;
				 end;

			i:=0;
                        if flag then
                           begin
                        fillchar(purchdate.diffsd,sizeof(diffsd),#0);
			purchdate.purchact:=sheet1^.activity;
			purchdate.purchunit:=sheet1^.munit;
			purchdate.psd:=sheet1^.sd;
			purchdate.pfd:=sheet1^.fd;
                           end;

			for z:=0 to 80 do
			if flag then
			begin
			if (round(z*period)<=dura) and
				((round(z*period)<=dura-period/2) or
                                    (dura<=period/2)) then
                                        diffsd[z]:=round(z*period)
                            else
                            begin
				if q=0 then q:=z;
				diffsd[z]:=dura;
			    end;
			end
			else
			   begin
                           if (diffsd[z]>=dura-1) and (q=0) then
                                                   q:=z-1;
                           if (diffsd[z]>dura-1) then
                                               diffsd[z]:=dura;
                           if diffsd[z]<0 then diffsd[z]:=0;
                           end;

                        repeat
                        c:=ESC;


                        gotoxy(1,5);
                        for j:=1 to 80 do write(' ');

                        gotoxy(1,6);
                        for j:=1 to 80 do write(' ');

                        gotoxy(6,4);

                        z:=0;

                        dura_2_days(sd[1],sd[2],sd[3],diffsd[z],d[1],d[2],d[3]);
                        date2str(d,s);
                        gotoxy(round(6+70*((diffsd[z])/dura)),wherey+1);
                        t:=wherex;
                        write(1);
                        gotoxy(t-4,wherey+1);
                        t:=wherex+4;
                        if i=0 then
                                      begin
                                         attr:=textattr;
                                         textattr:=106;
                                         write(s);
                                         textattr:=attr;
                                      end;

                        gotoxy(t,wherey-2);
                        gotoxy(6,wherey);
                        for j:=1 to 70 do write(' ');

                        gotoxy(round(6+70*((diffsd[z])/dura)),wherey);

                        write('^');

                        for k:=0 to 71 do
                            begin
                            if k>=((diffsd[z+1]+1)/dura)*70 then
                                  begin
                                  inc(z);
                                  dura_2_days(sd[1],sd[2],sd[3],diffsd[z],d[1],d[2],d[3]);
                                  date2str(d,s);

                          gotoxy(round(6+70*((diffsd[z]+1)/dura)),wherey+1);

                        t:=wherex;
                        if i<=q then write(z+1);
                                  gotoxy(t-4,wherey+1);
                                  t:=wherex+4;
                                  {msg(strint(i,3));}
                                  if (z=i) then
                                         begin
                                         attr:=textattr;
                                         textattr:=106;
                                         if diffsd[z]>dura-1 then textattr:=63;
                                         write(s);

                                         textattr:=attr;
                                         end;
                                  gotoxy(t,wherey-2);
                                  gotoxy(round(6+70*((diffsd[z]+1)/dura)),wherey);
                                  write('^');
                                  end;
                            end;

                        readksbuff:=#0;

                        speckey:=FALSE;
                        if newpurchfile then
                           c:=ENTER else ksreadkey(1,c,speckey);

            if speckey then
             case c of
               LEFT:
                        begin
                        if (diffsd[i]>0) and (i=0) then
                                diffsd[i]:=diffsd[i]-1
                        else
                        begin
                        if (diffsd[i]>0) and (i>0) then
                                if diffsd[i]-1>diffsd[i-1] then
                                       diffsd[i]:=diffsd[i]-1
                                else
                                    begin
                                    diffsd[i]:=diffsd[i-1];
                                    sound(100);
                                    delay(750);
                                    nosound;
                                    clearbuffer;
                                    if i>1 then dec(i);
                                    end;
                        end;
                        end;
              right:
                        begin
                        if (i>0) and (diffsd[i]<dura-1) and (i<70) then
                           if diffsd[i]+1<diffsd[i+1] then
                                   diffsd[i]:=diffsd[i]+1
                                else
                                    begin
                                    diffsd[i]:=diffsd[i+1];
                                    sound(100);
                                    delay(750);
                                    nosound;
                                    clearbuffer;
                                   end;
                        end;
               up:
                        begin
                        if (diffsd[i]<dura-1) then
                        begin
                        inc(i);
                        if (i>=q) then
                               begin
                               inc(q);
                               diffsd[q]:=dura;
                               end;
                        end;
                        end;
            down:       if i>0 then dec(i);
{DEL}        'S':
                        if i>0 then
                        begin
                            if i=q then
                                   begin
                                        dec(i);
                                        dec(q);
                                        diffsd[i+1]:=dura;
                                   end
                                   else
                                       diffsd[i]:=diffsd[i+1];
                        end;
            end;

                        for j:=0 to 79 do
                            if (diffsd[j]=diffsd[j+1]) then
                                    begin
                                    if (j+1=q) and (j<>q) then
                                                  dec(q);
                                    for p:=j to q+1 do
                                         diffsd[p]:=diffsd[p+1];
                                    end;

			if (c=ENTER) and (sd[1]<>0) then
                                begin

                       if not flag and (filepos(purchfile)>0) then {matched}
                          begin
                          seek(purchfile,filepos(purchfile)-1);
                          read(purchfile,purchdate);

{                          writeln(purchdate.purchact,' ESC');
                          waitfor(ESC);
}
                          seek(purchfile,filepos(purchfile)-1);

                          end;

                          {
                          else seek(purchfile,sizeof(purchfile));
                          }
                          write(purchfile,purchdate);
                          {
                          smsg('O.K');
                          wait;
                          }
                       end;


{ **Display quantity of material to be purchased** }
window(21,10,59,22);
clrscr;
window(1,1,80,25);
       if (i<=q) then
                           begin

                           {
                           w1:=2;
                           w2:=10;
                           w3:=50;
                           w4:=24;
                           }

                           inpbreak:=TRUE;
move(sd,breaksd,sizeof(breaksd));
dura_2_days(sd[1],sd[2],sd[3],diffsd[i],breaksd[1],breaksd[2],breaksd[3]);
move(breaksd,breakfd,sizeof(breaksd));
{
date2str(breaksd[1],breaksd[2],breaksd[3],s1);
}
dura_2_days(breaksd[1],breaksd[2],breaksd[3],diffsd[i+1]-diffsd[i],breakfd[1],breakfd[2],breakfd[3]);
{
date2str(breakfd[1],breakfd[2],breakfd[3],s2);
}
                           breakact:=sheet1^.recno;
                           box(20,9,60,23,single,28);
                           gotoxy(1,9);
                           centre('Purchase on current date');
                           gotoxy(21,12);
                           break(4);
         end;

{
                        writeln('O.K ',indx);
                        readln;
}
                       	until (c in [ESC,ENTER]);

                        end;

                        end;

               if (newpurchfile and (indx=No_act)) then
                                newpurchfile:=FALSE;

{
                        writeln('O.K* ',indx,' ',newpurchfile);
                        readln;
}

               until (excode=ESC) or aborted or (sheet1^.sd[1]=0);
               if sheet1^.sd[1]=0 then
                  begin
                  smsg(p0i(sheet1^.recno,3)+' : Dates not specified.'+ESC);
                  {$I-}
                  erase(purchfile);
                  {$I+}
                  end;

               {$I-}
               close(purchfile);
               {$I+}

{
               reset(purchfile);
               while not eof(purchfile)
			           do
                                     begin
                                     read(purchfile,purchdate);
                                     writeln(purchdate.purchact);
                                     end;
               waitfor(ESC);
}

               copyf(TD+proname+'.SPD',proname+'.SPD');
               inpbreak:=FALSE;

          end;
	  7:               { material rates }
             begin
             fileflag:=2;
	     editrec;
	     end;
          8:               { Actual purchase }
            begin
             fileflag:=1;
             editrec;
            end;
          9:                    { Income & Expenses }
             begin
             fileflag:=3;
	     editrec;
	     end;
       end;
get(screen);
300:scode[10]:=scode[5];
until (scode[10] in [ESC,LEFT,RIGHT,chr(altstate)]);
end;
end.

