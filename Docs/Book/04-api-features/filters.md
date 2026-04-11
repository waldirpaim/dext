# Action Filters

Action Filters in Dext allow you to execute code before and after the execution of a controller action, in a declarative way using attributes.

## Concept

Action Filters are interceptors that execute logic at specific points in the action execution pipeline:

1. **OnActionExecuting**: Runs before the action method is executed.
2. **OnActionExecuted**: Runs after the action method executes (even if an exception occurs).

```pascal
[LogAction]  // ← Filter executed automatically
[DextGet('/users')]
function GetUsers: IResult;
```

## Built-in Filters

Dext includes several ready-to-use filters:

### 1. `[LogAction]`
Automatically logs the execution time and result of the action to the console/logger.

### 2. `[RequireHeader]`
Validates that a specific header is present in the request.

```pascal
[RequireHeader('X-API-Key', 'API Key is required')]
[DextPost('/api/data')]
function PostData: IResult;
```

### 3. `[ResponseCache]`
Adds HTTP cache headers (Cache-Control) to the response.

```pascal
[ResponseCache(60, 'public')]  // Cache for 60 seconds
```

## Creating Custom Filters

To create a custom filter, inherit from `ActionFilterAttribute` and override the desired methods.

```pascal
type
  RequireAdminAttribute = class(ActionFilterAttribute)
  public
    procedure OnActionExecuting(AContext: IActionExecutingContext); override;
  end;

procedure RequireAdminAttribute.OnActionExecuting(AContext: IActionExecutingContext);
begin
  if (AContext.HttpContext.User = nil) or 
     (not AContext.HttpContext.User.IsInRole('Admin')) then
  begin
    // Short-circuit: setting AContext.Result prevents the action from running
    AContext.Result := Results.StatusCode(403, '{"error":"Admin access required"}');
  end;
end;
```

## Execution Order

When multiple filters are applied, they execute in the order they are declared:

1. `FilterA.OnActionExecuting`
2. `FilterB.OnActionExecuting`
3. **Action executes**
4. `FilterB.OnActionExecuted` (reverse order)
5. `FilterA.OnActionExecuted`

### Controller vs. Method Filters

Filters applied to the **Controller** class execute before filters applied to the **Method**.

```pascal
[LogAction] // 1st
TUserController = class
public
  [ResponseCache(60)] // 2nd
  function GetUsers: IResult;
end;
```

## Short-Circuiting

You can prevent an action from executing by setting the `Result` property in `OnActionExecuting`.

```pascal
procedure TMyFilter.OnActionExecuting(AContext: IActionExecutingContext);
begin
  if SomeFailure then
    AContext.Result := Results.BadRequest('Failed');
end;
```

---

[← Middleware](middleware.md) | [Next: Rate Limiting →](rate-limiting.md)
