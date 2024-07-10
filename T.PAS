
{Note:Functions get(syear,smonth,sday,eyear,emonth,eday) has to be called in sequence }
unit t;
interface
uses lib,ilib,graph,crt,cash;
procedure heading;
procedure prodays;
procedure Barchart(incode:byte);
procedure textbar;

const y3d=4390;
type
    ar36=array[1..y3d] of real;
var
   heap2:pointer;
  maxx, maxy  : word;     { the maximum resolution of the screen }
  errorcode   : integer;  { reports any graphics errors }
  maxcolor    : word;     { the maximum color value available }
  oldexitproc : pointer;  { saves exit procedure address }

  {
  schcut,actcut:real;
  sad:datetype;
  }

  xx:integer;
  produra:integer;
  eprod,aprod:^ar36;

implementation
var
   dd:datetype;
procedure date2type(x,y,z:integer;var dt:datetype);
begin
dt[1]:=x;
dt[2]:=y;
dt[3]:=z;
end;

procedure prodays;
begin
  syear:=getsyear;
  smonth:=getsmonth;
  sday:=getsday;

  eyear:=geteyear;
  emonth:=getemonth;
  eday:=geteday;
  produra:= duradays(sday,smonth,syear,eday,emonth,eyear);
end;

procedure mysetcolor(color:byte);
begin
if color<=maxcolor then
                        setcolor(color)
                   else
                       setcolor(maxcolor);
end;

procedure fullport;
{ set the view port to the entire screen }
begin
  setviewport(0, 0, maxx, maxy, clipon);
end; { fullport }

procedure defaultcolors;
{ select the maximum color in the palette for the drawing color }
begin
  setcolor(maxcolor);
end; { defaultcolors }

procedure drawBorder;
{ draw a border around the current view port }
var
  viewport : viewporttype;
begin
  defaultcolors;
  setlinestyle(solidln, 0, normWidth);
  getviewsettings(viewport);
  with viewport do
    rectangle(0, 0, x2-x1, y2-y1);
end; { drawBorder }

procedure statusline(msg : string);
{ display a status line at the bottom of the screen }
begin
  fullport;
  defaultcolors;
  settextstyle(defaultfont, horizdir, 1);
  settextjustify(centertext, toptext);
  setlinestyle(solidln, 0, normWidth);
  setfillstyle(emptyfill, 0);
  Bar(0, maxy-(textheight('m')+4), maxx, maxy);      { erase old status line }
  rectangle(0, maxy-(textheight('m')+4), maxx, maxy);
  mysetcolor(magenta);
  outtextxy(maxx div 2, maxy-(textheight('m')+2), msg);
  { go back to the main window }
  setviewport(1, textheight('m')+5, maxx-1, maxy-(textheight('m')+5), clipon);
end; { statusline }

procedure Waittogo;
{ Wait for the user to abort the program or continue }
var  ch : char;
begin
  statusline('integrated management services,trichur.');
  repeat until Keypressed;
  ch := readKey;
  if ch = #0 then ch := readkey;      { trap function keys }
  if ch = esc then
    halt(0)                           { terminate program }
  else
    cleardevice;                      { clear screen, go on with demo }
end; { Waittogo }

procedure initialize;
var
   graphdriver:integer;
   graphmode:integer;

{ initialize graphics and report any errors that may occur }
var
  ingraphicsmode : boolean; { flags initialization of graphics mode }
  pathtodriver   : string;  { stores the dos path to *.Bgi & *.chr }
begin
  { when using crt and graphics, turn off crt's memory-mapped writes }

  directvideo := false;
  pathtodriver := 'c:\pascal';
  repeat

{$ifdef Use8514}                          { check for Use8514 $define }
    graphdriver := iBm8514;
    graphmode := iBm8514hi;
{$else}
    graphdriver := detect;                { use autodetection }
{$endif}
    initgraph(graphdriver, graphmode, pathtodriver);
    errorcode := graphresult;             { preserve error return }
    if errorcode <> groK then             { error? }
    begin
      Writeln('graphics error: ', grapherrormsg(errorcode));
      if errorcode = grfilenotfound then  { can't find driver file }
      begin
        Writeln('enter full path to Bgi driver or type <ctrl-Break> to quit:');
        readln(pathtodriver);
        Writeln;
      end
      else
        halt(1);                          { some other error: terminate }
    end;
  until errorcode = groK;
  randomize;                { init random number generator }
  maxcolor := getmaxcolor;  { get the maximum allowable drawing color }
  maxx := getmaxx;          { get screen resolution values }
  maxy := getmaxy;
end; { initialize }

procedure mainWindow(header : string);
{ make a default window and view port for demos }
begin
  defaultcolors;                           { reset the colors }
  cleardevice;                             { clear the screen }
  settextstyle(defaultfont, horizdir, 1);  { default text font }
  settextjustify(centertext, toptext);     { left justify text }
  fullport;
  mysetcolor(cyan);                        { full screen view port }
  outtextxy(maxx div 2, 2, header);        { draw the header }
  { draw main window }
  setviewport(0, textheight('m')+4, maxx, maxy-(textheight('m')+4), clipon);
  drawBorder;                              { put a border around it }
  { move the edges in 1 pixel on all sides so border isn't in the view port }
  setviewport(1, textheight('m')+5, maxx-1, maxy-(textheight('m')+5), clipon);
end; { mainWindow }

function randcolor : word;
{ returns a random non-zero color value that is within the legal
  color range for the selected device driver and graphics mode.
  maxcolor is set to getmaxcolor by initialize }
begin
  randcolor := random(maxcolor)+1;
{  if maxcolor<4 then randcolor:=maxcolor; #}
end; { randcolor }

procedure heading;
const
  Seed   = 1962; { A seed for the random number generator }
  NumPts = 1000; { The number of pixels plotted }
var
  I : word;
  X, Y, Color : word;
  XMax, YMax  : integer;
const
  DelayValue = 50;  { milliseconds to delay }
var
  ViewInfo      : ViewPortType;
  Left, Top     : integer;
  Right, Bottom : integer;
  Step          : integer; { step for rectangle shrinking }
  longi:longint;
  count:integer;

procedure pixplay1;
begin
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    XMax := (x2-x1-1);
    YMax := (y2-y1-1);
  end;
{
while not KeyPressed do
  begin
}
    {  Plot random pixels  }
    Randseed:=Seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      PutPixel(Random(XMax)+1, Random(YMax)+1, RandColor);
    end;
end;

procedure pixplay2;
begin
    { Erase pixels }
    Randseed:=seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      X := Random(XMax)+1;
      Y := Random(YMax)+1;
      Color := GetPixel(X, Y);
      if Color = RandColor then PutPixel(X, Y, 0);
    end;
end;

begin
k:=1;
j:=80;
txtmode:=FALSE;
Initialize;
    SetTextJustify(CenterText, TopText);
    SetUserCharSize(5, 6, 3, 2);
    SetTextStyle(Triplexfont, HorizDir, UserCharSize);
    mysetcolor(Blue);
    OutTextXY(MaxX div 2, MaxY div 2-textheight('I')+10, 'IMS Project Manager');
    mysetcolor(yellow);
    OutTextXY(MaxX div 2+3, MaxY div 2-textheight('I')+10+3, 'IMS Project Manager');
    SetTextStyle(TriplexFont, HorizDir, 1);
    SetTextJustify(LeftText, TopText);
    mysetcolor(Cyan);
    SetTextStyle(Gothicfont, HorizDir, 0);
OutTextXY(MaxX div 2-5*textwidth('I')+3,
               MaxY-MaxY div 12-3*textheight('I')+10+3, 'Designed By');
  GetViewSettings(ViewInfo);
  Left := 0;
  Top := 0;
with ViewInfo do
  begin
    Right := x2-x1;
    Bottom := y2-y1;
  end;
  Step := Bottom div 50;
  SetColor(GetMaxColor);
{
  Line(Left, Top, Right, Bottom);
  Line(Left, Bottom, Right, Top);
}
  SetWriteMode(XORPut);                    { Set XOR write mode }
{  Randseed:=Seed;}
longi:=1;
count:=0;
  repeat
  inc(count);
    SetTextStyle(Gothicfont, HorizDir, 0);
    OutTextXY(MaxX div 2-4*textwidth('I')+3, MaxY-MaxY div 12-textheight('I')+10+3, 'Viju K S');
repeat
{show_note;}
if odd(count) then pixplay1;

sound(5000 div longi);

    Rectangle(Left, Top, Right, Bottom);
delay(4*longi);
    SetTextStyle(Gothicfont, HorizDir, 0);
    OutTextXY(MaxX div 2-4*textwidth('I')+3, MaxY-MaxY div 12-textheight('I')+10+3, 'Viju K S');

longi:=longi+1;

 { Draw XOR rectangle }
{      delay(random(1000));}
{    Delay(DelayValue);   }                  { Wait }
    Line(Left, Top, Right, Bottom);        { Erase lines }
    Line(Left, Bottom, Right, Top);

    Rectangle(Left, Top, Right, Bottom);

  { Erase rectangle }
    if (Left+Step +MaxX div 24 < Right) and ( Top+Step +MaxX div 24 < Bottom) then
     begin
        Inc(Left, Step);                  { Shrink rectangle }
        Inc(Top, Step);
        Dec(Right, Step);
        Dec(Bottom, Step);
      end
    else
      begin
      longi:=1;
        Color := count;                { New color }
        SetColor(Color);
        Left := 0;                         { Original large rectangle }
        Top := 0;

      with ViewInfo do
        begin
          Right := x2-x1;
          Bottom := y2-y1;
        end;
    end;
  if odd(count) then pixplay2;
    until Left=0;
  nosound;
  until KeyPressed;

  SetWriteMode(CopyPut);                   { back to overwrite mode }
  if keypressed then c:=readkey;
closegraph;
txtmode:=TRUE;

end;         { WriteModePlay }
{end;}
(*
procedure heading;
const
  Seed   = 1962; { A seed for the random number generator }
  NumPts = 1000; { The number of pixels plotted }
var
  I : word;
  X, Y, Color : word;
  XMax, YMax  : integer;
const
  DelayValue = 50;  { milliseconds to delay }
var
  ViewInfo      : ViewPortType;
  Left, Top     : integer;
  Right, Bottom : integer;
  Step          : integer; { step for rectangle shrinking }
  longi:longint;
  count:integer;
  toggle:boolean;

procedure pixplay1;
begin
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    XMax := (x2-x1-1);
    YMax := (y2-y1-1);
  end;
{
while not KeyPressed do
  begin
}
    {  Plot random pixels  }
    Randseed:=Seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      PutPixel(Random(XMax)+1, Random(YMax)+1, RandColor);
    end;
end;

procedure pixplay2;
begin
    { Erase pixels }
    Randseed:=seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      X := Random(XMax)+1;
      Y := Random(YMax)+1;
      Color := GetPixel(X, Y);
      if Color = RandColor then PutPixel(X, Y, 0);
    end;
end;

begin
txtmode:=FALSE;
Initialize;
    SetTextJustify(CenterText, TopText);
    SetUserCharSize(5, 6, 3, 2);
    SetTextStyle(Triplexfont, HorizDir, UserCharSize);
    mysetcolor(Blue);
    OutTextXY(MaxX div 2, MaxY div 2-textheight('I')+10, 'IMS Project Manager');
    mysetcolor(yellow);
    OutTextXY(MaxX div 2+3, MaxY div 2-textheight('I')+10+3, 'IMS Project Manager');
    SetTextStyle(TriplexFont, HorizDir, 1);
    SetTextJustify(LeftText, TopText);
    mysetcolor(Cyan);
    SetTextStyle(Gothicfont, HorizDir, 0);
OutTextXY(MaxX div 2-5*textwidth('I')+3,
               MaxY-MaxY div 12-3*textheight('I')+10+3, 'Designed By');
  GetViewSettings(ViewInfo);
  Left := 0;
  Top := 0;
with ViewInfo do
  begin
    Right := x2-x1;
    Bottom := y2-y1;
  end;
  Step := Bottom div 50;
  SetColor(GetMaxColor);
{
  Line(Left, Top, Right, Bottom);
  Line(Left, Bottom, Right, Top);
}
  SetWriteMode(XORPut);                    { Set XOR write mode }
{  Randseed:=Seed;}
longi:=1;
count:=0;
  repeat
  inc(count);
    SetTextStyle(Gothicfont, HorizDir, 0);
    OutTextXY(MaxX div 2-4*textwidth('I')+3, MaxY-MaxY div 12-textheight('I')+10+3, 'Viju K S');
    toggle:=TRUE;
repeat
if odd(count) then pixplay1;

sound(5000 div longi);


    Rectangle(Left, Top, Right, Bottom);
delay(4*longi);
    SetTextStyle(Gothicfont, HorizDir, 0);
    OutTextXY(MaxX div 2-4*textwidth('I')+3, MaxY-MaxY div 12-textheight('I')+10+3, 'Viju K S');

longi:=longi+1;

 { Draw XOR rectangle }
{      delay(random(1000));}
{    Delay(DelayValue);   }                  { Wait }
    Line(Left, Top, Right, Bottom);        { Erase lines }
    Line(Left, Bottom, Right, Top);

    Rectangle(Left, Top, Right, Bottom);

  { Erase rectangle }
    if (Left+Step +MaxX div 24 < Right) and ( Top+Step +MaxX div 24 < Bottom) then
     begin
        if toggle then
           begin
           Inc(Left, Step);                  { Shrink rectangle }
           Inc(Top, Step);
            Dec(Right, Step);
            Dec(Bottom, Step);
            end
            else
                begin
           Dec(Left, Step);                  { Shrink rectangle }
           Dec(Top, Step);
            Inc(Right, Step);
            Inc(Bottom, Step);
                end;
      end
    else
        begin
        toggle:=not toggle;
      {
      begin
      longi:=1;
        Color := count;                { New color
        SetColor(Color);
        Left := 0;                         { Original large rectangle
        Top := 0;

      end;
      }
      with ViewInfo do
        begin
          Right := x2-x1;
          Bottom := y2-y1;
        end;
    end;

  if odd(count) then pixplay2;
    until Left=0;
  nosound;
  until KeyPressed;

  SetWriteMode(CopyPut);                   { back to overwrite mode }
  if keypressed then c:=readkey;
closegraph;
txtmode:=TRUE;
end;         { WriteModePlay }
{end;}
*)


{****** START BARCHART }
procedure Barchart(incode:byte);
var
  viewinfo,viewinfo1 : viewporttype;
  h        : word;
  xstep    : real;
  ystep    : real;
  i, j     : integer;
  depth    : word;
  color    : word;
  bd1,bd2,bd3,bd4:real;
  yticks,xticks:integer;
  total_cost:real;

  cumprod:real;
  m:integer;
  lastx1,lastx2,firstx1,firstx2,secx1,secx2:real;
  svno:integer;
  dura:integer;

  procedure getmonthyear(cmonth:integer;var month,year:integer);
    begin
    if cmonth>36 then
		begin
		     year:=3;
		     month:=cmonth mod 12;
		end
		else
    if cmonth>24 then
		begin
		     year:=2;
		     month:=cmonth mod 12;
		end
		else
	  if cmonth>12 then
			begin
			     year:=1;
			     month:=cmonth mod 12;
			end
				else
					begin
					     year:=0;
					     month:=cmonth;
					end;
    year:=syear+year;
    if month=0 then month:=12;
    end;

 function eprodm(i:integer):real;
    var
    k:integer;
   cumprod:real;
   month:integer;
   year:integer;
begin
    getmonthyear(i+smonth-1,month,year);
    cumprod:=0;
    for k:=1 to daysin(month,year) do
                                   cumprod:=cumprod+eprod^[i+k-1];
end;

 function aprodm(i:integer):real;
var
   k:integer;
   cumprod:real;
   month:integer;
   year:integer;

begin
    getmonthyear(i+smonth-1,month,year);
    cumprod:=0;
    for k:=1 to daysin(month,year) do
                                   cumprod:=cumprod+aprod^[i+k-1];
end;


 procedure call_bds(n:integer);
begin
with sheet1^ do
begin
dura:=duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]);
if (quantity<>0) and (sd[1]>0) then
         begin
         dura_2_days(sd[1],sd[2],sd[3],myround(qdone/quantity*dura),ad[1],ad[2],ad[3]);
         end
      else
          begin
             ad[1]:=sd[1];
             ad[2]:=sd[2];
             ad[3]:=sd[3];
          end;
bd1:=duradays(1,1,syear+n,sd[1],sd[2],sd[3]);
bd2:=duradays(1,1,syear+n,fd[1],fd[2],fd[3]);
bd3:=duradays(1,1,syear+n,ad[1],ad[2],ad[3]);
end;
end;

  procedure comp_eprod;
  var i:integer;
      dura:real;
      cmonth:integer;
      prod:^ar36;
      daycount:integer;
      heap3:pointer;
  begin
  mark(heap3);
  if memok(sizeof(prod^)) then new(prod) else exit;
  for i:=1 to y3d do
           begin
           prod^[i]:=0;
           eprod^[i]:=0;
           end;

  for i:=1 to no_act do
      begin
      takerec(i);
      call_bds(0);

      bd1:=bd1-duradays(1,1,syear,1,smonth,syear)+1;
      bd2:=bd2-duradays(1,1,syear,1,smonth,syear)+1;
      bd3:=bd3-duradays(1,1,syear,1,smonth,syear)+1;

      for daycount:=1 to y3d do
      begin
      if (bd1<=daycount) and (bd2>=daycount) then dura:=1 else dura:=0;
      with sheet1^ do
             if (bd2-bd1+1>0) then
              prod^[daycount]:=prod^[daycount]+quantity*c_rate*dura/(bd2-bd1+1);
      end;

     end;

if total_cost>0 then for daycount:=1 to y3d do
                eprod^[daycount]:=prod^[daycount]/total_cost*100;

  release(heap3);
  end;

  procedure comp_aprod;
  var i,j,k,r:integer;
      dura:real;
      month,year:integer;
      rate:real;
      cmonth,daycount:integer;
      prod:^ar36;
      heap3:pointer;
  begin
  mark(heap3);
  if memok(sizeof(prod^)) then new(prod) else exit;

  for i:=1 to y3d do
           begin
           prod^[i]:=0;
           aprod^[i]:=0;
           end;

  total_cost:=0;
  for i:=1 to no_act do
      begin
      takerec(i);
      rate:=sheet1^.c_rate;
      push;

      total_cost:=total_cost+gt('S',d,FALSE)*st_sheet^.c_rate;

	  for j:=1 to no_act do
	      begin
	      takerec(j);
      for cmonth:=smonth to myround(smonth+produra/day30+3) do
      begin
      getmonthyear(cmonth,month,year);
      with sheet1^ do
	begin
             if (stat=1) and (cd[2]=month) and (cd[3]=year) then
                     begin
                      daycount:=duradays(1,smonth,syear,cd[1],cd[2],cd[3]);
                      prod^[daycount]:=prod^[daycount]+quantity*rate;
                     end;
        end;
      end;
      end;
      pop;
  end;

if total_cost>0 then for k:=1 to y3d do aprod^[k]:= prod^[k]/total_cost*100;

i:=0;
for k:=sday to y3d-1 do
            begin
                if (aprod^[k]=0) and (i<y3d) then
                   begin
                        i:=k;
                        repeat
                              inc(i);
                        until (aprod^[i]>0) or (i=y3d);
                        prod^[i]:=aprod^[i];

                        if aprod^[i]>0 then
                           for j:=k to i do
                               aprod^[j]:=prod^[i]/(i-k+1);
                   end;
                end;
release(heap3);
end;

procedure find_tcost;
var i,j:integer;
begin
total_cost:=0;
for i:=1 to No_act do
         begin
	 takerec(i);
         push;
       	 total_cost:=total_cost+gt('S',d,FALSE)*st_sheet^.c_rate;
         pop;
	 end;
end;

procedure barchart1;
label 100;
var
	i,m:integer;
	s1,s2:string[8];
        horizno,vertno:integer;
        noisef:boolean;
        dd:datetype;

begin
horizno:=0;
vertno:=0;

date2type(sday,smonth,syear,dd);
  date2str(dd,s1);
date2type(eday,emonth,eyear,dd);
  date2str(dd,s2);

mainwindow( fixlength('BARCHART FOR '+proname+'.DAT    FROM '+
	s1+' TO '+s2+' ('+strint(produra,4)+' DAYS)',80,LEFT));
  h := 3*textheight('m');
  getviewsettings(viewinfo);
  with viewinfo do
      setviewport(x1+10, y1+20, x2-200, y2-40, clipon);
  getviewsettings(viewinfo1);

  Xticks   :=  12;  { the number of bars drawn }
  Yticks   :=  12;  { the number of tick marks on the y axis }

  with viewinfo1 do
  begin
    ystep := trunc((y2-y1-2*h) / Yticks);
    xstep := trunc((x2-x1-2*h) / Xticks);
  end;

  with viewinfo1 do
      setviewport(x1+h+1, y2-h-1-myround(ystep*12), x1+h+1+myround(xstep*12), y2-h-1, clipon);
      getviewsettings(viewinfo);

with viewinfo do
repeat
        fullport;
        setviewport(1,14,viewinfo1.x2-1,viewinfo1.y2-(h div 2),clipon);
        clearviewport;
        settextjustify(centertext, toptext);
        settextstyle(triplexfont, horizdir, 4);
        outtextxy(maxx div 2, 6, 'Bar chart');
        settextstyle(defaultfont, horizdir, 1);

with viewinfo1 do
begin
    setviewport(x1,y1,x2,y2,clipon);
    j := (y2-y1)-h;
    settextjustify(centertext, centertext);
    line(h, h, h, (y2-y1)-h);
    line(h, (y2-y1)-h, (x2-x1)-h, (y2-y1)-h);
    line(h, h,(x2-x1)-h,h);
    line((x2-x1)-h, h,  (x2-x1)-h,(y2-y1)-h);

    { draw the y axis and ticks marks }

    for i := 0 to Yticks do
    begin
      line(h div 2, j, h, j);
      outtextxy(0, j, strint(vertno*Yticks+i,1));
      j := myround(j-ystep);
    end;

    j := h;
    for i := horizno*Xticks+1 to succ((horizno+1)*Xticks) do
    begin
      line(j, (y2-y1)-( h div 2), j, (y2-y1)-h);
      if i<>succ((horizno+1)*Xticks) then
        outtextxy(myround(j+xstep/2), myround(y2-y1-xstep/2), strint(i,1));
	  j:= myround(j+xstep);
    end;
    depth := trunc(0.25 * xstep);    { calculate depth of bar }

    { draw x axis, bars, and tick marks }
    settextjustify(centertext, toptext);
end;

setviewport(x1, y1, x2, y2, clipon);

{
schcut:=duradays(1,1,syear,eday,emonth,eyear);
sad[1]:=sday;
sad[2]:=smonth;
sad[3]:=syear;
}

    j := 0;

    for i := horizno*Xticks+1 to succ((horizno+1)*Xticks) do
    if i<=no_act then
    begin
    takerec(i);
    call_bds(0);

      bd1:=bd1/day30;
      bd2:=bd2/day30;
      bd3:=bd3/day30;

      {setcolor(maxcolor);}
      {line(j, (y2-y1)-h, j, (y2-y1-3)-(h div 2));}

      if i <> succ(Xticks) then
      begin
{	outtextxy(myround(j+xstep/2), myround(y2-y1-xstep/2), strint(i));}
	color := white;
        setfillstyle(0, color);
        mysetcolor(white);
 	if (abs((y2-y1-bd1*ystep)-(y2-y1)-(bd2 * ystep))>1e-10) then
		begin
Bar3d(myround(j+xstep-depth), myround(y2-y1-(bd1-vertno*Yticks)*ystep), j,
	myround((y2-y1)-((bd2-vertno*Yticks)*ystep)), 0, topon );
	settextstyle(defaultfont, vertdir, 1);

fullport;
moveto(x1+j+myround(xstep/2),y2+h-6);

with sheet1^ do
                outtext(strreal(quantity*c_rate/total_cost*100,5,2));

     setviewport(x1, y1, x2, y2, clipon);
     settextstyle(defaultfont, horizdir, 1);
     setfillstyle(slashfill,red);

if abs(bd3-bd1)>1e-10 then
     Bar3d(myround(j+xstep-depth),myround(y2-y1-(bd1-vertno*Yticks)*ystep),j,
	 myround((y2-y1)-((bd3-vertno*Yticks)*ystep)) , 0, topoff);
      end;
	  j:= myround(j+xstep);
      end;
  end;

    with viewinfo1 do
    begin
    setviewport(x2,y1+h+h div 2,maxx-1,y2,clipon);
    clearviewport;
    fullport;
    j := (y2-y1)-h;
    settextjustify(centertext, centertext);

    for i := 0 to Yticks do
    begin
      line(x2, j+y1, maxx, j+y1);
      j:= myround(j-ystep);
    end;

    line(x2, textheight('m')+4, x2, maxy-(textheight('m')+4));
    line(x2+50, textheight('m')+4, x2+50, maxy-(textheight('m')+4));
    line(x2+100, textheight('m')+4, x2+100, maxy-(textheight('m')+4));
    line(x2+150, textheight('m')+4, x2+150, maxy-(textheight('m')+4));
    settextstyle(defaultfont, vertdir, 1);
    outtextxy(x2+20,textheight('m')+4+30,'shed.');
    outtextxy(x2+35,textheight('m')+4+30,'/month');
    outtextxy(x2+20+50,textheight('m')+4+30,'actual');
    outtextxy(x2+35+50,textheight('m')+4+30,'/month');
    outtextxy(x2+20+100,textheight('m')+4+30,'shed.');
    outtextxy(x2+35+100,textheight('m')+4+30,'cum.');
    outtextxy(x2+20+150,textheight('m')+4+30,'actual');
    outtextxy(x2+35+150,textheight('m')+4+30,'cum.');
    settextstyle(defaultfont, horizdir, 1);

noisef:=FALSE;
100:

if noisef then begin sound(1000); delay(25); nosound; end;

noisef:=TRUE;
c:=readkey;
if c=#0 then c:=readkey;
case c of
left:  if horizno>0 then dec(horizno) else goto 100;
right: if (horizno+1)*Xticks<No_act then inc(horizno) else goto 100;
down : if vertno>0 then dec(vertno) else goto 100;
up   : if vertno<2 then inc(vertno) else goto 100;
esc  : exit;
else   if c<>space then goto 100;
end;
     j := y2-y1-h;

case vertno of
    0:
    begin
    lastx1:=x2-h;
    lastx2:=x2-h;
    end;
    1:
    begin
    lastx1:=firstx1;
    lastx2:=firstx2;
    end;
    2:
    begin
    lastx1:=secx1;
    lastx2:=secx2;
    end;
    end;

    for i := (vertno*Yticks+1) to ((vertno+1)*Yticks) do
    begin

    if c=space then
    begin
      outtextxy(x2+25, myround(j+y1-ystep/2), strreal(eprod^[i],2,2));
      outtextxy(x2+75, myround(j+y1-ystep/2), strreal(aprod^[i],2,2));
    end;

      cumprod:=0;                       { sheduled curve }
      for m:=1 to i do
	begin
        cumprod:=cumprod+eprod^[m];
        if Ubreak then exit;
        end;

if c=space then
    begin
      outtextxy(x2+125, myround(j+y1-ystep/2), strreal(cumprod,2,2));
      {
      if (abs(lastx1- (x2-h-cumprod/100*xstep*Yticks))>1e-7) then
         line(myround(lastx1),myround(y2-h-(i-vertno*Xticks-1)*ystep),
              myround(x2-h-cumprod/100*(xstep*Yticks)),myround(y2-h-(i-vertno*Xticks)*ystep));
      }
    end;

      lastx1:=x2-h-cumprod/100*(xstep*Yticks);
      cumprod:=0;                        { actual curve }

      for m:=1 to i do
          begin
          cumprod:=cumprod+aprod^[m];
          if Ubreak then exit;
          end;

        if c=space then
    begin
   outtextxy(x2+175, myround(j+y1-ystep/2), strreal(cumprod,2,2));
      {
      if abs(lastx2- (x2-h-cumprod/100*xstep*Yticks))>1e-7 then
      line(myround(lastx2),myround(y2-h-(i-vertno*Xticks-1)*ystep),
		   myround(x2-h-cumprod/100*(xstep*Yticks)),myround(y2-h-(i-vertno*Xticks)*ystep));
      }
      end;

      lastx2:=x2-h-cumprod/100*(xstep*Yticks);
      j := myround(j-ystep);

if vertno=0 then
              begin
                firstx1:=lastx1;
                firstx2:=lastx2;
              end;

if vertno=1 then
              begin
                secx1:=lastx1;
                secx2:=lastx2;
              end;

        end;
    end;
  if c=space then
                 begin
                 noisef:=FALSE;
                 goto 100;
                 end;
  until c=ESC;
end; { Barchart1 }

 procedure barchart2;
var
   day,month,year:integer;
   i,m,bot,top,lt,rt:integer;
   stcumprod:real;
   cdays:array[1..12] of integer;
begin
h := 3*textheight('m');
bot:=3*h;
top:=2*h;
lt:=2*h;
rt:=h;

  yticks := 10;  { Progrss  0% to 100% }
  xticks := sday+myround(produra)-1;  { the number of time units on the x axis }

  cdays[1]:=31;
  cdays[2]:=59;
  cdays[3]:=90;
  cdays[4]:=120;
  cdays[5]:=151;
  cdays[6]:=181;
  cdays[7]:=212;
  cdays[8]:=243;
  cdays[9]:=273;
  cdays[10]:=304;
  cdays[11]:=334;
  cdays[12]:=365;

  i:=1;
  repeat
  inc(i);
  until (xticks<=(xticks div 366)*365+cdays[i]) or (i=12);

  xticks:=(xticks div 366)*365+cdays[i];

  xstep  := (maxx-lt-rt) / xticks;
  ystep  := (maxy-bot-top) / yticks;

  fullport;
  clearviewport;
  if incode=2 then
	  begin
	  settextstyle(Defaultfont, horizdir, 2);
{          setcolor(Yellow);}
	  outtextxy(160, 4,  '    Progress Curve    ');
	  outtextxy(160, 4+h,'(scheduled vs. actual)');
{         setcolor(lightcyan);}
	  end
          else
begin
j:=MaxY-bot;
repeat
Line(lt,j,maxx-rt,j);
j:=j-myround(1.5*H);
until j<0;
end;
  day:=1;

  month:=smonth;

  {
  sad[1]:=sday;
  sad[2]:=smonth;
  sad[3]:=syear;
  }

 year:=syear;
 if incode=2 then
	 begin
	 line(lt, maxy-bot, lt,myround(maxy-bot-ystep*yticks));  { vert line }
	 line(lt, maxy-bot, lt+myround(xstep*xticks),maxy-bot);  { horiz line }
	 settextstyle(SmallFont, horizdir, 0);
{         setcolor(lightblue);}
	 outtextxy(MaxX div 2-h,MaxY-h,'T I M E ( M O N T H S )');
{         setcolor(Lightcyan);}
	end;

 j := lt;

 { draw the x axis and ticks marks }

      settextstyle(smallfont, vertdir, 0);
{      setcolor(lightblue);}
      if incode=2 then
         outtextxy(0,MaxY div 2-h,'P R O G R E S S ( % )');
 {     setcolor(Lightcyan);}

    for i := 0 to xticks do
    begin
    case i mod 365 of
    0,31,59,90,120,151,181,212,243,273,304,334:
    begin
      line(j,myround(maxy-bot-yticks*ystep), j,maxy-bot);

{if (i<>xticks) then}
   outtextxy(myround(j+xstep-h div 6), maxy-bot+h div 8, strint(month,2)+'/'+strint(year,2));

   if month=12 then
               begin
                                 month:=1;
                                 inc(year);
               end
               else
                   inc(month);
   end;
   end;
   j := myround(lt+(i+1)*xstep);
   end;

settextstyle(smallfont, horizdir, 0);
settextjustify(lefttext, toptext);
j:=maxy-bot;
if incode=2 then

for i := 0 to 10 do
    begin
	    {line(lt-h div 2, j, lt, j);#}
	    line(lt,j,myround(lt+xticks*xstep), j);
	    outtextxy(h, j, strint(i*10,2)+'%');
	    j := myround(j-ystep);
    end;

lastx1:=maxy-bot;
lastx2:=maxy-bot;

j := 0;

for i := 1 to xticks do
    begin
    if incode=3 then
       begin
settextstyle(smallfont, Vertdir, 0);
outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-H-H div 2),
                         strreal(eprod^[i],2,2));
outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-3*H-H div 2),
                         strreal(aprod^[i],2,2));
outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-9*H-H div 2),
                         strreal(aprod^[i]-eprod^[i],2,2));
settextstyle(smallfont, horizdir, 0);
       end;

     cumprod:=0;                       { scheduled curve }
     for m:=1 to i do
          	begin
                if Ubreak then exit;
                cumprod:=cumprod+eprod^[m];
                end;
                stcumprod:=cumprod;
     if abs(cumprod)>maxlongint then
                                    halt;

if incode=2 then
begin
     if abs(lastx1-(maxy-bot-cumprod/100*(yticks*ystep)))>1e-7 then
     begin
{     setcolor(lightblue);}
     xx:=myround(lt+i*xstep);
     line(myround(lt+(i-1)*xstep),myround(lastx1),xx,
                          myround(maxy-bot-cumprod/100*(yticks*ystep)));
     end;
end
else
    begin
     settextstyle(smallfont, Vertdir, 0);
     outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-5*H-H div 2),
                         strreal(cumprod,2,2));
     settextstyle(smallfont, horizdir, 0);
    end;

      lastx1:=maxy-bot-cumprod/100*(yticks*ystep);
      cumprod:=0;                        { actual curve }
      for m:=1 to i do
                begin
                if Ubreak then exit;
                cumprod:=cumprod+aprod^[m];
                end;

      if abs(cumprod)>maxlongint then
                                 halt;
setlinestyle(solidln,0,thickwidth);

if incode=2 then
   begin
	if (abs(lastx2- (maxy-bot-cumprod/100*(yticks*ystep)))>1e-7) then
        begin
{        setcolor(lightred);}
        xx:=myround(lt+i*xstep);
        line(myround(lt+(i-1)*xstep),myround(lastx2),xx,myround(maxy-bot-cumprod/100*(yticks*ystep)));
        end;
   end
else
   begin
        settextstyle(smallfont, Vertdir, 0);
        outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-7*H-H div 2), strreal(cumprod,2,2));
        outtextxy(myround(lt+H div 6+(i-1)*Xstep), myround(MaxY-bot-11*H-H div 2), strreal(cumprod-stcumprod,2,2));
        settextstyle(smallfont, horizdir, 0);
   end;

   setlinestyle(solidln,0,normwidth);
   lastx2:=maxy-bot-cumprod/100*(yticks*ystep);
   j := myround(j-ystep);
   if Ubreak then exit;
end;
waitfor(ESC);
end;                           { Barchart2 }


  procedure comp_eprod3;
  var i:integer;
      dura:real;
      cmonth:integer;
      prod:array[1..48] of real;
      month,year,dd1,dd2:integer;

      cumprod,ddd:real;  {#debug}

  begin

  for i:=1 to 48 do
           begin
           prod[i]:=0;
           eprod^[i]:=0;
           end;

  for i:=1 to no_act do
      begin
      takerec(i);
      call_bds(0);

      ddd:=0;

      for cmonth:=smonth to myround(smonth+produra/day30+2) do
      begin
      dura:=0;
      getmonthyear(cmonth,month,year);

      dd1:=duradays(1,1,syear,1,month,year);
      dd2:=duradays(1,1,syear,daysin(month,year),month,year);

       if not((bd2<dd1) or (bd1>dd2)) then
           begin
                   if bd1>=dd1 then
                      begin
                      if (bd2<dd2) then
                                          dura:=bd2-bd1+1
                                          else
                                          dura:=dd2-bd1+1;
                      end
                      else
                      if (bd2<dd2) then
                                          dura:=bd2-dd1+1
                                          else
                                          dura:=daysin(month,year);
      with sheet1^ do
      if (bd2-bd1+1>0) then
           prod[cmonth]:=prod[cmonth]+quantity*c_rate*dura/(bd2-bd1+1);

      ddd:=ddd+dura;

           end;


{writeln(ddd:3:0,' ',dura:3:0,'  * ',dd1:3,' ',dd2:3,' ',bd1:3:0,' ',bd2:3:0);}

           end;
     end;


if total_cost>0 then
for cmonth:=smonth to myround(smonth+produra/day30+2) do
                eprod^[cmonth]:=prod[cmonth]/total_cost*100;

end;


  procedure comp_aprod3;
  var i,j:integer;
      dura:real;
      month,year:integer;
      rate:real;
      cmonth:integer;
      prod:array[1..48] of real;

  begin
  for i:=1 to 48 do
           begin
           prod[i]:=0;
           aprod^[i]:=0;
           end;
  total_cost:=0;
  for i:=1 to no_act do
      begin
      takerec(i);
      rate:=sheet1^.c_rate;
      push;
      total_cost:=total_cost+gt('S',d,FALSE)*st_sheet^.c_rate;
      for j:=1 to no_act do
	      begin
	      takerec(j);
      for cmonth:=smonth to myround(smonth+produra/day30+2) do
      begin
              getmonthyear(cmonth,month,year);
	      with sheet1^ do
		begin
                   if (stat=1) and
		      (sheet1^.cd[2]=month) and (sheet1^.cd[3]=year) then
			    prod[cmonth]:=prod[cmonth]+quantity*rate;
                end;
	      end;
          end;
      pop;
  end;
if total_cost>0 then
for cmonth:=smonth to myround(smonth+produra/day30+2) do
                   aprod^[cmonth]:= prod[cmonth]/total_cost*100;
end;

procedure barchart3;
var
  day,month,year:integer;
  i,m,x:integer;
  stcumprod:real;
  out:text;
  flag:boolean;

begin
  day:=1;
  month:=smonth;
  year:=syear;

  xticks:=myround(produra/day30+2);

  x:=3;

if printmode and printerready
             then
                      out_2_prn
             else
		      begin
                      outname:='D:\TEMP.IPM';
                      assign(out,outname);
                      rewrite(out);
                      end;

{$I-}

writeln(out);
writeln(out,'Month     Scheduled    Actual     Monthly    Scheduled    Actual    Cumulative ');ff;
writeln(out,'/Year     Monthly      Monthly   Variation  Cumulative  Cumulative  Variation ');ff;
writeln(out);


stcumprod:=0;
for i := smonth to smonth+xticks do
if ((syear=year) and (smonth<=month)) or
   (eyear>year) or
   ((eyear=year) and (emonth>=month)) or (stcumprod<=100-e) then
  begin

  flag:= (eprod^[i]<=e) and (aprod^[i]<=e);

  if not flag then
  write(out,strint(month,2)+'/'+strint(year,2),' ':x-1,
          justify(eprod^[i],6,2,RIGHT),' ':x,justify(aprod^[i],6,2,RIGHT),' ':x,
		justify(aprod^[i]-eprod^[i],6,2,RIGHT),' ':x);

	cumprod:=0;                        { scheduled }
        for m:=smonth to i do
               begin
                if Ubreak then exit;
           	cumprod:=cumprod+eprod^[m];
               end;

	stcumprod:=cumprod;

	if abs(cumprod)>maxlongint then
                                       halt;

if not flag then write(out,justify(cumprod,6,2,RIGHT),' ':x);


	cumprod:=0;                        { actual }
	for m:=smonth to i do
                begin
                if Ubreak then exit;
                cumprod:=cumprod+aprod^[m];
                end;

	if abs(cumprod)>maxlongint then
                                       halt;

if not flag then
        begin
        writeln(out,justify(cumprod,6,2,RIGHT),' ':x,
                         justify(cumprod-stcumprod,6,2,RIGHT),'   '); ff;
        end;

	if month<12 then inc(month) else
                                 begin
                                      month:=1;
				      inc(year);
                                      writeln(out);
                                 end;
        if Ubreak then exit;
  end;

close(out);
{$I+}

gotoxy(1,25);
fastwrite(' ',80,Norm);
if not printmode then
   editfile(outname);
end;                           { Barchart3 }


procedure cashflow;
var
   day,month,year:integer;
   i,m,bot,top,lt,rt:integer;
   stcumprod:real;
   cdays:array[1..12] of integer;
begin
h := 3*textheight('m');
bot:=3*h;
top:=2*h;
lt:=2*h;
rt:=h;

  yticks := 10;  { Progrss  0% to 100% }
  xticks := sday+myround(produra)-1;  { the number of time units on the x axis }

  cdays[1]:=31;
  cdays[2]:=59;
  cdays[3]:=90;
  cdays[4]:=120;
  cdays[5]:=151;
  cdays[6]:=181;
  cdays[7]:=212;
  cdays[8]:=243;
  cdays[9]:=273;
  cdays[10]:=304;
  cdays[11]:=334;
  cdays[12]:=365;

  i:=1;
  repeat
  inc(i);
  until (xticks=(xticks div 366)*365+cdays[i]) or (i=12);

  xticks:=(xticks div 366)*365+cdays[i];

  xstep  := (maxx-lt-rt)   / xticks;
  ystep  := (maxy-bot-top) / yticks;

  fullport;
  clearviewport;

	  settextstyle(triplexfont, horizdir, 1);
	  outtextxy(240, 3,  '    Cash Flow Curve  ');
	  outtextxy(240, 3+h,' (income vs. expense)');

 day:=1;

 month:=smonth;

 year:=syear;

	 line(lt, maxy-bot,lt,myround(maxy-bot-ystep*yticks));  { vert line }
	 line(lt,maxy-bot, lt+myround(xstep*xticks),maxy-bot);  { horiz line }
	 settextstyle(smallfont, horizdir, 0);
	 outtextxy(MaxX div 2-h,MaxY-h,'Time in months');

 j := lt;

 { draw the x axis and ticks marks }

      settextstyle(smallfont, vertdir, 0);

      outtextxy(0,MaxY div 2-h,'Rupees in millions');

    for i := 0 to xticks do
    begin
    case i mod 365 of
    0,31,59,90,120,151,181,212,243,273,304,334:
    begin
      line(j,myround(maxy-bot-yticks*ystep), j,maxy-bot);

{if (i<>xticks) then}
   outtextxy(myround(j+xstep-h div 6), maxy-bot+h div 12,'1/'+strint(month,2)+'/'+strint(year,2));

   if month=12 then
               begin
                                 month:=1;
                                 inc(year);
               end
               else
                   inc(month);
   end;
   end;
   j := myround(lt+(i+1)*xstep);
   end;

settextstyle(smallfont, horizdir, 0);
settextjustify(lefttext, toptext);
j:=maxy-bot;

for i := 0 to 10 do
    begin
	    line(lt,j,myround(lt+xticks*xstep), j);
	    outtextxy(h, j, strint(i*10,2));
	    j := myround(j-ystep);
    end;

lastx1:=maxy-bot;
lastx2:=maxy-bot;

j := 0;

for i := 1 to xticks do
    begin
     cumprod:=0;                       { scheduled curve }

     for m:=1 to i do
          	begin
                   if Ubreak then exit;
                   cumprod:=cumprod+eprod^[m];
                end;

     stcumprod:=cumprod;
     if abs(cumprod)>maxlongint then halt;

     if abs(lastx1-(maxy-bot-cumprod/100*(yticks*ystep)))>1e-5 then
     begin
     xx:=myround(lt+i*xstep);
     line(myround(lt+(i-1)*xstep),myround(lastx1),xx,
                          myround(maxy-bot-cumprod/100*(yticks*ystep)));
     end;

     lastx1:=maxy-bot-cumprod/100*(yticks*ystep);
     cumprod:=0;                                 { actual curve }

     for m:=1 to i do
                begin
                if Ubreak then exit;
                cumprod:=cumprod+aprod^[m];
                end;

     if abs(cumprod)>maxlongint then halt;
     setlinestyle(solidln,0,thickwidth);

     if (abs(lastx2- (maxy-bot-cumprod/100*(yticks*ystep)))>1e-7) then
        begin
        xx:=myround(lt+i*xstep);
        line(myround(lt+(i-1)*xstep),myround(lastx2),xx,myround(maxy-bot-cumprod/100*(yticks*ystep)));
        end;

     setlinestyle(solidln,0,normwidth);
     lastx2:=maxy-bot-cumprod/100*(yticks*ystep);
     j := myround(j-ystep);
     if Ubreak then exit;
end;
waitfor(ESC);
end;                           { Cashflow }



var
   daycount:integer;
   tem:real;

begin
if pushed then pop;
mark(heap2);
if memok(sizeof(aprod^)) then new(aprod) else exit;
if memok(sizeof(eprod^)) then new(eprod) else exit;

smsg('Computing ... Please wait.');

prodays;
if incode=4 then
            begin
            assign(datamatf,proname+'.CIO');
            {$I-}
            reset(datamatf);
            {$I+}
            if ioresult<>0 then
               begin
               release(heap2);
               exit;
               end;
            for i:=1 to y3d do
                     begin
                          eprod^[i]:=0;
                          aprod^[i]:=0;
                     end;

            while not eof(datamatf) do
                      begin

                      read(datamatf,datamat);
                      with datamat do
                           begin
                 daycount:=duradays(1,smonth,syear,pdate[1],pdate[2],pdate[3]);
                 if not errorflag and (daycount>0) and (daycount<y3d) then
                 if qty>0 then
                                              eprod^[daycount]:=eprod^[daycount]+qty/100000
                                     else
                                              aprod^[daycount]:=aprod^[daycount]+abs(qty)/100000;

                           end;
                        end;
                        close(datamatf);

            i:=0;
            for k:=sday to y3d-1 do
            begin
                if (eprod^[k]=0) and (i<y3d) then
                   begin
                        i:=k;
                        repeat
                              inc(i);
                        until (eprod^[i]>0) or (i=y3d);
                         tem:=eprod^[i];

                        if eprod^[i]>0 then
                           for j:=k to i do
                               eprod^[j]:=tem/(i-k+1);
                   end;
                end;

            i:=0;

            for k:=sday to y3d-1 do
            begin
                if (aprod^[k]=0) and (i<y3d) then
                   begin
                        i:=k;
                        repeat
                              inc(i);
                        until (aprod^[i]>0) or (i=y3d);
                        tem:=aprod^[i];

                        if aprod^[i]>0 then
                           for j:=k to i do
                               aprod^[j]:=tem/(i-k+1);
                   end;
                end;
{
            for k:=1 to y3d do
                    begin
                     writeln(eprod^[k],'   ',aprod^[k]);
                     waitfor(any);
                     end;
}
            end
else
begin
if incode in [1,3]
   then
     begin
     comp_APROD3;

       if total_cost<=0 then
                   begin
                   msg('Error : Total cost of project zero.'+ESC);
                   release(heap2);
                   exit;
                   end;

     { call eprod only after aprod since total_cost is computed in aprod. }

     comp_EPROD3;
    end
   else
     begin
     comp_APROD;

       if total_cost<=0 then
                   begin
                   msg('Error : Total cost of project is zero. Press ESC.');
                   waitfor(ESC);
                   release(heap2);
                   exit;
                   end;

     { call eprod only after aprod since total_cost is computed in aprod. }

     comp_EPROD;
     end;
end;


{
if overflow then
                  begin
                       release(heap2);
                       exit;
                  end;
}

if incode = 3 then
		begin
		     barchart3;
                     release(heap2);
		     exit;
		end;

txtmode:=FALSE;
Initialize;
case incode of
     1: barchart1;
     2: barchart2;
     4: cashflow;
   end;
CloseGraph;
txtmode:=TRUE;
directvideo:=TRUE;
release(heap2);
memerror:=FALSE;
end;

procedure TextBar;
label exitbarchart;
var
  XStep    : real;
  YStep    : real;
  I, J, K  : integer;
  Depth    : word;
  Color    : word;
  Total_time:integer;
  bd1,bd2,bd3,bd4:real;
  NumBars,YTicks:integer;
  Total_cost:real;
  CumProd:real;
  m,p:integer;
  lastx1,lastx2:real;
  sno:integer;
  svno,sn_act,tx,mycom:integer;
  days,t1:real;
  dura,sy,fy,ay,acts:integer;
  s1,s2,s3:string[8];

  varm,cnt:integer;
  numcol:integer;
  adjmul:real;
var
    ss:astring;
    colno:integer;

procedure getdates(var s1,s2,s3:string);
begin
if (syear+n) mod 100 >50 then
                 s1:='19'+p0i((syear+n) mod 100 ,2)
                 else
                 s1:='20'+p0i((syear+n) mod 100 ,2);

if (syear+n+1) mod 100 >50 then
                 s2:='19'+p0i((syear+n+1) mod 100 ,2)
                 else
                 s2:='20'+p0i((syear+n+1) mod 100 ,2);

if (syear+n+2) mod 100 >50 then
                 s3:='19'+p0i((syear+n+2) mod 100 ,2)
                 else
                 s3:='20'+p0i((syear+n+2) mod 100 ,2);
end;

procedure call_bds(n:integer);
begin
with sheet1^ do
begin
sy:=sd[3];
fy:=fd[3];
if sd[3]<syear then sy:=sd[3]+100;
if fd[3]<syear then fy:=fd[3]+100;
dura:=duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]);
if (quantity<>0) and (sd[1]>0) then
         dura_2_days(sd[1],sd[2],sd[3],round(qdone/quantity*dura),ad[1],ad[2],ad[3])
      else
          begin
             ad[1]:=sd[1];
             ad[2]:=sd[2];
             ad[3]:=sd[3];
          end;
ay:=ad[3];
bd1:=duradays(1,1,syear+n,sd[1],sd[2],sy);
bd2:=duradays(1,1,syear+n,fd[1],fd[2],fy);
bd3:=duradays(1,1,syear+n,ad[1],ad[2],ad[3]);
end;
end;


begin
prodays;
if not col80 and not printmode
                     then col80:=TRUE;
numcol:=80;
if printmode and printerready then
             begin
               out_2_prn;
               smsg('Printing... Press ^C to break.');
             end
	     else
	     begin
                  outname:='CON';
                  assign(out,outname);
                  assigncrt(out);
                  rewrite(out);
                  window(1,2,80,24);
             end;

{$I-}

p:=1;
m:=1;
hl:=1;
n:=0;

if adjust then
  begin

date2type(sday,smonth,syear,dd);
  date2str(dd,s1);
date2type(eday,emonth,eyear,dd);
  date2str(dd,s2);

  if col80 then
  begin
    write(out,'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ FROM ',s1,' TO ',s2,' (',strint(produra,4),'DAYS )',' ÄÄÄÄÄÄÄ¿');ff;
    write(out,'³ SL ³     Activity      ÃÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÅÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ´');    ff;
    write(out,'³ No.³   Start-Finish    ³ 0³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³ 0³ 1³ 2³ 3³ 4³ 5³ 6³ 7³');    ff;
    write(out,'ÃÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄ´');    ff;
  end
  else
    begin
write(out,'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ FROM ',s1,
' TO ',s2,' (',strint(produra,4),'DAYS )',' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');ff;
write(out,'³ SL ³     Activity      ÃÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂ');
write(out,'ÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ´');ff;
write(out,'³ No.³   Start-Finish    ³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³ 1³ 2³ 3³ 4³ 5³ 6³');
write(out,' 7³ 8³ 9³10³11³12³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³');ff;

write(out,'ÃÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁ');
write(out,'ÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄ´');ff;
numcol:=134;
    end;
  end
  else
if col80 or not printmode then
begin
getdates(s1,s2,s3);
write(out,'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',s1,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ',s2,'ÄÄÄÄÄÄ¿');ff;
write(out,'³ SL ³     Activity      ÃÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÅÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ´');    ff;
write(out,'³ No.³   Start-Finish    ³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³ 1³ 2³ 3³ 4³ 5³ 6³');    ff;
write(out,'ÃÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄ´');    ff;
end
else
if printmode then
begin
getdates(s1,s2,s3);
write(out,'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',s1,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
write(out,s2,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',s3,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');ff;

write(out,'³ SL ³     Activity      ÃÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÅÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂ');
write(out,'ÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÅÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ´');ff;

write(out,'³ No.³   Start-Finish    ³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³ 1³ 2³ 3³ 4³ 5³ 6³');
write(out,' 7³ 8³ 9³10³11³12³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³');ff;

write(out,'ÃÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁ');
write(out,'ÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄ´');ff;

numcol:=134;
end;

sno:=0;
svno:=0;
Total_time:=12;
acts:=10;
Total_cost:=0;
for i:=1 to No_act do
         begin
	 takerec(i);
	 Total_cost:=Total_cost+sheet1^.quantity*sheet1^.c_rate;
	 end;
daytimes;
repeat

window(1,6,80,25);
getdates(s1,s2,s3);

if not (adjust or printmode) and col80 then
   vs(1,2,'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+s1+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ'+s2+'ÄÄÄÄÄÄ¿',Norm);

{write('Project File: ',proname,'.DAT      Printed on ',date);}

  NumBars   := 10;  { The number of bars drawn }
  YTicks    := 12;  { The number of tick marks on the Y axis }
  YStep := 1;
  XStep := 1;

if printmode and not col80 then varm:=36 else varm:=18;
                { # sudden changes . review }

    J := 1;
if printmode then mycom:=No_act-p-5 else mycom:=0;
    for I := p to p+5+mycom do
    begin
if (i>0) and (i<=No_act) then
begin
takerec(i);
with sheet1^ do
begin
write(out,'³');
write(out,strint(I,4));
write(out,'³ ');

colno:=18;
align(activity,ss,colno);
if printmode then
       write(out,fixlength(ss[1],18,LEFT))
   else
       write(out,fixlength(activity,18,LEFT));

write(out,'³');

sy:=sd[3];
fy:=fd[3];

if sd[3]<syear then sy:=sd[3]+100;
if fd[3]<syear then fy:=fd[3]+100;

dura:=round(duradays(sd[1],sd[2],sd[3],fd[1],fd[2],fd[3]));
call_bds(n);

if (syear+n>sy) then        bd1:=0 else bd1:=bd1/10.0;
if (syear+n>fy) then        bd2:=0 else bd2:=bd2/10;
if (syear+n>ad[3]) then     bd3:=0 else bd3:=bd3/10.0;

if round(bd2)>varm*3-1 then   bd2:=varm*3-1;

if round(bd3)>varm*3-1 then   bd3:=varm*3-1;

if round(bd1)>varm*3-1 then
                 begin
                  bd1:=0;
		  bd2:=0;
		  bd3:=0;
                 end;

if adjust and (dura>0) and (dura<varm*30) then
   begin
      adjmul:=varm*3 / ( round(produra/30)*3+3);

      bd1:=(bd1-(smonth-1)*3 )* adjmul;
      bd2:=(bd2-(smonth-1)*3 )* adjmul;
      bd3:=(bd3-(smonth-1)*3 )* adjmul;
   end;

tx:=27;
for k:=1 to round(bd1) do
            if tx<numcol then
                begin
                 write(out,' ');
                 inc(tx);
                end;

if (tx<numcol) and (bd3-bd1<0.5) and (bd3-bd1>1e-5) then
                                begin
                                   write(out,'°');
                                   inc(tx);
                                end;

for k:=1 to round(bd3-bd1) do
	if tx<numcol then
	    begin
	     write(out,'²');                           { Actual progress }
	     inc(tx);
	    end;

if (tx<numcol) and (bd2-bd3<0.5)
	   and (bd2-bd3>1e-5) {and (tx-27<=bd2)}
			then
				begin
                                   write(out,'Ý');
                                   inc(tx);
				end;

for k:=1 to round(bd2-bd3) do
            begin
	    if (tx<numcol) and (tx-27<=round(bd2)) then
			begin
			write(out,'Û');               { Remaining work }
			inc(tx);
			end;
            end;

for k:=tx to numcol-1 do write(out,' ');
write(out,'³');ff;

if printmode then
for cnt:=2 to colno do
begin
write(out,'³',' ':4,'³ ',fixlength(ss[cnt],18,LEFT));
write(out,'³');
for k:=27 to numcol-1 do write(out,' ');
write(out,'³');ff;
end;


write(out,'³',' ':4,'³  ');
{
write(out,fixlength(activity,11,LEFT));
writeln(out,'³');
}
date2str(sd,s);
write(out,s);
if (sd[1]=0) then c:=' ' else c:='-';
write(out,c);
date2str(fd,s);
write(out,s);
write(out,'³');
for k:=27 to numcol-1 do write(out,' ');
write(out,'³');ff;


{
write(out,bd4:5:2);
write(out,'³');
write(out,(bd4-bd1)/(bd2-bd1)*100:5:2);
write(out,'³');
write(out,Real2Str(bd3/Total_cost*100,5,2));
write(out,'³');
write(out,bd3:7:2);
write(out,'³ ');
}

write(out,'³');
write(out,' ':4);

if sd[1]<>0 then
          write(out,'³ ',' ':7,dura:5,' Days ')
   else
          write(out,'³ ',' ':18);

write(out,'³');
for k:=27 to numcol-1 do write(out,' ');
write(out,'³');ff;
  end
  end
  else
  begin
  for tx:=1 to 3 do
      begin
       write(out,'³',' ':4,'³ ',' ':18,'³');
       for k:=27 to numcol-1 do write(out,' ');
       write(out,'³');ff;
      end;
  end;
     j:=j+2;
  end;
if not printmode then
     begin
     write(out,'ÀÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
     KSreadkey(1,c,speckey);
if speckey then
  case c of
  PgDn: if p+5<=No_act then p:=p+5 else p:=No_act;
  PgUp: if p>5 then p:=p-5 else p:=1;
  Down: if p<No_act then inc(p);
    Up: if p>1 then dec(p);
 right: if not adjust then inc(n);
  left: if not adjust and (n>0) then dec(n);
  end;
 end;

if ubreak then c:=ESC;
if printmode and (i=No_act) then c:=ESC;
if ioresult<>0 then goto ExitBarchart;
until c=ESC;

if  printmode then
    begin
         write(out,'ÀÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ');
         for k:=27 to numcol-1 do write(out,'Ä');
         write(out,'Ù');ff;
    end;

ExitBarchart:
  close(out);

{$I+}

if printmode then
             begin
             outname:='CON';
             assign(out,'CON');
             assigncrt(out);
             rewrite(out);
             end;

end; { BarChart }
end.
