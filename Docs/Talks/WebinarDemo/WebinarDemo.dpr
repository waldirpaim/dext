program WebinarDemo;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  Dext.Utils,
  System.SysUtils,
  Dext.Web,
  Dext.Web.Interfaces,
  Dext.DI.Interfaces,
  Domain.Entities in 'Domain\Domain.Entities.pas',
  Domain.Interfaces in 'Domain\Domain.Interfaces.pas',
  Infra.Context in 'Infrastructure\Infra.Context.pas',
  Infra.Services in 'Infrastructure\Infra.Services.pas',
  Presentation.Startup in 'Presentation\Presentation.Startup.pas';

procedure SeedDatabase(const Provider: IServiceProvider);
var
  Scope: IServiceScope;
  Db: TAppDbContext;
  Product: TProduct;
begin
  Scope := Provider.CreateScope;
  try
    Db := Scope.ServiceProvider.GetService(TAppDbContext) as TAppDbContext;
    if Assigned(Db) then
    begin
      Db.EnsureCreated;

      if Db.Products.Count = 0 then
      begin
        Writeln('Seeding sample data...');
        
        Product := TProduct.Create;
        Product.Name := 'Dext Framework License';
        Product.Description := 'Open Source Apache 2.0';
        Product.Price := 0.00;
        Product.Stock := 9999;
        Product.IsActive := True;
        Product.CreatedAt := Now;
        Db.Products.Add(Product);

        Product := TProduct.Create;
        Product.Name := 'Delphi 12 Athens';
        Product.Description := 'Enterprise Edition';
        Product.Price := 2999.00;
        Product.Stock := 10;
        Product.IsActive := True;
        Product.CreatedAt := Now;
        Db.Products.Add(Product);

        Db.SaveChanges;
        Writeln('Seed complete.');
      end;
    end;
  finally
    Scope := nil;
  end;
end;

var
  App: IWebApplication;
  Provider: IServiceProvider;
begin
  SetConsoleCharSet;
  try
    Writeln('Dext Webinar Demo - Embarcadero 2026');
    Writeln('====================================');
    Writeln('');
    
    App := WebApplication;
    App.UseStartup(TStartup.Create);
    
    Provider := App.BuildServices;
    if Provider <> nil then
      SeedDatabase(Provider);
    
    Writeln('Server listening on http://localhost:5000');
    Writeln('Open http://localhost:5000/swagger to test the DataApi');
    
    App.Run(5000);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  
  App := nil;
  Provider := nil;
end.
