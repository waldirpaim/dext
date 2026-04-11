# Smart Properties - Expressões de Query Type-Safe

Smart Properties é uma funcionalidade poderosa do Dext ORM que permite **construção de queries type-safe sem magic strings**. Em vez de escrever fragmentos SQL ou usar nomes de colunas em strings, você escreve expressões Delphi naturais que são automaticamente convertidas para SQL.

## Visão Geral

ORMs tradicionais frequentemente exigem o uso de literais string para nomes de colunas em queries:

```pascal
// Abordagem tradicional - propensa a erros, sem IntelliSense
Users.Where('Age > 18 AND Name LIKE ''%John%''');
```

Com Smart Properties, você escreve:

```pascal
// Smart Properties - type-safe, IntelliSense, refatorável
var u := Prototype.Entity<TUser>;
Users.Where(u.Age > 18).Where(u.Name.Contains('John'));
```

## Conceitos Principais

### 1. Smart Types (`Prop<T>`)

Para habilitar expressões de query inteligentes, as propriedades da entidade devem ser empacotadas em `Prop<T>`. Este record genérico armazena tanto o valor quanto os metadados necessários para a geração de SQL.

Você pode usar `Prop<T>` explicitamente:

```pascal
type
  [Table('Users')]
  TUser = class
  private
    FId: Prop<Integer>;
    FName: Prop<string>;
    FAge: Prop<Integer>;
    FActive: Prop<Boolean>;
  public
    [PK, AutoInc]
    property Id: Prop<Integer> read FId write FId;
    property Name: Prop<string> read FName write FName;
    property Age: Prop<Integer> read FAge write FAge;
    property Active: Prop<Boolean> read FActive write FActive;
  end;
```

No entanto, para manter seu código limpo e conciso, Dext fornece aliases padrão (Recomendado):

```pascal
type
  [Table('Users')]
  TUser = class
  private
    FId: IntType;      // Alias para Prop<Integer>
    FName: StringType; // Alias para Prop<string>
    FAge: IntType;     // Alias para Prop<Integer>
    FActive: BoolType; // Alias para Prop<Boolean>
  public
    [PK, AutoInc]
    property Id: IntType read FId write FId;
    property Name: StringType read FName write FName;
    property Age: IntType read FAge write FAge;
    property Active: BoolType read FActive write FActive;
  end;
```

### 2. Aliases de Tipo

Para código mais limpo, Dext fornece aliases de tipo:

| Alias | Tipo Subjacente |
|-------|-----------------|
| `IntType` | `Prop<Integer>` |
| `Int64Type` | `Prop<Int64>` |
| `StringType` | `Prop<string>` |
| `BoolType` | `Prop<Boolean>` |
| `FloatType` | `Prop<Double>` |
| `CurrencyType` | `Prop<Currency>` |
| `DateTimeType` | `Prop<TDateTime>` |
| `DateType` | `Prop<TDate>` |
| `TimeType` | `Prop<TTime>` |

### 3. Entidades Prototype

Um "prototype" é uma instância especial **em cache** da sua entidade usada para construir queries. Em vez de conter dados reais, cada campo `Prop<T>` contém metadados (nome da coluna) que geram expressões SQL quando operadores são usados.

**Pontos chave:**
- Prototypes são **cacheados por tipo** para performance
- Criados uma vez, reutilizados para sempre (sem preocupação com lifecycle)
- Thread-safe (cada thread obtém sua própria instância)

### 4. BooleanExpression

`BooleanExpression` (alias: `BoolExpr`) é um record híbrido que pode conter:
- Um **valor Boolean em runtime** (para filtragem em memória)
- Uma **IExpression** (para geração de SQL)

Isso permite que o mesmo código funcione tanto para construção de queries quanto para avaliação em runtime.

## Opções de Sintaxe de Query

Dext oferece múltiplas formas de construir queries. Escolha o estilo que se encaixa no seu caso de uso.

---

### Opção 1: Prototype Direto (Recomendado)

A abordagem mais simples e performática. Prototypes são cacheados.

```pascal
var u := Prototype.Entity<TUser>;

// Query simples
var adults := Users.Where(u.Age >= 18).ToList;

// Múltiplas condições (AND)
var activeAdults := Users
  .Where(u.Age >= 18)
  .Where(u.Active = True)
  .ToList;

// Expressão complexa
var result := Users.Where((u.Age >= 18) and u.Active).ToList;
```

**Quando usar:** Na maioria dos cenários. Melhor para performance.

---

### Opção 2: Métodos Anônimos com BooleanExpression

Para expressões complexas que se beneficiam de um bloco de código.

```pascal
// Usando o nome completo do tipo
var result := Users.Where(
  function(u: TUser): BooleanExpression
  begin
    Result := (u.Age >= 18) and u.Name.StartsWith('J');
  end
).ToList;

// Usando o alias curto BoolExpr
var result := Users.Where(
  function(u: TUser): BoolExpr
  begin
    if AlgumaCondicao then
      Result := u.Age >= 21
    else
      Result := u.Age >= 18;
  end
).ToList;
```

**Quando usar:** 
- Lógica condicional complexa
- Expressões multi-linha
- Quando você precisa de variáveis locais ou cálculos

---

### Opção 3: Métodos de Specification

Usando prototype de dentro de Specifications (suporta Joins).

```pascal
type
  TActiveAdultsSpec = class(TSpecification<TUser>)
  public
    constructor Create;
  end;

constructor TActiveAdultsSpec.Create;
var
  u: TUser;
begin
  inherited Create;
  u := Prototype;  // Usa prototype cacheado
  Where(TFluentExpression((u.Age >= 18) and (u.Active = True)));
end;

// Para Joins - crie prototypes para múltiplos tipos
constructor TUserWithOrdersSpec.Create;
var
  u: TUser;
  o: TOrder;
begin
  inherited Create;
  u := Prototype;                  // Entidade principal
  o := Prototype<TOrder>;          // Entidade relacionada para Join
  // Construa condições de join...
end;
```

---

### Opção 4: Métodos Prototype do DbSet

Similar a Specification, mas diretamente do DbSet.

```pascal
var
  u: TUser;
  o: TOrder;
begin
  u := Users.Prototype;            // Entidade principal
  o := Users.Prototype<TOrder>;    // Para Joins
  
  var result := Users
    .Where(u.Age >= 18)
    .ToList;
end;
```

---

### Opção 5: Variável BooleanExpression Direta

Armazene expressões em variáveis para reutilização ou composição.

```pascal
var u := Prototype.Entity<TUser>;

// Armazenar condições
var ageCondition: BoolExpr := u.Age >= 18;
var activeCondition: BoolExpr := u.Active = True;
var combined: BoolExpr := ageCondition and activeCondition;

// Usar a expressão combinada
var result := Users.Where(combined).ToList;

// Composição dinâmica
if FiltrarPorIdade then
  combined := combined and (u.Age < 65);
  
var seniors := Users.Where(combined).ToList;
```

---

## Operações de Expressão

### Operadores de Comparação

```pascal
var u := Prototype.Entity<TUser>;

// Igualdade
var result := Users.Where(u.Age = 18).ToList;
var result := Users.Where(u.Name = 'João').ToList;

// Desigualdade
var result := Users.Where(u.Age <> 18).ToList;

// Maior/Menor que
var result := Users.Where(u.Age > 18).ToList;
var result := Users.Where(u.Age >= 18).ToList;
var result := Users.Where(u.Age < 65).ToList;
var result := Users.Where(u.Age <= 65).ToList;
```

### Operações de String

```pascal
var u := Prototype.Entity<TUser>;

// LIKE 'João%'
var result := Users.Where(u.Name.StartsWith('João')).ToList;

// LIKE '%silva'
var result := Users.Where(u.Name.EndsWith('silva')).ToList;

// LIKE '%maria%'
var result := Users.Where(u.Name.Contains('maria')).ToList;

// Padrão LIKE personalizado
var result := Users.Where(u.Name.Like('J_ão%')).ToList;
```

### Tratamento de Null

```pascal
var u := Prototype.Entity<TUser>;

// IS NULL
var semEmail := Users.Where(u.Email.IsNull).ToList;

// IS NOT NULL
var comEmail := Users.Where(u.Email.IsNotNull).ToList;
```

### Operações de Range e Coleção

```pascal
var u := Prototype.Entity<TUser>;

// BETWEEN
var result := Users.Where(u.Age.Between(30, 50)).ToList;

// IN (lista)
var result := Users.Where(u.Age.In([25, 30, 35])).ToList;

// NOT IN
var result := Users.Where(u.Age.NotIn([18, 21])).ToList;
```

### Operadores Lógicos

```pascal
var u := Prototype.Entity<TUser>;

// AND (usando múltiplas chamadas Where - AND implícito)
var result := Users
  .Where(u.Age >= 18)
  .Where(u.Active = True)
  .ToList;

// AND (explícito)
var result := Users.Where((u.Age >= 18) and (u.Active = True)).ToList;

// OR
var result := Users.Where((u.Age < 18) or (u.Age > 65)).ToList;

// NOT
var result := Users.Where(not (u.Age = 25)).ToList;

// Combinações complexas
var result := Users.Where(
  ((u.Age >= 18) and (u.Age <= 65)) or u.Active
).ToList;
```

## Como Funciona

### Geração de Expression Tree

Quando você escreve `u.Age > 18`:

1. `u.Age` é um `Prop<Integer>` com metadados injetados (nome da coluna = "Age")
2. O operador `>` é sobrecarregado em `Prop<T>`
3. Em vez de comparar valores, ele cria um nó `TBinaryExpression`
4. A árvore de expressão é armazenada em um record `BooleanExpression`
5. O gerador SQL percorre a árvore e produz: `"Age" > 18`

### Cache de Prototypes

```pascal
// Primeira chamada: cria e cacheia o prototype
var u1 := Prototype.Entity<TUser>;

// Segunda chamada: retorna instância cacheada (sem overhead RTTI)
var u2 := Prototype.Entity<TUser>;

// u1 e u2 são a MESMA instância!
```

### Internos do BooleanExpression

```pascal
BooleanExpression = record
private
  FRuntimeValue: Boolean;    // Para avaliação em memória
  FExpression: IExpression;  // Para geração de SQL
public
  // Métodos factory
  class function FromQuery(const AExpr: IExpression): BooleanExpression;
  class function FromRuntime(const AValue: Boolean): BooleanExpression;
  
  // Operadores lógicos
  class operator LogicalAnd(const Left, Right: BooleanExpression): BooleanExpression;
  class operator LogicalOr(const Left, Right: BooleanExpression): BooleanExpression;
  class operator LogicalNot(const Value: BooleanExpression): BooleanExpression;
end;

// Alias curto
BoolExpr = BooleanExpression;
```

## Vantagens

### ✅ Type Safety
Verificação em tempo de compilação dos nomes de propriedades. Erros de digitação são detectados imediatamente.

### ✅ Suporte a IntelliSense
Autocomplete completo do IDE para propriedades de entidades.

### ✅ Amigável para Refatoração
Renomeie uma propriedade e todas as queries são atualizadas automaticamente.

### ✅ Prevenção de SQL Injection
Valores são sempre parametrizados, nunca concatenados no SQL.

### ✅ Agnóstico de Banco de Dados
O mesmo código de query funciona em SQLite, PostgreSQL, SQL Server, etc.

### ✅ Código Legível
Queries são lidas como expressões naturais.

### ✅ Alta Performance
Prototypes são cacheados - sem overhead RTTI repetido.

### ✅ Alinhamento com .NET
`BooleanExpression` se alinha com o conceito de `Expression<Func<T, bool>>` do .NET.

## Limitações

### 1. Design de Entidades
Entidades devem usar tipos `Prop<T>` em vez de tipos simples:

```pascal
// Não funciona com Smart Properties
property Age: Integer read FAge write FAge;

// Funciona com Smart Properties
property Age: IntType read FAge write FAge;
```

### 2. Sem Sintaxe Lambda Curta
Delphi não suporta sintaxe `x => x.Age > 18`. O mais próximo que podemos chegar é:
```pascal
// Delphi requer declaração explícita de função
function(u: TUser): BoolExpr begin Result := u.Age > 18; end
```

### 3. Expressões Complexas
Algumas operações SQL complexas ainda podem exigir SQL bruto ou Specifications.

## Serialização & Desserialização
 
O serializador JSON do Dext (`TDextJson`) lida com `Prop<T>` de forma transparente em ambas as direções:
 
### Serialização (Entidade -> JSON)
Ele detecta automaticamente propriedades `Prop<T>` e as serializa como seus valores primitivos subjacentes:
 
```json
// JSON com unwrap automático
{
  "id": 1,
  "name": "João Silva",
  "age": 30
}
```
 
### Desserialização (JSON -> Entidade)
Ele popula corretamente tipos `Prop<T>` a partir de valores primitivos JSON simples. Isso é essencial para o Model Binding em Web APIs:
 
```pascal
// Exemplo: POST /products recebendo JSON
App.MapPost<TProduct, IResult>('/products', 
  function(P: TProduct): IResult
  begin
    // 'P.Name' e 'P.Price' (smart properties) são automaticamente populados a partir do corpo JSON
    Db.Products.Add(P);
    // ...
  end);
```
 
> **Nota:** Se você usar serializadores de terceiros (como `REST.Json` ou `System.JSON`) diretamente, records `Prop<T>` podem ser serializados como objetos complexos (ex: `{"Age": {"FValue": 30}}`). Para APIs REST, recomendamos usar o serializador nativo do Dext que lida com isso de forma transparente.

## Boas Práticas

### 1. Use Prototype Direto para Queries Simples
```pascal
var u := Prototype.Entity<TUser>;
var result := Users.Where(u.Age > 18).ToList;
```

### 2. Use Métodos Anônimos para Lógica Complexa
```pascal
var result := Users.Where(
  function(u: TUser): BoolExpr
  begin
    if UsuarioAtualEhAdmin then
      Result := True  // Sem filtro
    else
      Result := u.DepartmentId = DeptIdUsuarioAtual;
  end
).ToList;
```

### 3. Use Specifications para Regras de Negócio Reutilizáveis
```pascal
type
  TClientePremiumSpec = class(TSpecification<TCliente>)
  public
    constructor Create;
  end;

// Reutilizável em toda aplicação
var premium := Clientes.Query(TClientePremiumSpec.Create).ToList;
```

### 4. Escolha Seu Nível de Verbosidade
```pascal
// Verboso mas explícito
function(u: TUser): BooleanExpression

// Curto e prático
function(u: TUser): BoolExpr
```

## Unidades Relacionadas

| Unidade | Descrição |
|---------|-----------|
| `Dext.Entity.SmartTypes` | Core `Prop<T>`, `BooleanExpression`, aliases de tipo |
| `Dext.Entity.Prototype` | Factory `Prototype.Entity<T>` com cache |
| `Dext.Specifications.Base` | Classe base de specification com métodos Prototype |
| `Dext.Specifications.Types` | Tipos de árvore de expressão |
| `Dext.Specifications.SQL.Generator` | Geração SQL a partir de árvores de expressão |

## Exemplo Completo

```pascal
unit MinhasEntidades;

interface

uses
  Dext.Entity.Attributes,
  Dext.Entity.SmartTypes;

type
  [Table('Products')]
  TProduct = class
  private
    FId: IntType;
    FName: StringType;
    FPrice: CurrencyType;
    FStock: IntType;
    FActive: BoolType;
    FCreatedAt: DateTimeType;
  public
    [PK, AutoInc]
    property Id: IntType read FId write FId;
    property Name: StringType read FName write FName;
    property Price: CurrencyType read FPrice write FPrice;
    property Stock: IntType read FStock write FStock;
    property Active: BoolType read FActive write FActive;
    property CreatedAt: DateTimeType read FCreatedAt write FCreatedAt;
  end;

implementation
end.
```

```pascal
uses
  Dext.Entity.Prototype,
  Dext.Entity.SmartTypes;

procedure ExemplosDeQuery;
var
  p: TProduct;
  List: IList<TProduct>;
begin
  // Opção 1: Prototype direto (cacheado, rápido)
  p := Prototype.Entity<TProduct>;
  
  List := Products
    .Where(p.Active = True)
    .Where(p.Stock < 10)
    .Where(p.Price > 100)
    .ToList;

  // Opção 2: Método anônimo (para lógica complexa)
  List := Products.Where(
    function(prod: TProduct): BoolExpr
    begin
      Result := (prod.CreatedAt > EncodeDate(2024, 1, 1)) 
            and prod.Name.Contains('Premium');
    end
  ).ToList;

  // Opção 3: Composição com variáveis
  var isActive: BoolExpr := p.Active = True;
  var lowStock: BoolExpr := p.Stock < 10;
  var urgent: BoolExpr := isActive and lowStock;
  
  List := Products.Where(urgent).ToList;
end;
```
