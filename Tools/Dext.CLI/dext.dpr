program dext;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Dext.CLI.App in 'Dext.CLI.App.pas';

begin
  try
    var App := TDextCLI.Create;
    try
      if not App.Run then
      begin
        if ParamCount = 0 then
          App.ShowHelp;
      end;
    finally
      App.Free;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end.
