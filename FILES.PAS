{ uses scode 1,7,8 }
procedure FileMenus;
var
   ext:string[4];
   matinp:stringlines;
   T:text;

begin
repeat
	nabt;
        shadow:=TRUE;
	box(2,3,31,12,single,28);

	menus^[1]:=' New                        ';
	menus^[2]:=' Retrieve                 '+chr(16)+' ';
	menus^[3]:=' Save                    F9 ';
	menus^[4]:=' Save as ...                ';
	menus^[5]:=' Create/edit IPM files    '+chr(16)+' ';
	menus^[6]:=' File maintainance        '+chr(16)+' ';
	menus^[7]:=' How to use ...             ';
	menus^[8]:=' Exit IMS-PM ...        F10 ';

	msgno:=20;

menus^[21]:='Start a new project.';
menus^[22]:='Load an existing project file from disk.';
menus^[23]:='Save current project to disk.';
menus^[24]:='Save current project to a specified filename.';
menus^[25]:='Create/edit secondary data files.';
menus^[26]:='Copy/delete/rename/print/list files.';
menus^[27]:='Provide help on using IMS-PM to a novice user.';
menus^[28]:='Close current session & exit to DOS.';

	scode[1]:=FMENU;
	boxpix(1,menus,'SQTMCC',3,4,20,11,1,choice[1],scode[1],1);
	urgentservice(scode[1]);

	msgno:=0;
	purpose:=0;                      { A very important statement }
	if scode[1]=ENTER then
	  case choice[1] of
		1:
		begin
                s:='';
		repeat
		readstrbox(1,5,5+choice[1],40,'New Project Name',s,excode);
		if excode<>ESC then fsplit(s,path,name,ext);
		until excode in [ESC,ENTER];

		if (excode=ENTER) and (nospace(name)<>'') then
		   begin
                   excode:=#0;
                   if exist(name+'.DAT') then
                     begin
                     smsg(' Project file already exists. Overwrite (Y/N) ? '+noise);
                     if not yes then excode:=ESC;
                     end;
                     if excode=#0 then
                        begin
                                saveguard;
				proname:=upstringf(name);
				sflag:=TRUE;
				release(heap);   { Release Heap to Starting state > dangerous process! }
				init_tables;
                        end;
		   end;
		end;
		 2:
		   begin
                   if nospace(rfname)='' then
                                             rfname:=proname;
		   for i:=1 to 16 do
				menus^[i]:=fixlength('',30,left);
		   i:=0;
                   repeat
			inc(i);
			filerec.name:='';
                        if i=1 then
			   findfirst('*.DAT',$3F,filerec)
			else
				findnext(filerec);
			fsplit(filerec.name,path,name,ext);
			menus^[i]:=' '+fixlength(name,29,LEFT);
		   until filerec.name='';

		   dec(i);           { No of files }
                   choice[7]:=1;
		   if i>0 then
                   repeat
                             shadow:=TRUE;
			     box(4,5+choice[1]-1,35,5+choice[1]+15+1,single,28);
                             vs(12,6,'Project Files',28);
			     scode[7]:=NOCHECK;
			     fileinfo(nospace(menus^[hv[1]+choice[7]-1]));
			     boxpix(1,menus,'',5,5+choice[1],35,5+choice[1]+15,hv[1],choice[7],scode[7],1);
                             urgentservice(scode[7]);

		   case scode[7] of     { To change pages }
			up: if (choice[7]=16) and (hv[1]>1) then
					begin
					dec(hv[1]);
					choice[7]:=1;
					end
					else
                                        if (choice[7]=16)
                                             then choice[7]:=1;
		     down: if (choice[7]=1) then
			   if (hv[1]+16<=i) then
					begin
					inc(hv[1]);
					choice[7]:=16;
					end
                        		else
                                        choice[7]:=16;

		     end;
                   if (nospace(menus^[hv[1]+choice[7]-1])='') and (choice[7]>1) then choice[7]:=i;
		   until scode[7] in [ESC,ENTER];

		   if (i>0) and (scode[7]=ENTER) then
		   if exist(nospace(menus^[hv[1]+choice[7]-1])+'.DAT') then
			begin
			     proname:=upstringf(nospace(menus^[hv[1]+choice[7]-1]));
			     flags[9]:=TRUE;
			     load(proname+'.DAT');
			end
		   else
				smsg('File not found.'+ESC);
		   end;
		 3:
		   begin
		        if (proname<>'') then save(proname) else msg(msg1);
		   end;
		 4:
		   begin
		   if sfname='' then sfname:=proname;
		   readstrbox(1,5,5+choice[1],40,'Save to', sfname,excode);
                   fsplit(sfname,path,name,ext);
                   sflag:=TRUE ;
		   if (excode<>ESC) and (nospace(name)<>'') then
                      begin
                      save(path+name);

copyf(proname+'.MAT',sfname+'.MAT');
copyf(proname+'.RAT',sfname+'.RAT');
copyf(proname+'.SNL',sfname+'.SNL');
copyf(proname+'.MPL',sfname+'.MPL');
copyf(proname+'.CIO',sfname+'.CIO');
copyf(proname+'.PRG',sfname+'.PRG');
copyf(proname+'.INF',sfname+'.INF');
copyf(proname+'.TXT',sfname+'.TXT');
copyf(proname+'.CAS',sfname+'.CAS');

                      end;
		   end;
		 5:
		 if (proname<>'') then
                 begin
                 repeat
		nabt;
                sbox(boxer,4,5+choice[1]-1,46,5+choice[1]+7);
                shadow:=TRUE;
	      box(4,5+choice[1]-1,52,5+choice[1]+7,single,28);
              vs(16,9,'Secondary data files',28);

		menus^[1]:=' '+fixlength(proname+'.INF',13,LEFT)+' : Project information           ';
	        menus^[2]:=' '+fixlength(proname+'.SNL',13,LEFT)+' : Subcontractors''s Name List    ';
	        menus^[3]:=' '+fixlength(proname+'.PRG',13,LEFT)+' : Contractors''s bill form       ';

	        menus^[4]:=' '+fixlength(proname+'.TXT',13,LEFT)+' : Material ratio file           ';
	        menus^[5]:=' '+fixlength(proname+'.TXT',13,LEFT)+' : Install material ratio file   ';
		menus^[6]:='                                               ';
		menus^[7]:='                                               ';

		scode[8]:=FMENU;

		boxpix(1,menus,'SQTMCC',5,5+choice[1],51,5+choice[1]+6,1,choice[8],scode[8],1);
                urgentservice(scode[8]);

		purpose:=0;                      { A very important statement }
		if (proname<>'') and (scode[8]=ENTER) then
                begin
                   ext:='';
		   case choice[8] of
		        1:ext:='.INF';
                        2:ext:='.SNL';
                        3:ext:='.PRG';
                        4:ext:='.TXT';
                        5:begin
                        s:=proname+'.TXT';
                        readstrbox(1,5,5+choice[1],40,'Install file',s,excode);

                        if excode<>ESC then
                           begin
assign(T,s);
{$I-}
reset(T);
{$I+}
if ioresult=0 then
begin
assign(matinp,PD+'IPM.MRF');
rewrite(matinp);
while not eof(T) do
      begin
      readln(T,s);
      write(matinp,s);
      end;
close(matinp);
close(T);
copyf(PD+'IPM.MRF',TD+'IPM.MRF');
end
   else   smsg('Can''t open file.'+ESC);

                           end;
                        end;
                        end;
	         if ext<>''  then
                            begin
			      attrib:='W';
			      editfile(proname+ext);
			      update_namelist;
		            end;
                 end
		     until scode[8]=ESC;
                     rbox(boxer);
		   end;
		6:
		 begin
           choice[8]:=1;
	   repeat
		nabt;
                sbox(boxer,4,5+choice[1]-1,46,5+choice[1]+6);
                shadow:=TRUE;
	        box(4,5+choice[1]-1,36,5+choice[1]+6,single,28);
                vs(12,10,'File Maintenance',28);

		menus^[1]:=' Edit                          ';
		menus^[2]:=' Copy                          ';
		menus^[3]:=' Delete                        ';
		menus^[4]:=' Rename                        ';
                menus^[5]:=' Print                         ';
		menus^[6]:=' List                          ';

                scode[8]:=FMENU;
		boxpix(1,menus,'SQTMCC',5,5+choice[1],35,5+choice[1]+5,1,choice[8],scode[8],1);
                urgentservice(scode[8]);

		purpose:=0;                      { A very important statement }
                flags[5]:=TRUE;

		if scode[8]=ENTER then
		   case choice[8] of
		        1:
                          begin
                               attrib:='W';
                               editf('');
                               flags[5]:=FALSE;
                          end;
		        2:copyf('','');
                        3:deletef('');
                        4:renamef('','');
                        5:printf('');
                        6:dirf;
                     end;
             	     until scode[8]=ESC;
                     rbox(boxer);
                  flags[5]:=FALSE;
                  end;
		7:begin
                  end;
		8:begin
                       saveguard;
                       halt;
                  end;
	 end;
get(screen);
scode[10]:=scode[1];
until (scode[10] in [ESC,LEFT,RIGHT,chr(altstate)]);
end;
