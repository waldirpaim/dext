unit Dext.Scaffolding.Models;

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  TColumnViewModel = class
  private
    FName: string;
    FDelphiName: string;
    FDataType: string;
    FDelphiType: string;
    FIsPrimaryKey: Boolean;
    FIsAutoInc: Boolean;
    FIsNullable: Boolean;
    FLength: Integer;
    FPrecision: Integer;
    FScale: Integer;
  public
    property Name: string read FName write FName;
    property DelphiName: string read FDelphiName write FDelphiName;
    property DataType: string read FDataType write FDataType;
    property DelphiType: string read FDelphiType write FDelphiType;
    property IsPrimaryKey: Boolean read FIsPrimaryKey write FIsPrimaryKey;
    property IsAutoInc: Boolean read FIsAutoInc write FIsAutoInc;
    property IsNullable: Boolean read FIsNullable write FIsNullable;
    property Length: Integer read FLength write FLength;
    property Precision: Integer read FPrecision write FPrecision;
    property Scale: Integer read FScale write FScale;
    
    function GetAttributeString: string;
  end;

  TFKViewModel = class
  private
    FName: string;
    FColumnName: string;
    FReferencedTable: string;
    FReferencedClass: string;
    FPropertyName: string;
  public
    property Name: string read FName write FName;
    property ColumnName: string read FColumnName write FColumnName;
    property ReferencedTable: string read FReferencedTable write FReferencedTable;
    property ReferencedClass: string read FReferencedClass write FReferencedClass;
    property PropertyName: string read FPropertyName write FPropertyName;
  end;

  TTableViewModel = class
  private
    FName: string;
    FClassName: string;
    FColumns: TObjectList<TColumnViewModel>;
    FForeignKeys: TObjectList<TFKViewModel>;
  public
    constructor Create;
    destructor Destroy; override;
    
    property Name: string read FName write FName;
    property DelphiClassName: string read FClassName write FClassName;
    property Columns: TObjectList<TColumnViewModel> read FColumns;
    property ForeignKeys: TObjectList<TFKViewModel> read FForeignKeys;
  end;

  TScaffoldViewModel = class
  private
    FNamespace: string;
    FTables: TObjectList<TTableViewModel>;
  public
    constructor Create;
    destructor Destroy; override;
    
    property Namespace: string read FNamespace write FNamespace;
    property Tables: TObjectList<TTableViewModel> read FTables;
  end;

implementation

{ TColumnViewModel }

function TColumnViewModel.GetAttributeString: string;
var
  Attrs: TList<string>;
begin
  Attrs := TList<string>.Create;
  try
    if FIsPrimaryKey then Attrs.Add('PK');
    if FIsAutoInc then Attrs.Add('AutoInc');
    if not FIsNullable then Attrs.Add('Required');
    if (FLength > 0) and (FDelphiType = 'string') then
      Attrs.Add('MaxLength(' + FLength.ToString + ')');
    if FPrecision > 0 then
      Attrs.Add(Format('Precision(%d, %d)', [FPrecision, FScale]));
    
    if Attrs.Count = 0 then
      Exit('');
      
    Result := '[' + string.Join(', ', Attrs.ToArray) + ']';
  finally
    Attrs.Free;
  end;
end;

{ TTableViewModel }

constructor TTableViewModel.Create;
begin
  FColumns := TObjectList<TColumnViewModel>.Create(True);
  FForeignKeys := TObjectList<TFKViewModel>.Create(True);
end;

destructor TTableViewModel.Destroy;
begin
  FColumns.Free;
  FForeignKeys.Free;
  inherited;
end;

{ TScaffoldViewModel }

constructor TScaffoldViewModel.Create;
begin
  FTables := TObjectList<TTableViewModel>.Create(True);
end;

destructor TScaffoldViewModel.Destroy;
begin
  FTables.Free;
  inherited;
end;

end.
