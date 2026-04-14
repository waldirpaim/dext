unit Dext.CLI.App;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  System.Types,
  System.StrUtils,
  FireDAC.Comp.Client,
  Dext.Templating,
  Dext.Entity.Drivers.Interfaces,
  Dext.Entity.Drivers.FireDAC,
  Dext.Entity.Scaffolding,
  Dext.Entity.TemplatedScaffolding;

type
  IConsoleCommand = interface
    ['{B1B2C3D4-E5F6-4789-0123-456789ABCDEF}']
    function GetName: string;
    function GetVerb: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TDextCLI = class
  private
    FCommands: TList<IConsoleCommand>;
    function FindCommand(const AVerb, AName: string): IConsoleCommand;
    procedure RegisterCommands;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ShowHelp;
    function Run: Boolean;
  end;

  TScaffoldModel = class
  private
    FEntityName: string;
    FTableName: string;
  public
    property EntityName: string read FEntityName write FEntityName;
    property TableName: string read FTableName write FTableName;
  end;

  // --- Commands ---

  TAddEntityCommand = class(TInterfacedObject, IConsoleCommand)
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

  TScaffoldDbCommand = class(TInterfacedObject, IConsoleCommand)
  private
    function GetArg(const Args: TArray<string>; const Name, ShortName: string; const Default: string = ''): string;
    function ResolveTemplatePath(const ATemplateName: string): string;
  public
    function GetVerb: string;
    function GetName: string;
    function GetDescription: string;
    procedure Execute(const Args: TArray<string>);
  end;

implementation

{ TDextCLI }

constructor TDextCLI.Create;
begin
  FCommands := TList<IConsoleCommand>.Create;
  RegisterCommands;
end;

destructor TDextCLI.Destroy;
begin
  FCommands.Free;
  inherited;
end;

function TDextCLI.FindCommand(const AVerb, AName: string): IConsoleCommand;
begin
  Result := nil;
  for var Cmd in FCommands do
  begin
    if SameText(Cmd.GetVerb, AVerb) and SameText(Cmd.GetName, AName) then
      Exit(Cmd);
  end;
end;

procedure TDextCLI.RegisterCommands;
begin
  FCommands.Add(TAddEntityCommand.Create);
  FCommands.Add(TScaffoldDbCommand.Create);
end;

procedure TDextCLI.ShowHelp;
begin
  var Exe := ExtractFileName(ParamStr(0));
  WriteLn('Dext Framework CLI');
  WriteLn('------------------');
  WriteLn('Usage: ' + Exe + ' <verb> <command> [args]');
  WriteLn('');
  WriteLn('Available Commands:');
  for var Cmd in FCommands do
  begin
    var FullCmd := Cmd.GetVerb + ' ' + Cmd.GetName;
    WriteLn('  ' + FullCmd.PadRight(25) + Cmd.GetDescription);
  end;
  WriteLn('');
end;

function TDextCLI.Run: Boolean;
var
  Verb, Name: string;
  Args: TArray<string>;
  Cmd: IConsoleCommand;
begin
  if ParamCount < 2 then
    Exit(False);

  Verb := ParamStr(1).ToLower;
  Name := ParamStr(2).ToLower;
  
  Cmd := FindCommand(Verb, Name);
  if Assigned(Cmd) then
  begin
    SetLength(Args, ParamCount - 2);
    for var i := 3 to ParamCount do
      Args[i - 3] := ParamStr(i);
      
    Cmd.Execute(Args);
    Result := True;
  end
  else
  begin
    WriteLn('Unknown command: ' + Verb + ' ' + Name);
    ShowHelp;
    Result := True;
  end;
end;

{ TAddEntityCommand }

function TAddEntityCommand.GetDescription: string;
begin
  Result := 'Adds a new entity class using a template';
end;

function TAddEntityCommand.GetName: string;
begin
  Result := 'entity';
end;

function TAddEntityCommand.GetVerb: string;
begin
  Result := 'add';
end;

function ResolveTemplate(const ATemplateName: string): string;
begin
  // 1. Local path: .\Templates
  Result := TPath.Combine(TPath.Combine(GetCurrentDir, 'Templates'), ATemplateName);
  if TFile.Exists(Result) then Exit;
  
  // 2. User path: %USERPROFILE%\.dext\Templates
  var HomeDir := TPath.GetHomePath;
  Result := TPath.Combine(TPath.Combine(HomeDir, '.dext'), TPath.Combine('Templates', ATemplateName));
  if TFile.Exists(Result) then Exit;
  
  // 3. Framework path: $(DEXT)\Templates
  var DextRoot := GetEnvironmentVariable('DEXT');
  if DextRoot <> '' then
  begin
    Result := TPath.Combine(TPath.Combine(DextRoot, 'Templates'), ATemplateName);
    if TFile.Exists(Result) then Exit;
  end;
  
  // 4. Default fallback (relative to EXE for local dev)
  Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\Templates\Basic\' + ATemplateName));
  if not TFile.Exists(Result) then
    Result := '';
end;

procedure TAddEntityCommand.Execute(const Args: TArray<string>);
var
  EntityName, TableName: string;
  TemplatePath: string;
  TemplateContent: string;
  Engine: ITemplateEngine;
  Context: ITemplateContext;
  Output: string;
  OutputFile: string;
begin
  if Length(Args) = 0 then
  begin
    WriteLn('Usage: dext add entity <EntityName> [TableName]');
    Exit;
  end;

  EntityName := Args[0];
  if Length(Args) > 1 then
    TableName := Args[1]
  else
    TableName := EntityName.ToLower + 's';

  // Heuristic for template location (3-level lookup)
  TemplatePath := ResolveTemplate('entity.pas.template');

  if TemplatePath = '' then
  begin
    WriteLn('Error: Template entity.pas.template not found in any search path.');
    WriteLn('Search paths: ./Templates, ~/.dext/Templates, $(DEXT)/Templates');
    Exit;
  end;

  WriteLn('Using template: ' + TemplatePath);
  WriteLn('Generating entity ' + EntityName + '...');
  
  TemplateContent := TFile.ReadAllText(TemplatePath);
  Engine := TTemplating.CreateEngine;
  Context := TTemplating.CreateContext;

  var ModelObj := TScaffoldModel.Create;
  ModelObj.EntityName := EntityName;
  ModelObj.TableName := TableName;
  
  Context.SetObject('Model', ModelObj); 

  Output := Engine.Render(TemplateContent, Context);
  
  OutputFile := EntityName + '.pas';
  TFile.WriteAllText(OutputFile, Output);
  
  WriteLn('File generated successfully: ' + OutputFile);
  ModelObj.Free;
end;

{ TScaffoldDbCommand }

function TScaffoldDbCommand.ResolveTemplatePath(const ATemplateName: string): string;
begin
  Result := ResolveTemplate(ATemplateName);
end;

function TScaffoldDbCommand.GetArg(const Args: TArray<string>; const Name, ShortName: string; const Default: string): string;
begin
  Result := Default;
  for var i := 0 to High(Args) - 1 do
  begin
    if SameText(Args[i], Name) or SameText(Args[i], ShortName) then
      Exit(Args[i + 1]);
  end;
end;

function TScaffoldDbCommand.GetDescription: string;
begin
  Result := 'Generates entity classes from an existing database';
end;

function TScaffoldDbCommand.GetName: string;
begin
  Result := 'db';
end;

function TScaffoldDbCommand.GetVerb: string;
begin
  Result := 'scaffold';
end;

procedure TScaffoldDbCommand.Execute(const Args: TArray<string>);
var
  ConnStr, OutDir, TemplatePath: string;
  Connection: IDbConnection;
  Provider: ISchemaProvider;
  Generator: TTemplatedEntityGenerator;
begin
  ConnStr := GetArg(Args, '--connection', '-c');
  OutDir := GetArg(Args, '--output', '-o', 'Generated');
  var UserTemplate := GetArg(Args, '--template', '-t');
  if UserTemplate <> '' then
    TemplatePath := UserTemplate
  else
    TemplatePath := ResolveTemplatePath('entity.pas.template');

  if TemplatePath = '' then
  begin
    WriteLn('Error: Template entity.pas.template not found.');
    Exit;
  end;

  WriteLn('Connecting to database...');
  try
    var FDConn := TFDConnection.Create(nil);
    FDConn.ConnectionString := ConnStr;
    Connection := TFireDACConnection.Create(FDConn);
    try
      Provider := TFireDACSchemaProvider.Create(Connection);
      Generator := TTemplatedEntityGenerator.Create;
      try
        WriteLn('Scanning schema and generating code...');
        Generator.Generate(Provider, TemplatePath, OutDir, gmMultipleFiles);
        WriteLn('Successfully generated entities in: ' + OutDir);
      finally
        Generator.Free;
      end;
    finally
      // Connection is interface, will be freed
    end;
  except
    on E: Exception do
      WriteLn('Error: ' + E.Message);
  end;
end;

end.
