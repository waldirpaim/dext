unit Dext.Threading.Sync;

interface

uses
  System.SysUtils,
  System.SyncObjs;

type
  /// <summary>
  ///   A lightweight Multi-Read Exclusive-Write synchronizer wrapper.
  ///   Uses TLightweightMREW on Delphi 10.4.1+ and falls back to TSpinLock on older versions.
  /// </summary>
  TDextMREW = record
  private
{$IF CompilerVersion >= 34.0}
    FLock: TLightweightMREW;
{$ELSE}
    FLock: TSpinLock;
{$ENDIF}
  public
    procedure BeginRead; inline;
    procedure EndRead; inline;
    procedure BeginWrite; inline;
    procedure EndWrite; inline;
  end;

implementation

{ TDextMREW }

{$IF CompilerVersion < 34.0}
{$MESSAGE HINT 'Using TSpinLock fallback for TDextMREW. Consider upgrading to Delphi 10.4.1+ for TLightweightMREW support.'}
{$ENDIF}

procedure TDextMREW.BeginRead;
begin
{$IF CompilerVersion >= 34.0}
  FLock.BeginRead;
{$ELSE}
  FLock.Enter;
{$ENDIF}
end;

procedure TDextMREW.EndRead;
begin
{$IF CompilerVersion >= 34.0}
  FLock.EndRead;
{$ELSE}
  FLock.Exit;
{$ENDIF}
end;

procedure TDextMREW.BeginWrite;
begin
{$IF CompilerVersion >= 34.0}
  FLock.BeginWrite;
{$ELSE}
  FLock.Enter;
{$ENDIF}
end;

procedure TDextMREW.EndWrite;
begin
{$IF CompilerVersion >= 34.0}
  FLock.EndWrite;
{$ELSE}
  FLock.Exit;
{$ENDIF}
end;

end.
