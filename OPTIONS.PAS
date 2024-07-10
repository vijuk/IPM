
{ uses scode 6 }

procedure OptionMenus;
var
	optvar,dispvar,soundvar:string[10];
begin
repeat
nabt;
shadow:=TRUE;
box(32,3,62,10,single,28);

if lastmode=mono then
                     dispvar:='Monocrome'
                 else
                     dispvar:='Color';
if optmem then
              optvar:='Memory'
          else
              optvar:='Speed';

if soundon then
		   soundvar:='On'
           else
		   soundvar:='Off';

        menus^[1]:=' Output to    ';
	menus^[2]:=' Paper size   ';
	menus^[3]:=' Time axis    ';

	menus^[4]:=' Display      '+fixlength(dispvar,15,LEFT);
	menus^[5]:=' Optimize     '+fixlength(optvar,15,LEFT);
	menus^[6]:=' Sound        '+fixlength(soundvar,15,LEFT);


if printmode then
			menus^[1]:=menus^[1]+'Printer        '
                 else
			menus^[1]:=menus^[1]+'Screen         ';

if col80 then
		 menus^[2]:=menus^[2]+'80 column      '
             else
		 menus^[2]:=menus^[2]+'132 column     ';

if adjust then
		 menus^[3]:=menus^[3]+'Project time   '
	 else
		 if col80 then
			menus^[3]:=menus^[3]+'1.5 Years      '
			else
			menus^[3]:=menus^[3]+'3 Years        ';


menus^[21]:='Sets output device to screen or printer.';
menus^[22]:='Specify paper size used in printer.';
menus^[23]:='Specify method used to scale time axis in bar chart.';
menus^[24]:='Toggles monochrome and color display modes.';
menus^[25]:='Optimize memory for large projects and speed for small projects.';
menus^[26]:='Enables or disables sound for software messages.';

scode[6]:=FMENU;
msgno:=20;
boxpix(1,menus,'SQTMCC',33,4,61,9,1,choice[6],scode[6],1);
urgentservice(scode[6]);
msgno:=0;

purpose:=0;                      { A very important statement }
if (scode[6]=ENTER) then
  case choice[6] of
	 1: printmode := not printmode;
	 2: col80     := not col80;
	 3: adjust    := not adjust;
         4:
           begin
           if lastmode=mono then
              begin
              textmode(co80);
              Vseg:=$b800;
              textattr:=112;
  for j:=1 to 24*80 do write('°');
  bottombar;
  hpixcode:=NOREAD;
  hline(1,2,80,196,5);
  textattr:=9;
  Centre('IMS TRICHUR');
  hpix(1,1,80,head,opt,hpixcode);
  vs(60,1,'IMS Project Manager',123);
  put(screen);
              end
               else
               begin
                      textmode(mono);

               Vseg:=$b000;
               textcolor(white);
               textbackground(black);

  bottombar;
  hpixcode:=NOREAD;
  hline(1,2,80,196,5);
  textattr:=9;
  Centre('IMS TRICHUR');
  hpix(1,1,80,head,opt,hpixcode);
  vs(60,1,'IMS Project Manager',123);
  put(screen);
               end;
	   end;
	 5: optmem    := not optmem;
	 6: soundon   := not soundon;
  end;

scode[10]:=scode[6];
until (scode[10] in [ESC,LEFT,RIGHT,chr(altstate)]);
end;
