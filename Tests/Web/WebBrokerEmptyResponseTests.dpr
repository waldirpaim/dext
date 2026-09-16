program WebBrokerEmptyResponseTests;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient, Web.HTTPApp,
  IdHTTPServer, IdContext, IdCustomHTTPServer, IdHTTPWebBrokerBridge,
  Dext, Dext.Web, Dext.Web.Interfaces, Dext.Configuration.Interfaces,
  Dext.Web.WebBroker in '..\..\Sources\Web\Dext.Web.WebBroker.pas';
type
  TStartup = class(TInterfacedObject, IStartup)
    procedure ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
    procedure Configure(const App: IWebApplication);
  end;
  TBridge = class
    procedure Handle(Ctx: TIdContext; Req: TIdHTTPRequestInfo; Resp: TIdHTTPResponseInfo);
  end;
procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin end;
procedure TStartup.Configure(const App: IWebApplication);
begin
  App.GetApplicationBuilder.MapGet('/empty', procedure(C: IHttpContext) begin C.Response.Write(''); end);
  App.GetApplicationBuilder.MapGet('/ok', procedure(C: IHttpContext) begin C.Response.StatusCode := 200; end);
  App.GetApplicationBuilder.MapGet('/redirect', procedure(C: IHttpContext) begin C.Response.AddHeader('HX-Redirect', '/login'); end);
  App.GetApplicationBuilder.MapGet('/no-content', procedure(C: IHttpContext) begin C.Response.StatusCode := 204; end);
end;
procedure TBridge.Handle(Ctx: TIdContext; Req: TIdHTTPRequestInfo; Resp: TIdHTTPResponseInfo);
var WReq: TIdHTTPAppRequest; WResp: TIdHTTPAppResponse;
begin
  WReq := TIdHTTPAppRequest.Create(Ctx, Req, Resp);
  try
    WResp := TIdHTTPAppResponse.Create(WReq, Ctx, Req, Resp);
    try
      Resp.FreeContentStream := False;
      TDextWebBrokerApp.HandleRequest(WReq, WResp);
      WResp.SendResponse;
    finally WResp.Free; end;
  finally WReq.Free; end;
end;
procedure CheckResponses;
var
  Client: THTTPClient;
  Response: System.Net.HttpClient.IHTTPResponse;
  Headers: TNetHeaders;
  Hx: Boolean;
  Route, Body: string;
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
      for Route in ['/empty', '/ok', '/redirect', '/no-content'] do
      begin
        Response := Client.Get('http://127.0.0.1:9129' + Route, nil, Headers);
        Body := Response.ContentAsString;
        ExpectedStatus := 200;
        if Route = '/no-content' then ExpectedStatus := 204;
        if Response.StatusCode <> ExpectedStatus then
          raise Exception.Create('Status incorreto em ' + Route);
        if Hx or (ExpectedStatus = 204) then
        begin
          if Body <> '' then raise Exception.Create('Corpo deveria estar vazio em ' + Route);
        end
        else if Pos('200 OK', Body) = 0 then
          raise Exception.Create('Resposta sem HTMX foi alterada em ' + Route);
        if (Route = '/redirect') and (Response.HeaderValue['HX-Redirect'] <> '/login') then
          raise Exception.Create('HX-Redirect nao foi preservado');
        Inc(Cases);
      end;
    end;
  finally Client.Free; end;
  WriteLn('PASS: ', Cases, ' cenarios WebBroker/Indy');
end;
var Server: TIdHTTPServer; Bridge: TBridge;
begin
  try
    TDextWebBrokerApp.Configure(TStartup.Create);
    Bridge := TBridge.Create;
    try
      Server := TIdHTTPServer.Create(nil);
      try
        Server.DefaultPort := 9129;
        Server.Bindings.Add.IP := '127.0.0.1';
        Server.Bindings[0].Port := 9129;
        Server.OnCommandGet := Bridge.Handle;
        Server.Active := True;
        CheckResponses;
        Server.Active := False;
      finally Server.Free; end;
    finally Bridge.Free; end;
    TDextWebBrokerApp.Shutdown;
  except on E: Exception do begin WriteLn(E.ClassName + ': ' + E.Message); Halt(1); end; end;
end.
