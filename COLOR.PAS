uses
    crt;
var
    i:integer;

begin
for i:=1 to 255 do
    begin
         textattr:=i;
         writeln(i,' ******************************');
    readln;
    end;
end.