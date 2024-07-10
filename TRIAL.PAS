{ample for DosExitCode and Exec }

{$M $4000,0,0 }   { 16K stack, no heap }
uses Dos;
var
  ProgramName, CmdLine: string;
begin
  WriteLn('About to Exec...');
  SwapVectors;
  Exec('bgidemo','c:\command.com');
  SwapVectors;
  WriteLn('...back from Exec');
  if DosError <> 0 then{ Error? }
    WriteLn('Dos error #', DosError)
  else
    WriteLn('Exec successful. ',
            'Child process exit code = ',
            DosExitCode);
end.



c