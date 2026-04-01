unit Dext.EF.Design.Editors;

interface

uses
  System.SysUtils,
  System.Classes,
  DesignIntf,
  DesignEditors,
  ToolsAPI,
  VCLEditors,
  Dext.Entity.DataSet,
  Dext.Entity.Core,
  Dext.EF.Design.DataProvider,
  Dext.EF.Design.Preview;

type
  TEntityClassNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  TEntityDataSetEditor = class(TComponentEditor)
  public
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure RegisterEditors;

implementation

procedure RegisterEditors;
begin
  RegisterComponents('Dext Entity', [TEntityDataProvider]);
  RegisterPropertyEditor(TypeInfo(string), TEntityDataSet, 'EntityClassName', TEntityClassNameProperty);
  RegisterComponentEditor(TEntityDataSet, TEntityDataSetEditor);
end;
{ TEntityClassNameProperty }

function TEntityClassNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TEntityClassNameProperty.GetValues(Proc: TGetStrProc);
var
  DataSet: TEntityDataSet;
  DP: IEntityDataProvider;
  Entities: TArray<string>;
  E: string;
begin
  DataSet := GetComponent(0) as TEntityDataSet;
  if Assigned(DataSet.DataProvider) then
  begin
    if DataSet.DataProvider.GetInterface(IEntityDataProvider, DP) then
    begin
      Entities := DP.GetEntities;
      for E in Entities do
        Proc(E);
    end;
  end;
end;

procedure TEntityClassNameProperty.SetValue(const Value: string);
var
  DataSet: TEntityDataSet;
  DP: IEntityDataProvider;
  EntityMD: TEntityClassMetadata;
begin
  inherited SetValue(Value);
  
  DataSet := GetComponent(0) as TEntityDataSet;
  if Assigned(DataSet.DataProvider) and DataSet.DataProvider.GetInterface(IEntityDataProvider, DP) then
  begin
    EntityMD := DP.GetEntityMetadata(Value);
    if EntityMD <> nil then
    begin
        // Auto-inject logic (optional but helpful)
        // Find module of the entity and add its unit to the current dataset's form
        // We'll need a better way to find which unit contains the entity in TEntityDataProvider
    end;
  end;
end;

{ TEntityDataSetEditor }

procedure TEntityDataSetEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: (Component as TEntityDataSet).GenerateFields;
    1: ShowEntityPreview(Component as TEntityDataSet);
  end;
end;

function TEntityDataSetEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Generate Fields from Source';
    1: Result := 'Preview Data...';
  end;
end;

function TEntityDataSetEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

end.
