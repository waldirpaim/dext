unit Dext.Entity.TemplatedScaffolding;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Dext.Entity.Scaffolding,
  Dext.Scaffolding.Models,
  Dext.Templating;

type
  TGenerationMode = (gmSingleFile, gmMultipleFiles);

  TTemplatedEntityGenerator = class
  private
    FEngine: ITemplateEngine;
    function CleanName(const AName: string): string;
    function SQLTypeToDelphiType(const ASQLType: string; AScale: Integer): string;
    function CreateTableViewModel(const AMeta: TMetaTable): TTableViewModel;
  public
    constructor Create;
    procedure Generate(const ASchema: ISchemaProvider; const ATemplatePath, AOutputDir: string; AMode: TGenerationMode = gmMultipleFiles);
  end;

implementation

uses
  Dext.Utils;

{ TTemplatedEntityGenerator }

constructor TTemplatedEntityGenerator.Create;
begin
  FEngine := TTemplating.CreateEngine;
end;

function TTemplatedEntityGenerator.CleanName(const AName: string): string;
var
  Parts: TArray<string>;
  S, Cleaned: string;
begin
  Result := '';
  Cleaned := AName.Replace('"', '').Replace('''', '').Replace('[', '').Replace(']', '');
  
  if Cleaned.Contains('.') then
  begin
    Parts := Cleaned.Split(['.']);
    Cleaned := Parts[High(Parts)];
  end;
  
  Parts := Cleaned.Split(['_', '-', ' '], TStringSplitOptions.ExcludeEmpty);
  for S in Parts do
    if S.Length > 0 then
      Result := Result + UpperCase(S.Chars[0]) + S.Substring(1).ToLower;
end;

function TTemplatedEntityGenerator.SQLTypeToDelphiType(const ASQLType: string; AScale: Integer): string;
var
  S: string;
begin
  S := ASQLType.ToUpper;
  if S.Contains('INT') then Result := 'Integer'
  else if S.Contains('BIGINT') then Result := 'Int64'
  else if S.Contains('SMALLINT') or S.Contains('TINYINT') then Result := 'Integer'
  else if S.Contains('CHAR') or S.Contains('TEXT') or S.Contains('CLOB') then Result := 'string'
  else if S.Contains('BOOL') or S.Contains('BIT') then Result := 'Boolean'
  else if S.Contains('DATE') or S.Contains('TIME') then Result := 'TDateTime'
  else if S.Contains('FLOAT') or S.Contains('DOUBLE') or S.Contains('REAL') then Result := 'Double'
  else if S.Contains('DECIMAL') or S.Contains('NUMERIC') or S.Contains('MONEY') then 
  begin
    if AScale = 0 then Result := 'Int64' else Result := 'Currency'; 
  end
  else if S.Contains('BLOB') or S.Contains('BINARY') or S.Contains('IMAGE') or S.Contains('VARBINARY') then Result := 'TBytes'
  else if S.Contains('GUID') or S.Contains('UUID') then Result := 'TGUID'
  else Result := 'string';
end;

function TTemplatedEntityGenerator.CreateTableViewModel(const AMeta: TMetaTable): TTableViewModel;
begin
  Result := TTableViewModel.Create;
  Result.Name := AMeta.Name;
  Result.DelphiClassName := 'T' + CleanName(AMeta.Name);
  
  for var MetaCol in AMeta.Columns do
  begin
    var Col := TColumnViewModel.Create;
    Col.Name := MetaCol.Name;
    Col.DelphiName := CleanName(MetaCol.Name);
    Col.DataType := MetaCol.DataType;
    Col.DelphiType := SQLTypeToDelphiType(MetaCol.DataType, MetaCol.Scale);
    Col.IsPrimaryKey := MetaCol.IsPrimaryKey;
    Col.IsAutoInc := MetaCol.IsAutoInc;
    Col.IsNullable := MetaCol.IsNullable;
    Col.Length := MetaCol.Length;
    Col.Precision := MetaCol.Precision;
    Col.Scale := MetaCol.Scale;
    Result.Columns.Add(Col);
  end;
  
  for var MetaFK in AMeta.ForeignKeys do
  begin
    var FK := TFKViewModel.Create;
    FK.Name := MetaFK.Name;
    FK.ColumnName := MetaFK.ColumnName;
    FK.ReferencedTable := MetaFK.ReferencedTable;
    FK.ReferencedClass := 'T' + CleanName(MetaFK.ReferencedTable);
    
    var NavProp := CleanName(MetaFK.ColumnName);
    if NavProp.EndsWith('Id', True) then
       NavProp := NavProp.Substring(0, NavProp.Length - 2);
    if (NavProp = '') or SameText(NavProp, 'Id') then
       NavProp := CleanName(MetaFK.ReferencedTable);
       
    FK.PropertyName := NavProp;
    Result.ForeignKeys.Add(FK);
  end;
end;

procedure TTemplatedEntityGenerator.Generate(const ASchema: ISchemaProvider; const ATemplatePath, AOutputDir: string; AMode: TGenerationMode);
var
  Tables: TArray<string>;
  TemplateContent: string;
  OutputContent: string;
  RootModel: TScaffoldViewModel;
  Context: ITemplateContext;
begin
  if not TFile.Exists(ATemplatePath) then
    raise Exception.Create('Template not found: ' + ATemplatePath);
    
  TemplateContent := TFile.ReadAllText(ATemplatePath);
  Tables := ASchema.GetTables;
  
  ForceDirectories(AOutputDir);
  
  if AMode = gmMultipleFiles then
  begin
    for var TableName in Tables do
    begin
      var TableMeta := ASchema.GetTableMetadata(TableName);
      var TableModel := CreateTableViewModel(TableMeta);
      try
        Context := TTemplating.CreateContext;
        Context.SetObject('Model', TableModel);
        
        OutputContent := FEngine.Render(TemplateContent, Context);
        var FileName := TPath.Combine(AOutputDir, CleanName(TableName) + '.pas');
        TFile.WriteAllText(FileName, OutputContent);
      finally
        TableModel.Free;
      end;
    end;
  end
  else
  begin
    RootModel := TScaffoldViewModel.Create;
    try
      for var TableName in Tables do
        RootModel.Tables.Add(CreateTableViewModel(ASchema.GetTableMetadata(TableName)));
        
      Context := TTemplating.CreateContext;
      Context.SetObject('Model', RootModel);
      
      OutputContent := FEngine.Render(TemplateContent, Context);
      var FileName := TPath.Combine(AOutputDir, 'Entities.pas');
      TFile.WriteAllText(FileName, OutputContent);
    finally
      RootModel.Free;
    end;
  end;
end;

end.
