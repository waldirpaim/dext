# Smart Properties

Type-safe query expressions using `Prop<T>`. This allows you to write queries that are checked at compile time, eliminating "magic strings".

> 📦 **Example**: [Web.SmartPropsDemo](../../../Examples/Web.SmartPropsDemo/)

## Type Aliases

For cleaner entity definitions, use the following aliases from `Dext.Core.SmartTypes`:

| Type | Delphi Equivalent |
|------|-------------------|
| `StringType` | `string` |
| `IntType` | `Integer` |
| `Int64Type` | `Int64` |
| `BoolType` | `Boolean` |
| `DateTimeType` | `TDateTime` |
| `CurrencyType` | `Currency` |

```pascal
type
  [Table('products')]
  TProduct = class
  private
    FName: StringType; // Smart Property
    FPrice: CurrencyType;
  public
    [Column('name')]
    property Name: StringType read FName write FName;
    [Column('price')]
    property Price: CurrencyType read FPrice write FPrice;
  end;
```

## Usage Patterns

There are two main ways to use Smart Properties in queries:

### 1. The "Member Props" Pattern (Cleanest)

Define a static property `Props` in your class.

```pascal
type
  TProduct = class
  public
    class var Props: record
      Name: StringType;
      Price: CurrencyType;
    end;
  end;

// Usage:
var p := TProduct.Props;
var CheapProducts := Context.Products
  .Where(p.Price < 10)
  .ToList;
```

### 2. The "Phantom Entity" Pattern (No changes to class)

If you don't want to add a `Props` field to your class, use `Prototype.Entity<T>`.

```pascal
uses Dext.Entity.Prototype;

var p := Prototype.Entity<TProduct>;
var CheapProducts := Context.Products
  .Where(p.Price < 10)
  .ToList;
```

## Supported Operations

### Comparisons
- `=`, `<>`, `>`, `>=`, `<`, `<=`
- `In([V1, V2])`, `NotIn([V1, V2])`
- `IsNull`, `IsNotNull`

### String Logic
- `Contains('text')`
- `StartsWith('text')`
- `EndsWith('text')`
- `Like('%text%')`

### Boolean Logic
```pascal
var u := TUser.Props;
Context.Users.Where((u.Age > 18) and (u.IsActive = True)).ToList;
```

## Why use Smart Properties?

1. **Refactoring Safety**: If you rename a property in the class, the compiler will catch all query errors.
2. **Readability**: Code looks closer to SQL yet remains 100% Pascal.
3. **IDE Support**: Code completion works for all available fields in the query.

---

[← Querying](querying.md) | [Next: Specifications →](specifications.md)
