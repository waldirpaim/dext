unit Dext.EF.Design.DataProvider;

interface

uses
  System.SysUtils,
  System.Classes,
  Dext.Collections,
  Dext.Collections.Dict,
  FireDAC.Comp.Client,
  Dext.Entity.Core,
  Dext.EF.Design.Metadata;

type
  TEntityDataProvider = class(TComponent, IEntityDataProvider)
  private
    FModelUnits: TStrings;
    FMetadataCache: IDictionary<string, TEntityClassMetadata>;
    FConnection: TFDConnection;
    procedure SetModelUnits(const Value: TStrings);
    procedure OnModelUnitsChange(Sender: TObject);
    procedure SetConnection(const Value: TFDConnection);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshMetadata;
    procedure RefreshUnit(const AFileName: string);
    function GetEntities: TArray<string>;
    function GetEntityMetadata(const AClassName: string): TEntityClassMetadata;
  published
    property ModelUnits: TStrings read FModelUnits write SetModelUnits;
    property Connection: TFDConnection read FConnection write SetConnection;
  end;

implementation

{ TEntityDataProvider }

constructor TEntityDataProvider.Create(AOwner: TComponent);
begin
  inherited;
  FModelUnits := TStringList.Create;
  TStringList(FModelUnits).OnChange := OnModelUnitsChange;
  FMetadataCache := TCollections.CreateDictionary<string, TEntityClassMetadata>(True);
end;

destructor TEntityDataProvider.Destroy;
begin
  FMetadataCache := nil; { Interface ARC }
  FModelUnits.Free;
  inherited;
end;

function TEntityDataProvider.GetEntities: TArray<string>;
var
  List: TList<string>;
  MD: TEntityClassMetadata;
begin
  List := TList<string>.Create;
  try
    for MD in FMetadataCache.Values do
      List.Add(MD.ClassName);
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function TEntityDataProvider.GetEntityMetadata(const AClassName: string): TEntityClassMetadata;
begin
  if not FMetadataCache.TryGetValue(AClassName, Result) then
    Result := nil;
end;

procedure TEntityDataProvider.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FConnection) then
    FConnection := nil;
end;

procedure TEntityDataProvider.OnModelUnitsChange(Sender: TObject);
begin
  if csDesigning in ComponentState then
    RefreshMetadata;
end;

procedure TEntityDataProvider.RefreshMetadata;
var
  FileName: string;
begin
  FMetadataCache.Clear;
  for FileName in FModelUnits do
  begin
    RefreshUnit(FileName);
  end;
end;

procedure TEntityDataProvider.RefreshUnit(const AFileName: string);
var
  Parser: TEntityMetadataParser;
  List: TList<TEntityClassMetadata>;
  MD: TEntityClassMetadata;
begin
  Parser := TEntityMetadataParser.Create;
  try
    List := TList<TEntityClassMetadata>(Parser.ParseUnit(AFileName));
    try
      for MD in List do
      begin
        // Add or Overwrite in cache
        FMetadataCache.AddOrSetValue(MD.ClassName, MD);
      end;
      // Clear list to stop it from owning the items we just put in cache
      List.OwnsObjects := False; 
    finally
      List.Free;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TEntityDataProvider.SetConnection(const Value: TFDConnection);
begin
  if FConnection <> Value then
  begin
    FConnection := Value;
    if FConnection <> nil then
      FConnection.FreeNotification(Self);
  end;
end;

procedure TEntityDataProvider.SetModelUnits(const Value: TStrings);
begin
  FModelUnits.Assign(Value);
end;

end.
