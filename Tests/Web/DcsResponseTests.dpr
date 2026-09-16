program DcsResponseTests;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, System.Rtti, System.Net.HttpClient, System.Net.URLClient,
  Net.CrossHttpServer, Dext.Web.Interfaces,
  Dext.Web.DCS in '..\..\Sources\Web\Dext.Web.DCS.pas';
type
  TBridge = class
    procedure Handle(const Req: ICrossHttpRequest; const Resp: ICrossHttpResponse; var Handled: Boolean);
  end;
procedure TBridge.Handle(const Req: ICrossHttpRequest; const Resp: ICrossHttpResponse; var Handled: Boolean);
var Adapter: TDextDCSResponse; Response: Dext.Web.Interfaces.IHttpResponse; Bytes: TBytes;
begin
  Handled := True;
  Adapter := TDextDCSResponse.Create(Resp);
  Response := Adapter;
  if Req.Path = '/sent' then
  begin
    Resp.StatusCode := 201;
    Resp.Send('already sent');
  end
  else if Req.Path = '/empty' then Response.Write('')
  else if Req.Path = '/redirect' then Response.AddHeader('HX-Redirect', '/login')
  else if Req.Path = '/no-content' then Response.StatusCode := 204
  else if Req.Path = '/text' then Response.Write('<p>ok</p>')
  else if Req.Path = '/json-raw' then Response.SendJsonUtf8(RawByteString('{"ok":true}'))
  else if Req.Path = '/json-bytes' then Response.SendJsonUtf8(TEncoding.UTF8.GetBytes('{"ok":true}'))
  else if Req.Path = '/json-stream' then
  begin
    Bytes := TEncoding.UTF8.GetBytes('{"ok":true}');
    Response.GetOutputStream.WriteBuffer(Bytes[0], Length(Bytes));
  end
  else if Req.Path = '/json-value' then Response.WriteJson(TValue.From<Integer>(42))
  else if Req.Path = '/json-status' then Response.WriteJson(201, TValue.From<Integer>(42))
  else if Req.Path = '/status-message' then Response.Status(202, 'Accepted');
  Adapter.FlushToResponse(SameText(Req.Header['HX-Request'], 'true'));
end;
procedure CheckResponses;
var
  Client: THTTPClient; Response: System.Net.HttpClient.IHTTPResponse;
  Headers: TNetHeaders; Hx: Boolean; Route, ExpectedBody, Body: string;
  ExpectedStatus, Cases: Integer;
begin
  Cases := 0;
  Client := THTTPClient.Create;
  try
    Client.ConnectionTimeout := 3000;
    Client.ResponseTimeout := 3000;
    for Hx in [False, True] do
    begin
      SetLength(Headers, 0);
      if Hx then
      begin
        SetLength(Headers, 1);
        Headers[0] := TNameValuePair.Create('HX-Request', 'true');
      end;
      for Route in ['/empty', '/ok', '/redirect', '/no-content', '/text',
        '/json-raw', '/json-bytes', '/json-stream', '/json-value', '/json-status', '/status-message', '/sent'] do
      begin
        Response := Client.Get('http://127.0.0.1:9130' + Route, nil, Headers);
        Body := Response.ContentAsString;
        ExpectedStatus := 200;
        ExpectedBody := '';
        if Route = '/sent' then
        begin
          ExpectedStatus := 201;
          ExpectedBody := 'already sent';
        end
        else if Route = '/no-content' then ExpectedStatus := 204
        else if Route = '/text' then ExpectedBody := '<p>ok</p>'
        else if (Route = '/json-value') or (Route = '/json-status') then
        begin
          ExpectedBody := '42';
          if Route = '/json-status' then ExpectedStatus := 201;
        end
        else if Route.StartsWith('/json-') then ExpectedBody := '{"ok":true}'
        else if Route = '/status-message' then ExpectedStatus := 202;
        if not Hx and (ExpectedBody = '') and (ExpectedStatus <> 204) then
        begin
          if ExpectedStatus = 202 then ExpectedBody := 'Accepted' else ExpectedBody := 'OK';
        end;
        if Response.StatusCode <> ExpectedStatus then raise Exception.Create('Status incorreto: ' + Route);
        if Body <> ExpectedBody then raise Exception.CreateFmt('Corpo incorreto: %s HX=%s esperado=[%s] recebido=[%s]',
          [Route, BoolToStr(Hx, True), ExpectedBody, Body]);
        if (Route = '/redirect') and (Response.HeaderValue['HX-Redirect'] <> '/login') then
          raise Exception.Create('HX-Redirect perdido');
        if Route.StartsWith('/json-') and not Response.HeaderValue['Content-Type'].StartsWith('application/json') then
          raise Exception.Create('Content-Type JSON perdido');
        Inc(Cases);
      end;
    end;
  finally Client.Free; end;
  WriteLn('PASS: ', Cases, ' cenarios DCS HTTP real');
end;
var Server: ICrossHttpServer; Bridge: TBridge;
begin
  try
    Bridge := TBridge.Create;
    try
      Server := TCrossHttpServer.Create(2, False);
      try
        Server.Addr := '127.0.0.1';
        Server.Port := 9130;
        Server.All('*', Bridge.Handle);
        Server.Start;
        try CheckResponses; finally Server.Stop; end;
      finally Server := nil; end;
    finally Bridge.Free; end;
  except on E: Exception do begin WriteLn(E.ClassName + ': ' + E.Message); Halt(1); end; end;
end.
