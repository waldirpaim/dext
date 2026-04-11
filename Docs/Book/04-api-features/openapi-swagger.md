# OpenAPI / Swagger

OpenAPI (formerly Swagger) is the industry standard for documenting REST APIs. Dext provides built-in support for generating OpenAPI 3.0 specifications and serving an interactive Swagger UI.

## Basic Setup

To enable Swagger UI, call `UseSwagger` in your application builder.

```pascal
var
  Options: TOpenAPIOptions;
begin
  Options := TOpenAPIOptions.Default;
  Options.Title := 'My Dext API';
  Options.Version := '1.0.0';

  App.UseSwagger(Options);
end;
```

Once running, you can access:
- **Swagger UI**: `http://localhost:8080/swagger`
- **OpenAPI JSON**: `http://localhost:8080/swagger.json`

## Documenting Endpoints

### 1. Minimal APIs (Fluent DSL)

Use `SwaggerEndpoint.From` to add metadata to your routes:

```pascal
uses
  Dext.OpenAPI.Fluent;

SwaggerEndpoint.From(App.MapGet('/api/users', GetUsers))
  .Summary('List all users')
  .Description('Retrieves a complete list of users from the database')
  .Tag('Identity')
  .Response(200, TypeInfo(TUserArray), 'Success');
```

### 2. Controllers (Attributes)

Attributes allow you to document your API directly on the controller class:

```pascal
[DextController('/api/products')]
[SwaggerTag('Catalog')]
TProductsController = class
public
  [DextGet('{id}')]
  [SwaggerOperation('Get Product', 'Returns details of a single product')]
  [SwaggerResponse(200, 'Product found')]
  [SwaggerResponse(404, 'Product not found')]
  function GetById(Id: Integer): IResult;
end;
```

## Security Documentation

Document your authentication requirements so they appear in Swagger with the "Authorize" button:

```pascal
Options.WithBearerAuth; // Adds JWT Bearer support to the spec

// On an endpoint:
SwaggerEndpoint.From(App.MapPost('/api/admin', ...))
  .RequireAuthorization;
```

## Advanced Features

- **Schema Generation**: Dext uses RTTI to automatically generate JSON schemas for your Request and Response types.
- **Custom Paths**: You can change the default `/swagger` path in the options.
- **Multiple Tags**: Group endpoints to keep your documentation organized.

---

[← Middleware](middleware.md) | [Next: Rate Limiting →](rate-limiting.md)
