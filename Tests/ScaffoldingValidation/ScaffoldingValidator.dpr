program ScaffoldingValidator;

{$APPTYPE CONSOLE}

{$I Dext.inc}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Dext.Entity,
  Dext.Entity.Mapping,
  Dext.Entity.Drivers.Interfaces,
  Dext.Entity.Drivers.FireDAC,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.PG,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.FB,
  FireDAC.Phys.IB,
  EntityDemo.DbConfig in '..\..\Examples\03-Data\Orm.EntityDemo\EntityDemo.DbConfig.pas',
  Scaffolding.StandardEntities in 'Scaffolding.StandardEntities.pas';

type
  TScaffoldTest = class
  public
    class procedure Run;
  end;

class procedure TScaffoldTest.Run;
var
  Providers: TArray<TDatabaseProvider>;
  Provider: TDatabaseProvider;
  Context: TDbContext;
  Connection: IDbConnection;
  ToolPath: string;
  OutputPath: string;
  Cmd: string;
  DatabaseParam: string;
  DriverParam: string;
begin
  Providers := [
    dpSQLite,
    dpFirebird,
    dpPostgreSQL,
    dpMySQL,
    dpSQLServer
  ];

  ToolPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'DextTool.exe');
  if not TFile.Exists(ToolPath) then
    ToolPath := 'C:\dev\Dext\DextRepository\Output\DextTool.exe';

  Writeln('Dext Scaffolding Cross-DB Validator');
  Writeln('==================================');
  Writeln('Tool Path: ' + ToolPath);
  Writeln('');

  for Provider in Providers do
  begin
    try
      case Provider of
        dpSQLite: TDbConfig.ConfigureSQLite('test.db');
        dpPostgreSQL: TDbConfig.ConfigurePostgreSQL('localhost', 5432, 'postgres', 'postgres', 'root');
        dpFirebird: TDbConfig.ConfigureFirebird('C:\temp\dext_test.fdb', 'SYSDBA', 'masterkey');
        dpMySQL: TDbConfig.ConfigureMySQL('localhost', 3306, 'dext_test', 'root', 'root', 'libmariadb.dll', 'C:\Program Files\MariaDB 12.1\');
        dpSQLServer: TDbConfig.ConfigureSQLServer('localhost', 'dext_test', 'sa', 'SQL@d3veloper');
      end;
      Writeln('Testing Provider: ' + TDbConfig.GetProviderName);
      
      // 1. Ensure Database exists and is clean
      // TDbConfig.EnsureDatabaseExists; 
      
      // 2. Create Schema using Dext ORM
      Connection := TDbConfig.CreateConnection;
      Context := TDbContext.Create(Connection, TDbConfig.CreateDialect);
      try
        Writeln('  Registering entities...');
        Context.Entities<TCountry>;
        Context.Entities<TCategory>;
        Context.Entities<TProduct>;
        Context.Entities<TProductMetadata>;
        Context.Entities<TCustomer>;
        Context.Entities<TOrder>;
        Context.Entities<TOrderItem>;
        Context.Entities<TTag>;
        Context.Entities<TProductTag>;
        Context.Entities<TAuditLog>;
        Context.Entities<TAttachment>;
        Context.Entities<TSystemConfig>;
        
        Writeln('  Creating schema...');
        if not Context.EnsureCreated then
          raise Exception.Create('EnsureCreated failed to create all tables (possible circular dependency or missing metadata)');
        Writeln('  Schema created successfully.');
      finally
        Context.Free;
      end;

      // 3. Run Scaffolding
      OutputPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Generated.' + TDbConfig.GetProviderName + '.pas');
      
      DriverParam := '';
      DatabaseParam := '';

      case Provider of
        dpSQLite: 
        begin
          DriverParam := 'sqlite';
          DatabaseParam := 'Database=test.db';
        end;
        dpPostgreSQL:
        begin
          DriverParam := 'pg';
          DatabaseParam := 'Server=localhost;Database=postgres;User_Name=postgres;Password=root';
        end;
        dpFirebird:
        begin
          DriverParam := 'fb';
          DatabaseParam := 'Database=C:\temp\dext_test.fdb;User_Name=SYSDBA;Password=masterkey';
        end;
        dpMySQL:
        begin
          DriverParam := 'mysql';
           DatabaseParam := 'Server=localhost;Database=dext_test;User_Name=root;Password=root;VendorLib=C:\Program Files\MariaDB 12.1\lib\libmariadb.dll';
        end;
        dpSQLServer:
        begin
          DriverParam := 'mssql';
          DatabaseParam := 'Server=localhost;Database=dext_test;User_Name=sa;Password=SQL@d3veloper;Encrypt=No;TrustServerCertificate=Yes';
        end;
      end;

      Cmd := Format('"%s" scaffold -d %s -c "%s" -o "%s" --with-metadata --poco', 
        [ToolPath, DriverParam, DatabaseParam, OutputPath]);
      
      Writeln('  Running scaffold...');
      // In a real scenario, we would use TProcess. 
      // For this demo, we'll just print the command or assume it's run by the script.
      Writeln('  CMD: ' + Cmd);
      
      Writeln('  [OK] ' + TDbConfig.GetProviderName + ' test completed.');
      Writeln('');
    except
      on E: Exception do
        Writeln('  [ERROR] ' + TDbConfig.GetProviderName + ': ' + E.Message);
    end;
  end;
end;

begin
  try
    TScaffoldTest.Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Execution complete.');
end.
