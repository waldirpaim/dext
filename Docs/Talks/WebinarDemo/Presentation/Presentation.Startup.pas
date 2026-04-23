unit Presentation.Startup;

interface

uses
  Dext,
  Dext.Web,
  Dext.Web.Interfaces,
  Dext.Web.DataApi,
  Dext.DI.Interfaces,
  Dext.Entity,
  Dext.Swagger.Middleware,
  Dext.OpenAPI.Generator,
  
  // Logging & Telemetry
  Dext.Logging,
  Dext.Logging.Extensions,
  Dext.Logging.Console,
  
  // Demo Project Units
  Domain.Entities,
  Domain.Interfaces,
  Infra.Context,
  Infra.Services;

type
  TStartup = class(TInterfacedObject, IStartup)
  public
    procedure ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
    procedure Configure(const App: IWebApplication);
  end;

implementation

{ TStartup }

procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  // 1. Configure Logging and Telemetry (Act 3)
  Services.AddLogging(
    procedure(Builder: ILoggingBuilder)
    begin
        Builder
          .SetMinimumLevel(TLogLevel.Debug)
          .AddConsole
          .AddTelemetry; // Captures HTTP and SQL metrics automatically
    end);

  // 2. Configure ORM & Database
  Services.AddDbContext<TAppDbContext>(
    procedure(Options: TDbContextOptions)
    begin
      Options.UseSQLite('webinar_demo.db');
      Options.Pooling := True;
    end);

  // 3. Register Domain Services for DI
  Services.AddScoped<IProductService, TProductService>;
end;

procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder
    .UseDeveloperExceptionPage()
    
    // The "Wow" Moment (Act 1): One line generates full CRUD API for TProduct
    .MapDataApis(
      DataApiOptions
        .DbContext<TAppDbContext>
        .UseSnakeCase
        .UseSwagger)
        
    // Add Swagger UI
    .UseSwagger(
      Swagger
        .Title('Dext Webinar Demo API')
        .Description('Auto-generated from [DataApi] attribute.')
        .Version('1.0.0')
    );
end;

end.
