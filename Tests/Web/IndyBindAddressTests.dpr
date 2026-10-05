program IndyBindAddressTests;
{
  TDextIndyWebServer with and without a bind address, against real sockets.
  A bound server must accept on its address and be unreachable through any
  other local interface; the unbound control must be reachable through both,
  which proves the probe can tell the two cases apart.
  Run with Run-IndyBindAddressTests.ps1.
}
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes,
  IdGlobal, IdStack, IdTCPClient,
  Dext.Web.Interfaces,
  Dext.Web.Indy.Server in '..\..\Sources\Web\Dext.Web.Indy.Server.pas';

var
  GFailures: Integer = 0;

procedure Check(ACondition: Boolean; const AName: string);
begin
  if ACondition then
    Writeln('[PASS] ' + AName)
  else
  begin
    Writeln('[FAIL] ' + AName);
    Inc(GFailures);
  end;
end;

function CanConnect(const AHost: string; APort: Integer): Boolean;
var
  LClient: TIdTCPClient;
begin
  LClient := TIdTCPClient.Create(nil);
  try
    LClient.Host := AHost;
    LClient.Port := APort;
    LClient.ConnectTimeout := 2000;
    try
      LClient.Connect;
      LClient.Disconnect;
      Result := True;
    except
      Result := False;
    end;
  finally
    LClient.Free;
  end;
end;

// First local IPv4 address that is not loopback, or '' when the machine has none.
function FirstNonLoopbackIPv4: string;
var
  LList: TIdStackLocalAddressList;
  I: Integer;
begin
  Result := '';
  TIdStack.IncUsage;
  try
    LList := TIdStackLocalAddressList.Create;
    try
      GStack.GetLocalAddressList(LList);
      for I := 0 to LList.Count - 1 do
        if (LList[I].IPVersion = Id_IPv4) and not LList[I].IPAddress.StartsWith('127.') then
          Exit(LList[I].IPAddress);
    finally
      LList.Free;
    end;
  finally
    TIdStack.DecUsage;
  end;
end;

procedure CheckServer(const ABind, AExternal: string; AExpectExternal: Boolean);
var
  LHost: IWebHost;
  LPort: Integer;
  LLabel: string;
begin
  if ABind = '' then
    LLabel := 'no bind address'
  else
    LLabel := 'bind ' + ABind;
  LHost := TDextIndyWebServer.Create(0,
    procedure(AContext: IHttpContext)
    begin
    end, nil, nil, ABind);
  try
    LHost.Start;
    LPort := LHost.Port;
    Check(LPort > 0, LLabel + ': listening on an ephemeral port');
    Check(CanConnect('127.0.0.1', LPort), LLabel + ': reachable on 127.0.0.1');
    if AExternal <> '' then
    begin
      if AExpectExternal then
        Check(CanConnect(AExternal, LPort), LLabel + ': reachable on ' + AExternal)
      else
        Check(not CanConnect(AExternal, LPort), LLabel + ': refused on ' + AExternal);
    end;
  finally
    LHost.Stop;
    LHost := nil;
  end;
end;

var
  LExternal: string;
begin
  try
    LExternal := FirstNonLoopbackIPv4;
    if LExternal = '' then
      Writeln('[WARN] no non-loopback IPv4 address: interface checks skipped')
    else
      Writeln('Non-loopback address under test: ' + LExternal);

    CheckServer('', LExternal, True);
    CheckServer('127.0.0.1', LExternal, False);
    CheckServer(' 127.0.0.1 ', LExternal, False);

    if LExternal = '' then
      ExitCode := 2
    else if GFailures > 0 then
      ExitCode := 1
    else
      ExitCode := 0;
    Writeln(Format('Failures: %d', [GFailures]));
  except
    on E: Exception do
    begin
      Writeln('[ERROR] ' + E.ClassName + ': ' + E.Message);
      ExitCode := 3;
    end;
  end;
end.
