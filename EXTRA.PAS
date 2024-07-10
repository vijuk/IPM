unit extra;
interface
uses lib,ilib;
type
   purchdatetype=
		record
			purchact:string[80];
			purchunit:string[4];
			psd,pfd:datetype;
			diffsd:array[0..80] of integer;
		end;
   var
      purchdate:purchdatetype;

function nomatch:boolean;

implementation

   function nomatch:boolean;
   begin

{
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

   if   not ( (nospace(upstringf(purchdate.purchact))=nospace(upstringf(sheet1^.activity)))
				and
			    (nospace(upstringf(purchdate.purchunit))=
				nospace(upstringf(sheet1^.munit)))
				and
				   (purchdate.psd[1]=sheet1^.sd[1])
				and
				   (purchdate.psd[2]=sheet1^.sd[2])
                                and
				   (purchdate.psd[3]=sheet1^.sd[3])
				and
				   (purchdate.pfd[1]=sheet1^.fd[1])
				and
				   (purchdate.pfd[2]=sheet1^.fd[2])
				and
				   (purchdate.pfd[3]=sheet1^.fd[3]) )
                                then
					begin
                                        nomatch:=TRUE;
                                        end
				else
               begin
               nomatch:=FALSE;

{              writeln('*',purchdate.purchact);
               writeln('**',sheet1^.activity);
}
               end;

   end;
end.
