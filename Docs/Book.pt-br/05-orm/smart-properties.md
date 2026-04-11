# Smart Properties

Expressões de consulta type-safe usando `Prop<T>`. Isso permite escrever queries que são verificadas em tempo de compilação, eliminando "strings mágicas".

> 📦 **Exemplo**: [Web.SmartPropsDemo](../../../Examples/Web.SmartPropsDemo/)

## Aliases de Tipo

Para definições de entidade mais limpas, use os seguintes aliases de `Dext.Core.SmartTypes`:

| Tipo | Equivalente Delphi |
|------|--------------------|
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

## Padrões de Uso

Existem duas formas principais de usar Smart Properties em consultas:

### 1. O Padrão "Member Props" (Mais Limpo)

Define uma propriedade estática `Props` na sua classe.

```pascal
type
  TProduct = class
  public
    class var Props: record
      Name: StringType;
      Price: CurrencyType;
    end;
  end;

// Uso:
var p := TProduct.Props;
var ProdutosBaratos := Context.Products
  .Where(p.Price < 10)
  .ToList;
```

### 2. O Padrão "Phantom Entity" (Sem alterações na classe)

Se você não quiser adicionar um campo `Props` à sua classe, use `Prototype.Entity<T>`.

```pascal
uses Dext.Entity.Prototype;

var p := Prototype.Entity<TProduct>;
var ProdutosBaratos := Context.Products
  .Where(p.Price < 10)
  .ToList;
```

## Operações Suportadas

### Comparações
- `=`, `<>`, `>`, `>=`, `<`, `<=`
- `In([V1, V2])`, `NotIn([V1, V2])`
- `IsNull`, `IsNotNull`

### Lógica de String
- `Contains('texto')`
- `StartsWith('texto')`
- `EndsWith('texto')`
- `Like('%texto%')`

### Lógica Booleana
```pascal
var u := TUser.Props;
Context.Users.Where((u.Age > 18) and (u.IsActive = True)).ToList;
```

## Por que usar Smart Properties?

1. **Segurança em Refatoração**: Se você renomear uma propriedade na classe, o compilador apontará todos os erros nas queries.
2. **Legibilidade**: O código fica próximo ao SQL, mas permanece 100% Pascal.
3. **Suporte da IDE**: O Code Completion funciona para todos os campos disponíveis na consulta.

---

[← Consultas](consultas.md) | [Próximo: Specifications →](specifications.md)
