unit Dext.Dashboard.TestRunner;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Dext.Json,
  Dext.Json.Types,
  {$IFDEF MSWINDOWS}
  WinApi.Windows,
  WinApi.ShellAPI
  {$ENDIF}
  {$IFDEF POSIX}
  Posix.Stdlib
  {$ENDIF};

type
  TTestRunner = class
  private
    class function FindExecutable(const AProjectPath: string): string;
    class function ExecuteProcess(const AExePath, AParams: string): Boolean;

  public
    class function RunProject(const AProjectPath: string): IDextJsonObject;
  end;

implementation

{ TTestRunner }



class function TTestRunner.ExecuteProcess(const AExePath, AParams: string): Boolean;
{$IFDEF MSWINDOWS}
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: string;
begin
  Result := False;
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE; 
  
  // We use -no-wait argument to tell the runner not to pause at the end
  CmdLine := Format('"%s" %s', [AExePath, AParams]);
  UniqueString(CmdLine);

  if CreateProcess(nil, PChar(CmdLine), nil, nil, False, 0, nil, PChar(TPath.GetDirectoryName(AExePath)), SI, PI) then
  begin
    // We do NOT wait for completion. Fire and forget.
    // The runner will report back via Telemetry.
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
    Result := True;
  end;
end;
{$ELSE}
begin
  {$IFDEF POSIX}
  // Fire and forget in background on Linux
  Result := _system(PAnsiChar(AnsiString(AExePath + ' ' + AParams + ' &'))) = 0;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;
{$ENDIF}

class function TTestRunner.FindExecutable(const AProjectPath: string): string;
var
  BaseName, ProjectDir, ExeExt: string;
  Candidates: TArray<string>;
  Path: string;
begin
  Result := '';
  BaseName := TPath.GetFileNameWithoutExtension(AProjectPath);
  ProjectDir := TPath.GetDirectoryName(AProjectPath);
  
  {$IFDEF MSWINDOWS}
  ExeExt := '.exe';
  {$ELSE}
  ExeExt := '';
  {$ENDIF}
  
  // Potential locations
  Candidates := [
    TPath.Combine(ProjectDir, BaseName + ExeExt),
    TPath.Combine(TPath.Combine(ProjectDir, 'TestOutput'), BaseName + ExeExt),
    TPath.Combine(TPath.Combine(ProjectDir, 'Output'), BaseName + ExeExt),
    // Repo Root Output (approximate)
    TPath.Combine(TPath.GetFullPath(TPath.Combine(ProjectDir, '..\..\Output')), BaseName + ExeExt),
    // Common Win32 Debug output
    TPath.Combine(TPath.Combine(ProjectDir, 'Win32\Debug'), BaseName + ExeExt),
    // Tests/Output (Relative to Tests/Testing)
    TPath.Combine(TPath.Combine(ProjectDir, '..\Output'), BaseName + ExeExt)
  ];
  
  for Path in Candidates do
  begin

    if FileExists(Path) then Exit(Path);
  end;

end;

class function TTestRunner.RunProject(const AProjectPath: string): IDextJsonObject;
var
  ExePath: string;
  ResultsFile: string;
begin
  ExePath := FindExecutable(AProjectPath);

  if ExePath = '' then
  begin
    Result := TDextJson.Provider.CreateObject;
    Result.SetString('error', 'Test executable not found. Please build the project first.');
    Exit;
  end;
  
  // Delete previous results...
  ResultsFile := TPath.Combine(TPath.GetDirectoryName(ExePath), 'test-results.json');
  if FileExists(ResultsFile) then TFile.Delete(ResultsFile);
  
  // Launch Async
  if ExecuteProcess(ExePath, '-no-wait') then
  begin
      Result := TDextJson.Provider.CreateObject;
      Result.SetString('status', 'started');
      Result.SetString('message', 'Tests are running in background. Check dashboard for real-time progress.');
  end
  else
  begin
      Result := TDextJson.Provider.CreateObject;
      Result.SetString('error', 'Failed to execute test process.');
  end;
end;

end.
