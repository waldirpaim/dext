# Middleware

Middleware is a piece of code that handles requests and responses. It sits in the middle of the request pipeline.

## Pipeline Concept

Dext uses a pipeline of middleware components to handle HTTP requests. Each component:
1. Receives the `IHttpContext`.
2. Can perform logic before passing the request to the next middleware.
3. Calls the `Next` delegate to continue the pipeline.
4. Can perform logic after the rest of the pipeline has finished (on the way back).

## Creating Middleware

### 1. Class-Based Middleware

Implement the `IMiddleware` interface:

```pascal
uses
  Dext.Web.Interfaces;

type
  TMyMiddleware = class(TInterfacedObject, IMiddleware)
  public
    procedure Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
  end;

procedure TMyMiddleware.Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
begin
  // Logic BEFORE the rest of the pipeline
  WriteLn('Request starting: ', AContext.Request.Path);

  // Call the next middleware in the chain
  ANext(AContext);

  // Logic AFTER the rest of the pipeline
  WriteLn('Request finished with status: ', AContext.Response.StatusCode);
end;
```

### 2. Functional Middleware

You can also use anonymous procedures for simple logic:

```pascal
App.Use(procedure(Ctx: IHttpContext; Next: TRequestDelegate)
  begin
    Ctx.Response.AddHeader('X-Custom', 'Dext');
    Next(Ctx);
  end);
```

## Registering Middleware

In your `Startup.Configure` or directly on the `App` object:

```pascal
// Class-based
App.UseMiddleware(TMyMiddleware);

// Functional
App.Use(MyMiddlewareFunc);
```

## Built-in Middleware

Dext comes with several pre-configured middleware components:

- `App.UseRouting`: Handles endpoint matching.
- `App.UseStaticFiles`: Serves files from the `wwwroot` folder.
- `App.UseAuthentication`: Handles `User` identity population.
- `App.UseCors`: Handles cross-origin requests.
- `App.UseSwagger`: Generates OpenAPI documentation.

## Short-Circuiting

A middleware can stop the pipeline by **NOT** calling `ANext(AContext)`. This is useful for security checks or immediate responses.

```pascal
procedure TAuthMiddleware.Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
begin
  if not IsAuthenticated(AContext) then
  begin
    AContext.Response.Status(401).Write('Unauthorized');
    Exit; // 🛑 Pipeline stops here
  end;

  ANext(AContext); // ✅ Continue pipeline
end;
```

---

[← OpenAPI / Swagger](openapi-swagger.md) | [Next: Action Filters →](filters.md)
