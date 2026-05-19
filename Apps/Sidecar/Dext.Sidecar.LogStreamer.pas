unit Dext.Sidecar.LogStreamer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Dext.Collections,
  Dext.Web.Interfaces,
  Dext.Json;

type
  TEventStreamer = class(TInterfacedObject, IEventStreamer)
  private
    FSessionManager: IStreamableSessionManager;
  public
    constructor Create(const ASessionManager: IStreamableSessionManager);
    procedure PushEvent(const AEventName, AData: string);
    procedure PushEventTo(const ASessionId, AEventName, AData: string);
  end;

implementation

{ TEventStreamer }

constructor TEventStreamer.Create(const ASessionManager: IStreamableSessionManager);
begin
  inherited Create;
  FSessionManager := ASessionManager;
end;

procedure TEventStreamer.PushEvent(const AEventName, AData: string);
var
  LStreamer: IEventStreamer;
begin
  if Supports(FSessionManager, IEventStreamer, LStreamer) then
    LStreamer.PushEvent(AEventName, AData);
end;

procedure TEventStreamer.PushEventTo(const ASessionId, AEventName, AData: string);
var
  LStreamer: IEventStreamer;
begin
  if Supports(FSessionManager, IEventStreamer, LStreamer) then
    LStreamer.PushEventTo(ASessionId, AEventName, AData);
end;


end.
