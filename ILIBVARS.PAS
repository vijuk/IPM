const
{$IFNDEF NEWIPM}
     addlen=60;
     dedlen=20;
     actlen=80;
{$ELSE}
     addlen=80;
     dedlen=80;
     actlen=160;
{$ENDIF}

type
     stringlines=file of string;
     matrectype=record
        desc:string[80];
        u:string[4];
        sx:array[1..10] of string[25];
        sv:array[1..10] of real;
        su:array[1..10] of string[5]; { 5 to 4 }
     end;
const
     DataCheck=TRUE;               {
                                   To check whether data is valid.
                                   Takes more time when set TRUE.
                                   Provide an option for user.
                                   }
     day30=365.25/12;
     hc:byte=1;
     col1:byte=1;
     col2:byte=1;
     pushed:boolean=FALSE;
     alphaset=[#32..#127];
     SA=1;     { Schedule of Activities }
     QS=2;     { Quantity surveying }
     TR=3;     { Tender Rates }
     SR=4;     { Site Report }
     SC_A=5;   { Subcontractor's Bill Abstract }
     SC_D=6;   { SubContractor's Bill Detailed }
     BM=7;     { Breakup of materials }
     CB=8;     { Contractor's Bill }
     MR=9;     { Material ratios }
     barco:integer=80;

     no_names:integer=0;
     no_dates:integer=0;
     sflag:boolean=FALSE;
     memdrive:boolean=FALSE;
     diskaddr:integer=1;
     mfno:integer=0;
     optmem:boolean=TRUE;

type
   datetype=array[1..3] of integer;

   sheettype1=record
                recno:integer;
		actcode:string[5];
		code:string[12];
                sub_id:string[20];
                activity:string[actlen];

{$IFNDEF NEWIPM}
                mix :byte;              { remove this }
                nos,                    { remove this }
{$ENDIF}

                length,breadth,height:real;
                subQ,addQ:real;

{$IFNDEF NEWIPM}
                aggr_size:integer;      { remove this }
                cement,sand,aggr:real;  { remove this }
{$ENDIF}
		quantity,qdone:real;
		munit:string[12];
		sc_rate,c_rate:real;
		cd,ed,sd,fd,ad:datetype;
		stat:byte;
		pres,prev:real;
                tapno:integer;
		a,tap:pointer;
	end;


(*
   sheettype2=record               { Future : Used to update data files }
                recno:integer;
		actcode:string[5];
		code:string[12];
                sub_id:string[20];
                activity:string[160];
                mix :byte;              { remove this }
                nos,length,breadth,height:real;
                subQ,addQ:real;
                aggr_size:integer;
                cement,sand,aggr:real;  { remove this }
		quantity,qdone:real;
		munit:string[12];
		sc_rate,c_rate:real;
		cd,ed,sd,fd,ad:datetype;
		stat:byte;
		pres,prev:real;
                tapno:integer;
		a,tap:pointer;
	end;
*)

     psheettype1=^sheettype1;
     atype1=array[1..150] of string[20]; { Subcontractor's name/ Date list }

type
     astring=array[1..5] of string[50];

const
     hv:array[1..10] of integer=(1,1,1,1,1,1,1,1,1,1);

     qd:real=0.0;
     Act_Q:real=0;
     passwd:string[10]='IMS';
     errorflag:boolean=FALSE;
     TN:integer=1;

var
   col80,adjust:boolean;

   heap,heap0:pointer;
   filerecord:searchrec;
   path:pathstr;
   name:namestr;
   ext:extstr;

   proname,sfname,rfname:string;

   namelist:atype1;
   datelist:atype1;

   k:integer;
   att:word;
   tpres,tprev,bal:real;
   d:datetype;
   No_act:integer;
   st_m,st_hl:integer;
   outrec:boolean;
   footer:string;
   st_sheet,temp,store1,store2:psheettype1;
   subname:string;
   purpose:byte;
   syear,smonth,sday,eyear,emonth,eday:integer;
   opt,num:integer;
   s:string;
   head:headtype;
   hpixcode:char;
   screen:image;
   c:char;
   c1,c2:byte;
   i,j,m,n:integer;
   hl,x:integer;
   first,last,sheet1:psheettype1;
   strec,storeno:integer;
   dater:integer;

PROCEDURE ff;
PROCEDURE memdisp;
FUNCTION  overflow:boolean;
PROCEDURE initrec;
PROCEDURE appendrec(var last:psheettype1);
PROCEDURE takerec(rn:integer);
FUNCTION  gt(as:char;d:datetype;flag:boolean):real;
PROCEDURE delrec(var first,last:psheettype1;rn:integer);
PROCEDURE insrec(var first,last:psheettype1;rn:integer);
PROCEDURE bymenu(sheettype:integer);
PROCEDURE datecheck(s1,s2,s3,f1,f2,f3:integer;var dater:integer);
FUNCTION  daysIn(month,year:integer):integer;
FUNCTION  days_In_year(year:integer):integer;
FUNCTION  duradays(day1,month1,year1,day2,month2,year2:integer):integer;
PROCEDURE dura_2_days(day1,month1,year1,dura:integer;var day2,month2,year2:integer);
FUNCTION  checkvaldate(var day,month,year:integer):boolean;
PROCEDURE str2date(s:string;var x1,x2,x3:integer);
PROCEDURE date2str(d:datetype;var s:string);
PROCEDURE moveup;
PROCEDURE movedown;
PROCEDURE copyrec(var sheet1,temp:psheettype1);
PROCEDURE menufill(sheettype:integer);
PROCEDURE selectread(sheettype:integer);
PROCEDURE writetable(sheettype:integer);
PROCEDURE drawtable(sheettype:integer);
PROCEDURE checkpost;
PROCEDURE push;
PROCEDURE pop;
PROCEDURE init_tables;
PROCEDURE save(fname:string);
PROCEDURE load(fname:string);
PROCEDURE moveoresc(sheettype:integer);
PROCEDURE sheet(sheettype:integer);
PROCEDURE urgentservice(var request:char);
PROCEDURE writedes_string(s:string);
PROCEDURE notnow;
PROCEDURE sel_name_date(x,y:byte;prompt:string;namelist:atype1;no_names:integer;var sels:string);
PROCEDURE sel_date(sheettype,x,y:byte);
PROCEDURE mybackground(x,y:byte);
PROCEDURE saveguard;
PROCEDURE update_namelist;
FUNCTION  getsyear:integer;
FUNCTION  getsmonth:integer;
FUNCTION  getsday:integer;
FUNCTION  geteyear:integer;
FUNCTION  getemonth:integer;
FUNCTION  geteday:integer;
PROCEDURE fileinfo(fname:string);
PROCEDURE printinput;
procedure editfile(s:string);
procedure sel_line(var matinp:stringlines;fname:string;var select:string);
procedure align(s:string;var ss:astring;var col:integer);
