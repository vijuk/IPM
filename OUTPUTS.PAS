
unit outputs;{ uses scode 3,8,9 }

interface
uses lib,ilib,extra,olib,cash,editor,t,crt;

var
   breaksd,breakfd:datetype;  { used to pass parameters to break() }
   BREAKACT:integer;
   s1,s2,s3,s4:string[80];  {#debug vars}

const

   MAX_NUM_MAT=100; { Max. limit 1500 }
   inpbreak:boolean=FALSE; { To be used when "break"ing from inputs unit }

procedure break(brk:byte);
procedure outputmenus;
implementation

function matratio(sheet1:psheettype1;ds,de:datetype):real;
label 100;
var
   LR:string[2];
   dura,pdura:integer;
   rat:real;

begin

with sheet1^ do
		begin
                     { if activity false left of period }

		     datecheck(ds[1],ds[2],ds[3],fd[1],fd[2],fd[3],dater);
                     if dater<0 then goto 100;

                     { if activity false right of period }

		     datecheck(sd[1],sd[2],sd[3],de[1],de[2],de[3],dater);
                     if dater<0 then goto 100;

                     LR[0]:=#2;

		     datecheck(ds[1],ds[2],ds[3],sd[1],sd[2],sd[3],dater);
                     if dater<0 then LR[1]:='L' else LR[1]:='R';

		     datecheck(de[1],de[2],de[3],fd[1],fd[2],fd[3],dater);
                     if dater<0 then LR[2]:='L' else LR[2]:='R';

{
                date2str(ds,s1);
                date2str(de,s2);
                date2str(sd,s3);
                date2str(fd,s4);
                writeln(s1,' ',s2,' A:>  ',s3,' ',s4);

}

                     if LR='LL' then
                        dura:=duradays(ds[1],ds[2],ds[3],fd[1],fd[2],fd[3]);

                     if LR='LR' then
                        dura:=duradays(ds[1],ds[2],ds[3],de[1],de[2],de[3]);

                     if LR='RL' then
                        dura:=duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]);

                     if LR='RR' then
                        dura:=duradays(sd[1],sd[2],sd[3],de[1],de[2],de[3]);

{
                      smsg(LR+': '+strint(dura,1)+ESC);
}

                 pdura:=duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]);
                 if pdura>0 then rat:=dura/pdura else rat:=0;

                 if rat>1 then
                          smsg('Internal Error!.'+ESC);
                 matratio:=rat;
                 exit;
	end;
100: matratio:=0;
exit;
end;

procedure break(brk:byte);
label exitbreak;
var
	matrec:matrectype;
	matfile:file of matrectype;
	i,j,k:integer;
        heap1:pointer;
        s1,s2:string;
        flag:boolean;

type
	matmaptype=record
                         mat:string[10];
			 quant:real;
			 mu:string[4];
		end;

        xtype=array[1..MAX_NUM_MAT] of matmaptype;
        cashrectype=record
                      name:string[10];
                      mun:string[4];
                      cash1,cash2:real;
                      d1,d2:datetype;
                      end;

var
        rec:^xtype;
        no,norec:integer;
        ds,de,cds,cde:datetype;
        cashrec:cashrectype;
        cashfile:file of cashrectype;
        cashrs:real;
        purchfile:file of purchdatetype;
        z:integer;
        tempcash,tempqty:real;
        c:char;

procedure readdates(var ds,de:datetype);
var
   rdura:real;
   i,err:integer;
   dura:integer;

begin
   s:='';
   repeat
           nabt;
	   readstr(1,' From : ',s);
	   str2date(s,ds[1],ds[2],ds[3]);
	   readKSbuff:='E';
   until not errorflag or escf or aborted;

   s:='';
   repeat
	errorflag:=FALSE;
        nabt;
	 readstr(1,' To   : ',s);
         upstring(s);
	 if (pos('/',s)=0) then
		begin
		   myval(s,rdura,err);
		   dura:=round(rdura);
	   if err=0 then
			dura_2_days(ds[1],ds[2],ds[3],dura,de[1],de[2],de[3])
		   else
			errorflag:=TRUE;
		end
	     else
		begin
		   str2date(s,de[1],de[2],de[3]);
		   readKSbuff:='E';
		   datecheck(ds[1],ds[2],ds[3],de[1],de[2],de[3],dater);
		end;
	until not errorflag or escf or aborted;
end;

    procedure fillrec;
    begin
	with matrec do
	if sx[k]<>'' then
				begin
				no:=1;
				while (no<=norec) and
			      ((upstringf(nospace(rec^[no].mat))<>upstringf(nospace(sx[k])))
				      or
				      (upstringf(nospace(rec^[no].mu))<>upstringf(nospace(su[k]))))
                                      do
                                           inc(no);

                                if no>99 then
                                   smsg('E.1 : Size declaration exceeded!.'+ESC);

				if brk=3 then c:='S' else c:='A';
                                if brk=6 then
                                       flag:=TRUE
                                   else
                                       flag:=FALSE;

				if no=norec+1 then
					begin
						inc(norec);
						rec^[no].mat:=sx[k];
						rec^[no].quant:=sv[k]*gt(c,d,flag);
						rec^[no].mu:=su[k];
					end
				  else
					rec^[no].quant:=rec^[no].quant+sv[k]*gt(c,d,flag);

				  end;
	end;

procedure inp_break4;
var k,wx:integer;
    inpavail:boolean;
begin
wx:=wherex;
takerec(BREAKACT);
reset(matfile);

{
msg('*'+uns(fixlength(sheet1^.activity,25,LEFT)+'*'));
waitfor(ESC);
}
while not eof(matfile) and
      not(sheet1^.activity=matrec.desc) do
                                  read(matfile,matrec);
{
                                  msg('!'+uns(matrec.desc)+'! Press ESC.');
                                  waitfor(ESC);
}


if sheet1^.activity=matrec.desc
	                	then
begin
memdispflag:=FALSE;
push;
inpavail:=FALSE;

	for k:=1 to 10 do
	with matrec do
	if sx[k]<>'' then
        begin
        writeln('   ',fixlength(sx[k],15,LEFT),' = ',
		justify(sv[k]*gt('S',d,FALSE)*matratio(st_sheet,ds,de),6,2,RIGHT),' ',
		fixlength(su[k],4,LEFT));
        gotoxy(wx,wherey);
        inpavail:=TRUE;
        end;

if not inpavail then
      smsg('Input data not available or units inconsistant.'+ESC);

pop;
memdispflag:=TRUE;
end;

end;

    { ********** BREAK MAIN *********** }

begin
nabt;
errorflag:=FALSE;
escf:=FALSE;
copyf(proname+'.MAT',TD+proname+'.MAT');
assign(matfile,TD+proname+'.MAT');
{$I-}
reset(matfile);
{$I+}
if ioresult<>0 then
	begin
		smsg(' Could not open '+proname+'.MAT'+ESC);
                scode[8]:=ESC;
		exit;
	end;

if brk=5 then
        begin
        cashrs:=0;
        copyf(proname+'.SPD',TD+proname+'.SPD');
        assign(purchfile,TD+proname+'.SPD');
        {$I-}
        reset(purchfile);
        {$I+}
        if ioresult<>0 then
                         begin
		           smsg('Could not open '+proname+'.SPD'+ESC);
                           close(matfile);
                           scode[8]:=ESC;
                           exit;
                         end;

        copyf(proname+'.RAT',TD+proname+'.RAT');
        assign(datamatf,TD+proname+'.RAT');
        {$I-}
        reset(datamatf);
        {$I+}

        if ioresult<>0 then
                           begin
                           close(purchfile);
                           close(matfile);
                           smsg('Can''t not open '+proname+'.RAT'+ESC);
                           scode[8]:=ESC;
                           exit;
                           end;

        if exist(proname+'.CAS') then
                              begin
				 copyf(proname+'.CAS',TD+'CASH.IPM');
                                 assign(cashfile,TD+'CASH.IPM');
                                 {$I-}
                                 reset(cashfile);
                                 {$I+}
                                 if ioresult<>0 then
                                    begin
					close(purchfile);
					close(datamatf);
					close(matfile);
                                        smsg('CASH.IPM not found.'+ESC);
					exit;
                                    end;
                               end
                       else
		           begin
			        assign(cashfile,TD+'CASH.IPM');
			        rewrite(cashfile);
		           end;
        end;

if brk=4 then
         if not inpbreak then
                         readdates(ds,de)
                else
                for i:=1 to 3 do
                    begin
                    ds[i]:=breaksd[i];
                    de[i]:=breakfd[i];
                    end;

if brk=5 then readdates(cds,cde);

if escf or aborted then
   begin
        close(matfile);
        if brk=5 then
           begin
           close(purchfile);
           close(datamatf);
           close(cashfile);
           end;
        nabt;
        exit;
   end;

if printmode and printerready then
        out_2_prn
   else
   if not inpbreak then
      begin
        assign(out,TD+'TEMP.IPM');
        rewrite(out);
        writeln(out);
      end;

if not inpbreak
   then
       begin
          msgattr:=156;
          msg('Please wait...');
          msgattr:=attr;
       end;

mark(heap1);
if memok(sizeof(rec^)) then
                           new(rec)
                       else
                           begin
                           smsg('Insufficient memory.'+ESC);
                           goto EXITBREAK;
                           end;
no:=1;
norec:=0;

with rec^[1] do
     begin
	  mat:='*****';
          quant:=0;
          mu:='';
     end;

for i:=1 to MAX_NUM_MAT do rec^[i].quant:=0;
matrec.desc:='~~~~~~~~~~~';

if inpbreak
   then
       inp_break4         { called from sch purch dates input }
   else

begin
for i:=1 to No_act do
	begin
		takerec(i);
                if sheet1^.sd[1]=0 then
                   begin
                   smsg(p0i(i,3)+' : dates not specified.'+ESC);
                   goto EXITBREAK;
                   end;

                reset(matfile);
		while not eof(matfile) and
		not (sheet1^.activity=matrec.desc) do
						read(matfile,matrec);

		if nospace(upstringf(sheet1^.activity))=nospace(upstringf(matrec.desc))
	                	then
begin
if brk=5 then              { cash alloc }
begin
purchdate.purchact:='~~~~~~~~~~';
reset(purchfile);
while not eof(purchfile) and nomatch do
                           begin
                           read(purchfile,purchdate);
{
                           with purchdate do
                                 begin
                                      writeln(sheet1^.activity,'***',purchact);
                                      waitfor(ENTER);
                                 end;
}
                           end;

{
   if nomatch then
              begin
              pop;
              smsg('Error in Material rate file entry.'+ESC);
              goto EXITBREAK;
              end;
}

end;

push;

{*}	if brk in [1,2,4] then
	      begin
		writeln(out);
		if matrec.sx[1]<>'' then
		   if st_sheet^.activity='' then
			write(out,' ',fixlength('NONAME : ',40,LEFT))
		    else
			write(out,' ',fixlength(st_sheet^.activity,40,LEFT),' : ');
	      end;

if brk=2 then
         begin
         writeln(out);
         writeln(out);
         for j:=1 to No_act do
		begin
		takerec(j);
		{writeln(out);}
		if matrec.sx[1]<>'' then
                   if sheet1^.code='' then
			    write(out,'    ','NONAME : ')
			else
			    write(out,'    ',fixlength(sheet1^.code,6,LEFT),' : ');

	for k:=1 to 10 do
		with matrec do
		if sx[k]<>'' then
			write(out,fixlength(sx[k],6,LEFT),'=',
			justify(sv[k]*sheet1^.quantity,6,2,RIGHT),
			fixlength(su[k],4,LEFT),' ');
                writeln(out);
		end;

        end;

if brk in [1,3,6,4,5] then
	for k:=1 to 10 do
	with matrec do

if brk in [1,4,5] then
	begin

if brk<>6 then
 if sx[k]<>'' then
        if brk=1
           then
	           write(out,' ',fixlength(sx[k],6,LEFT),'=',
                     justify(sv[k]*gt('S',d,FALSE),6,2,RIGHT),fixlength(su[k],4,LEFT),' ')
           else
                if brk=4 then
                   write(out,' ',fixlength(sx[k],6,LEFT),'=',
       		     justify(sv[k]*gt('S',d,FALSE)*matratio(st_sheet,ds,de),6,2,RIGHT),
			fixlength(su[k],4,LEFT),' ');

{*** Cash allocation begins }

if (sx[k]<>'') and (brk=5) then
      begin
      ds[1]:=st_sheet^.sd[1];
      ds[2]:=st_sheet^.sd[2];
      ds[3]:=st_sheet^.sd[3];

      z:=0;
      repeat
      inc(z);
      dura_2_days(ds[1],ds[2],ds[3],purchdate.diffsd[z],de[1],de[2],de[3]);
      datecheck(ds[1],ds[2],ds[3],st_sheet^.fd[1],st_sheet^.fd[2],st_sheet^.fd[3],dater);

      if not errorflag then with cashrec do
            begin
            reset(datamatf);
                while not eof(datamatf) and
		not ( (upstringf(nospace(sx[k]))=
		upstringf(nospace(datamat.mat)))
                and
                (upstringf(nospace(su[k]))=
                upstringf(datamat.muni))) do
					begin
                                        read(datamatf,datamat);

                                        end;

		if ((upstringf(nospace(sx[k]))=
		upstringf(nospace(datamat.mat)))
                  and
                (upstringf(nospace(su[k]))=
		upstringf(nospace(datamat.muni)))
                ) then
                begin
                name:=sx[k];
		  tempcash:=sv[k]*gt('S',d,FALSE)*matratio(st_sheet,ds,de)*datamat.rate;
                  cash1:=datamat.cashp[1]/100*tempcash;
                  cash2:=datamat.cashp[2]/100*tempcash;
                  dura_2_days(ds[1],ds[2],ds[3],datamat.days[1],d1[1],d1[2],d1[3]);
                  dura_2_days(ds[1],ds[2],ds[3],datamat.days[2],d2[1],d2[2],d2[3]);
                  mun:=su[k];

                  write(cashfile,cashrec);
                  date2str(ds,s1);
                  date2str(de,s2);

                  dura_2_days(de[1],de[2],de[3],1,ds[1],ds[2],ds[3]);
                  end
                  else
                  begin
{
writeln(upstringf(nospace(sx[k])),'>>',upstringf(nospace(datamat.mat)),
'::',upstringf(nospace(su[k])),'>>',upstringf(datamat.muni));
waitfor(ENTER);
}
                  smsg(sx[k]+' '+su[k]+' : rate absent / unit mismatch.'+ESC);
                  scode[8]:=ESC;
                  goto EXITBREAK;
                  end;

            end;
      until errorflag or (z=80);
      if z=80 then
         begin
         {smsg(ESC);}
         goto EXITBREAK;
         end;
	end;

        end
	else
		begin
			fillrec;
			if brk=4 then writeln(out);
		end;
        pop;
end;

if brk=5 then
begin
      {$I-}
      seek(cashfile,0);
      {$I+}
      if ioresult<>0 then
                     begin
                     smsg('Cash file not found'+ESC);
                     goto EXITBREAK;
                     end;
      while not eof(cashfile) do
            begin
	    read(cashfile,cashrec);
            with cashrec do
                 begin
                 errorflag:=FALSE;
                 datecheck(cds[1],cds[2],cds[3],d1[1],d1[2],d1[3],dater);

                 if not errorflag then
                    begin
                    errorflag:=FALSE;
                    datecheck(cde[1],cde[2],cde[3],d1[1],d1[2],d1[3],dater);
                    if errorflag then
                       cashrs:=cashrs+cash1;
                    errorflag:=FALSE;
                    end;

                 datecheck(cds[1],cds[2],cds[3],d2[1],d2[2],d2[3],dater);
                 if not errorflag then
                    begin
                 errorflag:=FALSE;
                    datecheck(cde[1],cde[2],cde[3],d2[1],d2[2],d2[3],dater);
                    if errorflag then
                       cashrs:=cashrs+cash2;
                    end;
                 end;
            end;
  end;
      { End of cash allocation }
end;

if brk=5 then
   begin
        date2str(cds,s1);
        date2str(cde,s2);
        writeln(out,' Cash required for the period from ',
                s1,' to ',s2,' =   Rs. ',cashrs:1:2,'/-');
   end;

no:=1;
if brk=6 then            { Stock register }
		begin
                copyf(proname+'.MPL',TD+proname+'.MPL');
		assign(datamatf,TD+proname+'.MPL');
		{$I-}
                reset(datamatf);
		{$I+}
                if ioresult<>0 then
                               begin
                               smsg(' Could not open '+proname+'.MPL'+ESC);
                               scode[8]:=ESC;
                               goto EXITBREAK;
                               end;
                end;

if brk in [3,6] then
   while no<=norec do
	begin
	if brk=3 then
	         begin
	         if no=1 then
			begin
		     writeln(out,' TOTAL REQUIREMENT OF MATERIALS ',
				   fixlength('Date : '+date,46,RIGHT));
			     writeln(out);
			end;
		 with rec^[no] do
			writeln(out,' ',fixlength(mat,12,LEFT),' = ',quant:6:3,mu);
                 end
        else
        begin
        if no=1 then
		begin
		     writeln(out,' MATERIAL PURCHASE, THEORETICAL CONSUMPTION AND STOCK. ',
			   fixlength('Date : '+date,23,RIGHT));
	     writeln(out);

writeln(out,' NO. ',fixlength('MATERIAL',20,LEFT),
	'    UNIT',
	fixlength('PURCHASED',15,RIGHT),
	fixlength('CONSUMED',15,RIGHT),
	fixlength('BALANCE',15,RIGHT));
	writeln(out);
		end;

	tempqty:=0;
	reset(datamatf);
	while not eof(datamatf) do
	  begin
	    read(datamatf,datamat);
	    if ((upstringf(nospace(rec^[no].mat))=
		upstringf(nospace(datamat.mat)))
	    and
                (upstringf(nospace(rec^[no].mu))=
		upstringf(nospace(datamat.muni))))
			then
				tempqty:=tempqty+datamat.qty;
	  end;
     if (tempqty-rec^[no].quant)<0 then
		msg(' Error: Purchased material less than consumed material.'+ESC);
     writeln(out,no:3,'. ',fixlength(rec^[no].mat,20,LEFT),
		fixlength(rec^[no].mu,8,RIGHT),tempqty:15:3,
		rec^[no].quant:15:3,(tempqty-rec^[no].quant):15:3);
     end;
     inc(no);
end;
if brk=5 then
         copyf(TD+'CASH.IPM',proname+'.CAS');
end;

EXITBREAK:
if pushed then pop;

{$I-}
if brk=5 then
   begin
       close(purchfile);
       close(datamatf);
       close(cashfile);
   end;

if brk=6 then close(datamatf);
close(matfile);
{$I+}


{if ioresult<>0 then smsg('Incomplete input ?!'+ESC);}

if not inpbreak then
   begin
{$I-}
   writeln(out);
   close(out);
{$I+}
   end;

outname:='CON';

{
assign(out,
assigncrt(out);
setfile(out,outname,'CON','W',excode);}

release(heap1);
if not inpbreak and not printmode then editf(TD+'TEMP.IPM');
end;

procedure OutputMenus;
label 200;
begin
repeat
      nabt;
      shadow:=TRUE;
      box(10*(opt-1)+2,3,10*(opt-1)+31,14,single,28);
		menus^[1]:=' Bar chart (Textmode)       ';
		menus^[2]:=' Bar chart (Graphics)       ';
                menus^[3]:=' Progress Curve             ';
                menus^[4]:=' Progress Chart             ';
		menus^[5]:=' Subcontractor''s bill     '+chr(16)+' ';
		menus^[6]:=' Contractor''s bill          ';
		menus^[7]:=' Material requirements    '+chr(16)+' ';
		menus^[8]:=' Cash requirements        '+chr(16)+' ';
                menus^[9]:=' Material stock             ';
               menus^[10]:=' Cash flow curve            ';

menus^[21]:='Barchart with actual work progress in textmode.';
menus^[22]:='Barchart with actual work progress in graphics.';
menus^[23]:='Graph : scheduled vs. actual progress';
menus^[24]:='Variation in actual & scheduled progress';
menus^[25]:='Prepare bill for a subcontractor upto a specified closing date';
menus^[26]:='Prepare bill for contractor upto a specified closing date';
menus^[27]:='Requirement of material & labour according to material ratios';
menus^[28]:='Requirement of cash for a period according to scheduled purchase';
menus^[29]:='Purchase, theoretical consumption and stock of materials';
menus^[30]:='Graph : Income vs. expense';

scode[3]:=FMENU;
msgno:=20;
boxpix(1,menus,'BWPMSCMCR',10*(opt-1)+3,4,10*(opt-1)+30,13,1,choice[3],scode[3],1);
urgentservice(scode[3]);
msgno:=0;

if (scode[3]=ENTER) and (nospace(proname)<>'') then
	case choice[3] of
		1:TextBar;
                2:Barchart(1);
                3:Barchart(2);
                4:Barchart(3);
		5:
                  begin


shadow:=TRUE;
sbox(boxer,10*(opt-1)+18,9,10*(opt-1)+34,13);
box(10*(opt-1)+18,9,10*(opt-1)+33,12,single,28);

		menus^[1]:=' Abstract     ';
		menus^[2]:=' Detailed     ';

menus^[21]:='Abstract form for subcontractor''s bill.';
menus^[22]:='Working notes for subcontractor''s bill.';

scode[8]:=#0;
choice[8]:=1;
msgno:=20;
boxpix(1,menus,'AD',10*(opt-1)+19,10,10*(opt-1)+34,11,1,choice[8],scode[8],1);
urgentservice(scode[8]);
msgno:=0;
rbox(boxer);

if scode[8]=ENTER then
begin
                  msg('Searching for closing dates. Please wait...');
                  update_namelist;
		  sel_name_date(10*(opt-1)+4,9,'Subcontractor''s Name',namelist,no_names,subname);
                  if (scode[9]=ESC) then goto 200;
		  errorflag:=FALSE;

		  s:='';
		  d[2]:=0;
	  repeat
		      sel_date(SC_D,10*(opt-1)+4,9);
		      if scode[9]=ESC then
                                      begin
                                      {
                                      pressed ESC/
                                      smsg('E.100: No closing dates entered.'+ESC);
                                      }
                                      goto 200;
                                      end;
		      str2date(s,d[1],d[2],d[3]);
	  until not errorflag or aborted;

if not aborted then
begin
msg('Computing...');
for i:=1 to No_act do
	begin
	     takerec(i);
	     tprev:=0;
		tpres:=0;
		bal:=0;
			push;
			for j:=1 to No_act do
				begin
				takerec(j);
				errorflag:=FALSE;
			with sheet1^ do
			if (stat=1) and (uns(sub_id)=uns(subname)) then
				begin
				datecheck(d[1],d[2],d[3],cd[1],cd[2],cd[3],dater);
				{
                                if errorflag then
						tprev:=tprev+quantity
					else
						tpres:=tpres+quantity;
				}
				if dater=0 then
						tpres:=tpres+quantity
                                else
                                if errorflag then
						tprev:=tprev+quantity
                                else
                                    bal:=bal+quantity;
                                end
				else
					bal:=bal+quantity;
				end;
			pop;

	with sheet1^ do
		begin
		prev:=tprev;
		pres:=tpres;
		if not eq(quantity-(prev+pres),bal) then
		     smsg(' Results unusable due to errors.'+ESC);
		end;

	end;
	if choice[8]=1 then sheet(SC_A);
	if choice[8]=2 then sheet(SC_D);
        end;
end;
      end;
	       6:
                  begin
		  errorflag:=FALSE;
		  s:='';
		  d[2]:=0;
                  update_namelist;
		  repeat
		      sel_date(CB,10*(opt-1)+4,10);
		      if scode[9]=ESC then goto 200;
		      str2date(s,d[1],d[2],d[3]);
	          until not errorflag or aborted;

if not aborted then
begin
for i:=1 to No_act do
	begin
	     takerec(i);
	     tprev:=0;
		tpres:=0;
		bal:=0;
			push;
			for j:=1 to No_act do
				begin
				takerec(j);
				errorflag:=FALSE;
			with sheet1^ do
			if (stat=1) then
				begin
				datecheck(d[1],d[2],d[3],cd[1],cd[2],cd[3],dater);
				{
                                if errorflag then
						tprev:=tprev+quantity
					else
						tpres:=tpres+quantity;
				}
				if dater=0 then
						tpres:=tpres+quantity
                                else
                                if errorflag then
						tprev:=tprev+quantity
                                else
                                    bal:=bal+quantity;
                                end
				else
					bal:=bal+quantity;
				end;
			pop;

	with sheet1^ do
		begin
		prev:=tprev;
		pres:=tpres;
  	if not eq(quantity-(prev+pres),bal) then
			smsg(' Results unusable due to errors.'+ESC);
		end;

	end;
                sheet(CB);
        end;
		end;
		7:
repeat
      nabt;
      shadow:=TRUE;
      box(10*(opt-1)+15,11,10*(opt-1)+36,16,single,28);

		menus^[1]:=' Activity-wise      ';
		menus^[2]:=' Item-wise          ';
		menus^[3]:=' Material-wise      ';
		menus^[4]:=' Duration-wise      ';

menus^[21]:='Material requirement for each activity of the project.';
menus^[22]:='Material requirement for each item of an activity.';
menus^[23]:='List of materials and its requirement for the project.';
menus^[24]:='Material requirement for a specified duration.';

choice[8]:=1;
scode[8]:=#0;
msgno:=20;
boxpix(1,menus,'AIMD',10*(opt-1)+16,12,10*(opt-1)+35,15,1,choice[8],scode[8],1);
urgentservice(scode[8]);
msgno:=0;
inpbreak:=FALSE;

if (scode[8]=ENTER) then
	case choice[8] of
		1:break(1);
		2:break(2);
		3:break(3);
		4:break(4);
	end;
until scode[8]=ESC;

               8:break(5);
               9:
                 begin
                  s:='';
		  d[2]:=0;
                  errorflag:=FALSE;
                  aborted:=FALSE;
                  msg('Searching for closing dates. Please wait...');
                  update_namelist;
	  repeat
		      sel_date(100 {sheettype} ,10*(opt-1)+4,13);
		      if scode[9]=ESC then
                                      begin
                                      {
                                      smsg('E.100: No closing dates entered.'+ESC);
                                      }
                                      goto 200;
                                      end;
		      str2date(s,d[1],d[2],d[3]);
	  until not errorflag or aborted;

                 break(6);
                 end;
              10:barchart(4);
	      end;
200:          get(screen);
scode[10]:=scode[3];
aborted:=FALSE;
until (scode[3] in [ESC,LEFT,RIGHT,chr(altstate)]);
end;
end.














