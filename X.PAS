{***** Free diskspace for scratch files }
   findfirst('D:\*.*',$20,filerecord);
   while doserror=0 do
         begin
             assign(df,'D:\'+filerecord.name);
             erase(df);
             findnext(filerecord);
         end;
