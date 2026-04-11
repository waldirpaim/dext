# ORM Mapping Attributes

Dext ORM provides a set of attributes to explicitly configure how your entities map to the database. In addition to standard mapping attributes like `[Table]`, `[Column]`, and `[PK]`, Dext now supports explicit database type definition and custom type converters.

## DbTypeAttribute

The `[DbType]` attribute allows you to explicitly specify the database column type for a property. This is useful when the default type inference (based on the Delphi property type) does not match your specific database schema requirements.

### Usage

```pascal
uses
  Dext.Entity.Attributes;

type
  [Table('Products')]
  TProduct = class
  private
    FDescription: string;
    FPrice: Currency;
  public
    // Map 'Description' explicitly to ftMemo (e.g., TEXT or CLOB in DB)
    [DbType(ftMemo)] 
    property Description: string read FDescription write FDescription;

    // Map 'Price' to ftCurrency (e.g., DECIMAL/MONEY) explicitly logic
    [DbType(ftCurrency)]
    property Price: Currency read FPrice write FPrice;
  end;
```

### Fluent API Equivalent

You can also achieve this using the Fluent API in your `OnModelCreating` method or configuration:

```pascal
Builder.Entity<TProduct>
  .Property('Description')
    .HasDbType(ftMemo);
```

---

## TypeConverterAttribute

The `[TypeConverter]` attribute allows you to specify a custom `ITypeConverter` implementation for a specific property. This enables complex data transformations between the database representation and your Delphi entity properties.

### Usage

First, implement your custom converter:

```pascal
type
  TMyCustomConverter = class(TInterfacedObject, ITypeConverter)
  public
    function FromDatabase(const AValue: TValue; AType: PTypeInfo): TValue;
    function ToDatabase(const AValue: TValue): TValue;
  end;
```

Then, apply the attribute to your property:

```pascal
type
  [Table('Orders')]
  TOrder = class
  private
    FStatus: TOrderStatus;
  public
    [TypeConverter(TMyCustomConverter)]
    property Status: TOrderStatus read FStatus write FStatus;
  end;
```

### Fluent API Equivalent

```pascal
Builder.Entity<TOrder>
  .Property('Status')
    .HasConverter(TMyCustomConverter);
```

## Smart Types Support

Dext ORM's Smart Types (e.g., `Prop<T>`) are fully supported by these mapping features. The SQL generator automatically unwraps the value type of `Prop<T>` to determine the correct column type, but you can override this with `[DbType]`.

```pascal
type
  TUser = class
  public
    // Will be detected as the inner type of Prop<Integer> -> ftInteger
    property Age: Prop<Integer> read FAge write FAge; 
    
    // Explicit override
    [DbType(ftLargeint)]
    property BigAge: Prop<Integer> read FBigAge write FBigAge;
  end;
```
