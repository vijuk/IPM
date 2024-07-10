***********************************************************  50
 Ü Welcome to Project Manager's On-line Help                   1
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß                   2
You can learn about Project Manager through this               3
on-line Help system.                                           4
                                                               5
 þ What you're reading right now is a "Help                    6
   screen."                                                    7
 þ Most Help screens have some highlighted                     8
   items ("Help keywords") on them that lead                   9
   to another Help screen.                                     10
                                                               11
 ÚÄÄÄÄÄ¿ You can use the arrow keys to move                    12
 ³|| <>³ the cursor from one Help keyword to                   13
 ÀÄÄÄÄÄÙ another, then press Enter to choose                   14
         that item.                                            15
***********************************************************  9,39,58,1, 3
Project Menu                                                   1
------------                                                   2
                                                               3
New option      :-                                             4
                                                               5
Assigns data file name for a starting project. The main        6
data file will be given a ".DAT" extension by the              7
software. This name is used to in all secondary data files.    8
                                                               9
                                                               10
Retrieve option  :-                                            11
                                                               12
Displays all the files with ".DAT"  extension in the           13
current directory. Select file by pressing ENTER.              14
                                                               15
***********************************************************  4,5,9,7, 4,5,16,1, 3
Save option     :-

Saves the file to disk. ( Power failure during save
option may result in data loss! ).

Pressing ENTER twice at this option will create a
backup copy of the project file with ".BAK" extention.

Save As option  :-

Saves the project with another file name. This option
can be used before a Save option to reduce the risk of
data loss during a power failure.


***********************************************************  4,5,9,7, 4,5,16,1, 3
Create/Edit data files option :-


Select this option to create  project information
file, subcontractors's name list, contractor's bill
forms etc.


a) PROJECT.INF : Selecting this option will display a
blank editor window. The details of the project such
as Client's name , Site details , Project Engineer's
name etc. may be typed in and after completion, exit
the editor by pressing ESC. The typed matter will be
displayed inside the INFO window while Retrive option
is selected. This option only serves for identification
***********************************************************  4,5,9,7, 4,5,16,1, 3
of the project and its use is optional.

b) PROJECT.SNL :- The editor window is displayed when
this option is selected. All the subcontractors's names
should be entered. More than one name should not be typed
on the same line. CAUTION:  Change of a subcontractor's
name ( even by a single alphabet or period ) or deletion
of a name after the entry for site report may cause

malfunctioning of the program. But the addition of new
names to the list is permitted.

c) PROJECT.CBF  :- A standard format for the contractors's
bill is supplied with the software in file IPM.CBF.
Still it may be necessary to change various parameters of
***********************************************************  4,5,9,7, 4,5,16,1, 3
the bill for each new project. Copy IPM.CBF to proname.CBF
and change the required parameters to suit the new project.
This enables the user to generate bills in any format.
At the time of execution the program supplies computed
values to the ".CBF" file and interpretation of the
instructions in the ".CBF" file is carried out to generate
the output.  Logical errors in mathematical expressions
in the ".CBF"  file can not be checked by the software.

File maintenance option :-

This option allows to execute  all the important DOS
file maintenance commands inside the software.

Inputs Menu
***********************************************************  4,5,9,7, 4,5,16,1, 3
-----------

Genreral : Except the "Create/edit data files" option
all the inputs are given through this menu option.
The sub-menus can be selected in any order for
feeding input. The outputs will be generated only if
sufficient data is made available to the program
to produce the s ame.


The recommended input sequence is as follows :-

Step 1.

     Input schedule of activities. Each activity should
***********************************************************  4,5,9,7, 4,5,16,1, 3
have an independent rate and unit of measurement. The given
start and end dates should be feasible dates.For example,if
the start date is later than the end date the software will
flag off an error while trying to generate outputs.
There are two methods of inputing activity dates- start date
and end date , or start date and duration in days. The
program will automatically compute the end date, if duration
is given in place end date.



Step 2.

     Input quantity surveying details for each activity.
The code names for building components should be assigned
***********************************************************  4,5,9,7, 4,5,16,1, 3
keeping in mind the method of measurement for the same.
Since software does not support partial payment for any
item, each item code should represent an independant entry
in the payment bill. The additions or deductions should be
entered through mathematical expressions for easy identi-
fication at a later stage. But only the final result of
expression will be displayed on the corresponding column
in the screen . The full calculations will be printed on
paper while taking printout for bills.



   While using mathematical expressions at the edit prompt
the various symbols and functions which can be used to form
valid expressions is displayed by pressing F2 function key.
***********************************************************  4,5,9,7, 4,5,16,1, 3
If the program is unable to evaluate the expression due to
bad constructs , the cursor will not return to the upper
screen until the expression is made error free. Any way,it
is possible to abandon the current expression by pressing ^C.

Step 3.

     Input the company's rate and the subcontractors's rates
for the same unit of measurement.  The rates should not be
changed after completion of an activity.



Step 4.

***********************************************************  4,5,9,7, 4,5,16,1, 3
     Site report entry can be made only after the sub-
contractors's name list has been typed in the PROJECT.SNL
file. It displays all the subcontractors's names. Pick the
name of the person whose work has to be credited. The
closing date of measurement as given in the report send
from the site is also feeded. The program then displays the
list of all the activities. The activity in which the
completed item resides has to be selected. Again select the
items which has been completed by the subcontractor on the
same closing date by pointing and pressing ENTER on the
item. A tick mark appears with the code name which indicates
that the selection has been accepted by the computer. If

the selected item already has a tick mark then the computer
asks for user's password. The need for such data security
***********************************************************  4,5,9,7, 4,5,16,1, 3
is to prevent payment for an item to more than one
subcontractor. Once the site entry for an item is done the
quantities or rates for that item should not be changed at
any stage of the project. The effects of such changes are
still not fully studied.

At present the user's password is set to be capital "IMS".




For more information please wait for User's Referance Manual.

( On-line help system is incomplete and is written in a crude
way at present. The need of explanation at any instant of
***********************************************************  4,5,9,7, 4,5,16,1, 3

the execution of this program may be pointed out by the user.
A great amount of effort and care has been made to bring out
this program. But enough trial runs have not been conducted
to remove hidden bugs, due to lack of time. So it is assumed
that user will check the outputs for its correctness
independantly till the software is proved to be error free.


The on-line help system is designed to be case sensitive in
future. The complete on-line help file and printed User's
Referance Manual will be completed as soon as possible .
Any suggestions on improving the program or, grammatical or
spelling mistakes in documentation will be greatly
acknowledged. )
***********************************************************  4,5,9,7, 4,5,16,1, 3


Please feel free to contact :

                     Viju.K.S.,
                     M.Tech (Struct. Engg.),
                     PG Hostel - 208,
                     REC P.O.- 673601,
                     Calicut Regional Engg. College.

Thank You.

End of Help File.               Last modified : 2/9/95

