# 6. Database as API

Generate REST APIs automatically from your entities - zero code required.

> 📦 **Example**: [Web.DatabaseAsApi](../../../Examples/Web.DatabaseAsApi/)

## Quick Start

```pascal
type
  [DataApi] // Auto-registers as /api/products
  [Table('products')]
  TProduct = class
  private
    FId: Integer;
    FName: string;
    FPrice: Double;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Price: Double read FPrice write FPrice;
  end;

// In the configuration pipeline (Global):
App.MapDataApis; 
```

### Registration Methods

Dext offers full flexibility to expose your data, supporting three approaches that can coexist:

1.  **Automatic (Attribute)**: Simply add `[DataApi]` to the class and call `App.MapDataApis` at startup.
2.  **Manual by type**: `TDataApiHandler<TProduct>.Map(App, '/api/products')`.
3.  **Manual Fluent**:
    ```pascal
    App.Builder.MapDataApi<TProduct>('/api/products', DataApiOptions
      .AllowRead
      .RequireAuth
    );
    ```

## Conventions and Smart Mapping

The Data API follows modern conventions to minimize configuration:

-   **Naming**: By default, the `T` prefix is removed and the class name is pluralized (e.g., `TCustomer` -> `/api/customers`).
-   **Custom Routes**: Use `[DataApi('/my/custom/path')]` to override the convention.
-   **Property Case Mapping**: PascalCase properties in Delphi are automatically mapped to snake_case in the URL (e.g., `PriceValue` -> `?price_value_gt=100`).

## Generated Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/api/products` | List all (with pagination) |
| GET | `/api/products/{id}` | Get by ID |
| POST | `/api/products` | Create new |
| PUT | `/api/products/{id}` | Update |
| DELETE | `/api/products/{id}` | Delete |

## Features

- **Automatic Pagination**: `?_limit=20&_offset=40`
- **Sorting**: `?_orderby=price desc,name asc`
- **Dynamic Specification (Filtering)**: Smart mapping via QueryString:

### Filter Operators

| Suffix | SQL Operator | Example | Description |
|--------|--------------|---------|-------------|
| `_eq`  | `=`          | `?status_eq=1` | Equal to (default) |
| `_neq` | `<>`         | `?type_neq=2` | Not equal to |
| `_gt`  | `>`          | `?price_gt=50` | Greater than |
| `_gte` | `>=`         | `?age_gte=18` | Greater or equal |
| `_lt`  | `<`          | `?stock_lt=5` | Less than |
| `_lte` | `<=`         | `?date_lte=2025-01-01` | Less or equal |
| `_cont`| `LIKE %x%`   | `?name_cont=Dext` | Contains |
| `_sw`  | `LIKE x%`    | `?code_sw=ABC` | Starts with |
| `_ew`  | `LIKE %x`    | `?mail_ew=gmail.com` | Ends with |
| `_in`  | `IN (...)`   | `?cat_in=1,2,5` | List of values |
| `_null`| `IS NULL`     | `?addr_null=true` | Check for null value |

## Performance: Zero-Allocation Streaming

A key differentiator of Dext's Data API is its **high-performance JSON engine**. Unlike traditional approaches that load all data into memory and then serialize it to strings, Dext uses a **streaming approach**:

1.  **Direct Streaming**: It uses `TUtf8JsonWriter` to write data directly into the response stream.
2.  **Binary Integration**: It reads values straight from the database driver and writes them to the wire without intermediate string allocations for large data sets.
3.  **Low Memory Footprint**: This architecture allows serving large datasets with minimal memory impact, crucial for high-traffic environments.

---

## Security Policies

You can restrict access by operation or by role:

```pascal
App.Builder.MapDataApi<TProduct>('/api/products', DataApiOptions
  .RequireAuth
  .RequireRole('Admin')
  .Allow([amGet, amGetList]) // Read-only access
);
```


## With Security

```pascal
TDataApiHandler<TProduct>.Map(App, '/api/products',
  TDataApiOptions.Create
    .AllowRead
    .AllowCreate
    .DenyDelete  // No DELETE allowed
    .RequireAuth // Require authentication
);
```

## Diagnostics and Observability

To ease the debugging of automatically generated APIs, the Data API integrates with Dext's logging system.

### Enabling Debug Logs

If you encounter unexpected behavior (such as filters not working or database errors), you can enable the `Debug` log level in your startup:

```pascal
App.Configure(procedure(App: IApplicationBuilder)
  begin
    // Set minimum level to Debug to see DataAPI details
    TDextServices.GetService<ILoggerFactory>(App.Services)
      .SetMinimumLevel(TLogLevel.Debug);
  end);
```

**What will be logged in Debug mode:**
- Incoming requests with raw QueryString parameters.
- Property mapping and applied filters.
- Detailed exceptions with stack traces (if configured).

---

[← ORM](../05-orm/README.md) | [Next: Real-Time →](../07-real-time/README.md)
