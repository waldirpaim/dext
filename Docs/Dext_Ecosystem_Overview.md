# Dext Framework — Visão de Ecossistema

> *"Não é uma coleção de bibliotecas. É uma plataforma integrada."*

Este documento apresenta o **Dext Framework** como um ecossistema coeso, destacando como cada subsistema se conecta para formar uma plataforma de desenvolvimento enterprise completa — algo que **não existia no Delphi** antes.

Existem projetos excelentes no ecossistema Delphi que resolvem problemas isolados (ORM, DI, testes, REST). O diferencial do Dext é que **todas as peças foram desenhadas para funcionar juntas**, do request HTTP até a persistência no banco, passando por DI, logging, validação, serialização e telemetria — tudo em uma pipeline unificada e coerente.

---

## 🧬 A Filosofia: Simplicidade Exige Engenharia Sofisticada

> *"Simplicity is Complicated."* — Rob Pike

O desenvolvedor escreve `App.MapGet('/users', ...)` e ganha roteamento, model binding, serialização JSON, DI, logging e tratamento de erros. Mas por baixo, o framework resolve:

1. O **Reflection Engine** descobre os tipos dos parâmetros via RTTI cache thread-safe
2. O **Activator** resolve dependências com **greedy constructor selection**
3. O **DI Container** injeta serviços com lifecycle híbrido (ARC para interfaces, manual para classes)
4. O **Model Binder** desserializa o body JSON usando o driver de alta performance (zero-allocation UTF-8)
5. O **Validation Engine** aplica atributos de validação automaticamente
6. O handler executa a lógica de negócio
7. O resultado é serializado via `TUtf8JsonWriter` diretamente para o socket — **sem string intermediária**

Tudo isso acontece invisível ao desenvolvedor. Essa é a promessa.

> *"Make what is right easy and what is wrong difficult."* — Steve "Ardalis" Smith

---

## 🔥 Pipeline Web Zero-Allocation: O Motor de Performance

A pipeline HTTP do Dext foi integralmente refatorada para **eliminar alocações de heap** nos hot-paths de processamento de requisições. Isso não é uma otimização pontual — é uma filosofia arquitetural que perpassa toda a stack:

### Da Requisição à Resposta — Sem Alocar

```
[Socket] → TByteSpan (raw bytes, stack-allocated)
         → TUtf8JsonReader (parsing zero-copy direto do buffer)
         → TUtf8JsonSerializer (record fields via PTypeInfo cache — sem TValue boxing)
         → Prop<T> / Smart Types (query mode ou runtime mode, sem intermediários)
         → Handler executa lógica
         → TUtf8JsonWriter (streaming direto para o socket — sem string intermediária)
         → [Socket]
```

**Componentes envolvidos na pipeline zero-allocation:**

| Camada | Componente | Impacto |
|---|---|---|
| **Parsing de entrada** | `TByteSpan` + `TUtf8JsonReader` | Evita conversão UTF-8 → UTF-16 → UTF-8 |
| **Desserialização** | `TUtf8JsonSerializer` | Cache de `TJsonRecordInfo` por `PTypeInfo` — elimina RTTI scan repetido |
| **RTTI / Reflection** | `TReflection` (S07) | Lock-free fast path com cache singleton de metadata |
| **Value Conversion** | `TValueConverterRegistry` | Lookup 3 níveis sem alocação de TValue intermediário |
| **Comparações** | `TDextSimd.EqualsBytes` | AVX2 (32 bytes/ciclo) ou SSE2 (16 bytes/ciclo) |
| **Serialização de saída** | `TUtf8JsonWriter` | Streaming direto para output buffer — zero string temporária |
| **View Engine** | Flyweight Iterators | Memória O(1) em loops de template |

**O resultado**: O tempo de processamento de requisições caiu **drasticamente** em comparação com pipelines tradicionais que convertem strings múltiplas vezes. Cada requisição toca a heap **o mínimo possível**.

---

## 🧠 Smart Types: A DSL que Não Deveria Existir no Delphi

O sistema `Prop<T>` é a inovação mais significativa do Dext — uma **DSL fluente LINQ-like com tipagem forte** implementada inteiramente via **operator overloading** e **expression trees**. Isso não existia no Delphi.

### O Que o Desenvolvedor Escreve

```pascal
TUser = class
  FAge: IntType;      // Alias para Prop<Integer>
  FName: StringType;  // Alias para Prop<string>
end;

// Query com compilação estática e IntelliSense
var Users := DbContext.Users
  .Where(function(U: TUser): BooleanExpression
  begin
    Result := (U.Age > 18) and (U.Name.StartsWith('Ce'));
  end)
  .OrderBy(U.Age.Desc)
  .Take(50)
  .ToList;
```

### O Que Acontece Por Baixo

1. `TPrototype` cria uma instância "fantasma" de `TUser` com `IPropInfo` injetado em cada `Prop<T>`
2. Quando `U.Age > 18` executa, o `Prop<Integer>` está em **Query Mode** — em vez de comparar valores, gera um nó `TBinaryExpression(TPropertyExpression('Age'), TLiteralExpression(18), boGreaterThan)`
3. O operador `and` combina as expressões em `TLogicalExpression(left, right, loAnd)`
4. O `BooleanExpression` final carrega toda a AST
5. O **SQL Dialect Compiler** percorre a árvore e gera: `WHERE "Age" > 18 AND "Name" LIKE 'Ce%'`

**A mágica**: O mesmo `Prop<T>` funciona em dois modos. Em contexto de query, gera SQL. Em contexto de runtime, opera como value type normal. O desenvolvedor **nunca muda de API** — é a mesma entidade nos dois cenários.

### Profundidade do Type System

```
Prop<T>  ────→  BooleanExpression  ────→  IExpression (AST)
   │                  │                        │
   ├─ Implicit(T)     ├─ and/or/not            ├─ TPropertyExpression
   ├─ Implicit(Nullable<T>)                    ├─ TBinaryExpression
   ├─ Implicit(Variant)                        ├─ TLogicalExpression
   ├─ Like/StartsWith/Contains                 ├─ TFunctionExpression
   ├─ In/NotIn/Between/IsNull                  ├─ TLiteralExpression
   ├─ Asc/Desc → IOrderBy                     └─ TConstantExpression
   └─ Aritmética: +, -, *, /
```

---

## 🏗️ O Ecossistema Integrado: Como Tudo Se Conecta

O que diferencia o Dext de soluções isoladas é a **integração de ponta a ponta**. Cada subsistema foi desenhado com conhecimento dos demais:

### O Grafo de Integração

```
                        ┌──────────────────┐
                        │   Dext CLI        │
                        │  (dext new/add)   │
                        └────────┬─────────┘
                                 │ gera projetos usando
                                 ▼
┌───────────────┐      ┌──────────────────┐      ┌───────────────┐
│ Template Engine│◄─────│  Web Pipeline     │─────►│ View Engine   │
│ (AST-based)   │      │  (Zero-Alloc)     │      │ (SSR/Stencils)│
└───────────────┘      └────────┬─────────┘      └───────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
            ┌────────────┐ ┌────────────┐ ┌────────────┐
            │  DI Container│ │ JSON Engine │ │ Validation │
            │  (Hybrid ARC)│ │ (UTF-8 0-alloc)│ │ (Attribute) │
            └──────┬─────┘ └──────┬─────┘ └────────────┘
                   │              │
                   ▼              ▼
            ┌────────────┐ ┌────────────┐
            │  Reflection  │ │Smart Types │
            │  (Cache S07) │ │ (Prop<T>)  │
            └──────┬─────┘ └──────┬─────┘
                   │              │ gera Expression Trees
                   ▼              ▼
            ┌────────────┐ ┌────────────┐
            │   ORM        │◄│Specifications│
            │ (Multi-DB)   │ │ (IExpression)│
            └──────┬─────┘ └────────────┘
                   │
          ┌────────┼────────┐
          ▼        ▼        ▼
     ┌────────┐┌────────┐┌────────┐
     │ PgSQL  ││ MSSQL  ││ MySQL  │ ... + Firebird, SQLite, Oracle
     └────────┘└────────┘└────────┘
```

### Integrações Chave que Não Existem em Soluções Isoladas

| Integração | O Que Faz | Por Que Importa |
|---|---|---|
| **DI → ORM → Web** | DbContext é registrado como Scoped; cada request HTTP recebe sua instância; o EventBus compartilha o mesmo scope | Sem isso, transações e Identity Map quebram |
| **Smart Types → ORM → SQL** | `Prop<T>` gera AST → ORM compila para o dialeto correto (PostgreSQL, MSSQL, etc.) | Query type-safe com IntelliSense, sem magic strings |
| **Reflection → JSON → Web** | Cache RTTI S07 é compartilhado entre serialização JSON, model binding, ORM mapping e validation | Um único scan RTTI serve todo o framework |
| **Templating → CLI → Web** | O mesmo motor de templates serve: scaffolding CLI, SSR web e geração de relatórios de teste | Uma engine, três usos — zero dependência cruzada |
| **EventBus → DI → Lifecycle** | Behaviors (Logging, Timing, Exception) são resolvidos via DI; lifecycle events conectam ao Host | Cross-cutting concerns sem acoplamento |
| **Collections → SIMD → JSON** | `TByteSpan.Equals` usa `TDextSimd.EqualsBytes` (AVX2/SSE2) para comparações do parser JSON | Hardware acceleration transparente |
| **Navigator → DI → Middleware** | Navigator usa a mesma arquitetura de middleware pipeline do Web para auth guards em navegação desktop | Desktop com padrões de segurança web |
| **EntityDataSet → ORM → VCL** | `TEntityDataSet` lê offsets via `TEntityMap` do ORM; `LoadFromUtf8Json` usa `TByteSpan` zero-alloc | Bridge perfeita entre ORM moderno e grids legadas |
| **REST Client → Async → DI** | `TRestClient` usa connection pool thread-safe; `TAsyncTask` encadeia operações; auth providers injetados via DI | HTTP client com mesma DX fluente do resto do framework |
| **HTMX → View Engine → ORM** | Flyweight Iterators streamam queries do ORM direto para templates; HTMX auto-detection suprime layouts | Full-stack SSR com O(1) memória e zero JavaScript |

---

## 🧪 O Ciclo Completo de Qualidade

O Dext não apenas permite construir aplicações — ele garante que sejam **testáveis de ponta a ponta**:

```
[Código] → [Testes Unitários + Mocking]
         → [Auto-Mocking Container (TAutoMocker)]
         → [Snapshot Testing (JSON baselines)]
         → [Code Coverage (dext test --coverage)]
         → [Quality Gates (thresholds CI/CD)]
         → [Relatórios: JUnit XML, TRX, SonarQube, HTML]
         → [Live Dashboard (dext ui)]
```

**Tudo integrado com DI**: `TTestServiceProvider` substitui serviços de produção por mocks sem alterar o código da aplicação.

---

## 🗄️ Database as API: Uma Linha de Código, Todo o Ecossistema Trabalhando

O **Database as API** é a demonstração definitiva de como o ecossistema integrado do Dext cria valor impossível em soluções isoladas. Com **uma única linha de código**, o desenvolvedor ganha uma API REST completa com segurança, filtros, paginação, documentação e telemetria — tudo operando sobre a mesma pipeline zero-allocation.

### O Que o Desenvolvedor Escreve

```pascal
[DataApi]          // ← Isso é tudo.
[Table('products')]
TProduct = class
  [PK, AutoInc] property Id: Integer;
  property Name: string;
  property Price: Double;
end;

// No startup:
App.MapDataApis;   // Escaneia RTTI, registra todas as [DataApi] automaticamente
```

### O Que o Framework Entrega

```
Uma linha → 5 endpoints REST (GET list, GET by id, POST, PUT, DELETE)
          → 11 operadores de filtro via QueryString (_gt, _lt, _cont, _in, ...)
          → Paginação automática (_limit, _offset)
          → Ordenação dinâmica (_orderby=price desc)
          → Segurança por operação (RequireAuth, RequireRole, ReadRole vs WriteRole)
          → Documentação Swagger automática
          → Telemetria (TDiagnosticSource)
          → Logging estruturado
          → Multi-tenancy (RequireTenant)
          → Suporte a UUID, GUID e Composite Keys
```

### Quantos Subsistemas São Ativados com Uma Linha?

| Subsistema | O Que Faz no DataApi |
|---|---|
| **RTTI / Reflection (S07)** | `TDataApi.MapAll` escaneia atributos `[DataApi]` via `TReflection.Context.GetTypes`. `ResolvePropertyName` converte snake_case→PascalCase via `GetHandlerBySnakeCase` |
| **DI Container** | `GetDbContext` resolve `TDbContext` do scope da request — cada request HTTP tem sua própria instância |
| **ORM (TDbContext)** | `DataSet(ClassInfo)` retorna `IDbSet` dinâmico. `Add`, `Update`, `Remove`, `FindObject`, `ListObjects` |
| **Specifications (AST)** | Filtros da QueryString geram `IExpression` via `TStringExpressionParser.Parse` — a **mesma AST** usada por `Prop<T>` |
| **JSON Engine** | `TDextJson.Deserialize` (entrada) + `TDextSerializer` (saída) com `NamingStrategy` e `EnumStyle` configuráveis per-endpoint |
| **Model Binding** | `TEntityIdResolver` delega ao `IModelBinder` para converter `{id}` da URL para Integer/TUUID/TGUID automaticamente |
| **Security** | `CheckAuthorization` valida JWT via `IClaimsPrincipal` com separação read/write roles |
| **Swagger / OpenAPI** | Endpoints aparecem automaticamente na spec com tags e descrições |
| **Telemetria** | `TDiagnosticSource.Write('DataApi.ModelBinding.Start/Complete')` para tracing |
| **Naming Conventions** | `TDataApiNaming.GetDefaultPath` remove prefixo `T`, pluraliza (y→ies, s→ses), gera `/api/products` |

**Isso é o que a integração faz**: Nenhum desses subsistemas foi criado *para* o DataApi. Cada um foi criado como peça independente do ecossistema. O DataApi simplesmente os **orquestra** — e o resultado é que uma única linha de código ativa 10 subsistemas trabalhando em harmonia.

### Três Modos de Registro

```pascal
// 1. Automático — [DataApi] + MapDataApis
App.MapDataApis;

// 2. Manual tipado
TDataApiHandler<TProduct>.Map(App, '/api/products');

// 3. Fluente com políticas
App.Builder.MapDataApi<TProduct>('/api/products', DataApiOptions
  .Allow([amGet, amGetList])      // Somente leitura
  .RequireAuth                    // JWT obrigatório
  .RequireWriteRole('Admin')      // Apenas Admin pode POST/PUT/DELETE
  .UseSnakeCase                   // JSON em snake_case
  .EnumsAsStrings                 // Enums como texto
  .DbContext<TMyContext>          // Contexto específico
  .Tag('Products')                // Tag no Swagger
);
```

---

## 📊 O Que Não Existia no Delphi — O Que o Dext Trouxe

| Capacidade | Antes do Dext | Com o Dext |
|---|---|---|
| **DSL LINQ-like type-safe** | Inexistente | `Prop<T>` + Expression Trees + operator overloading |
| **Pipeline HTTP zero-allocation** | N/A | `TByteSpan` → `TUtf8JsonReader` → handler → `TUtf8JsonWriter` → socket |
| **Frozen Collections (.NET 8 style)** | Inexistente | `TFrozenDictionary<K,V>`, `TFrozenSet<T>` |
| **Go-style Channels** | Inexistente | `TChannel<T>` com bounded/unbounded e back-pressure |
| **SIMD-accelerated collections** | Inexistente | AVX2 (32B/ciclo), SSE2 (16B/ciclo) com fallback |
| **Lock Striping (concurrent dict)** | Inexistente | `TConcurrentDictionary<K,V>` com array de `TSpinLock` |
| **Minimal API style routing** | Inexistente | `App.MapGet`, `App.MapPost` com auto-binding |
| **Auto-Mocking Container** | Inexistente | `TAutoMocker` injeta mocks automaticamente |
| **Snapshot Testing** | Inexistente | `MatchSnapshot` com baselines JSON |
| **Database as API (zero-code)** | Inexistente | `[DataApi]` + `MapDataApis` → CRUD REST com 11 filtros, segurança, Swagger, telemetria, multi-tenant — **10 subsistemas ativados com 1 linha** |
| **Expression Evaluator (dual-mode AST)** | Inexistente | Mesma `IExpression` AST gera SQL no banco E avalia in-memory no servidor |
| **Soft Delete declarativo** | Inexistente | `[SoftDelete]` → Remove vira UPDATE, `Restore`, `OnlyDeleted`, `IgnoreQueryFilters` |
| **JSON/JSONB Column Queries** | Inexistente | `.Json('path')` cross-database: PG `#>>`, MySQL `JSON_EXTRACT`, SQLite `json_extract`, MSSQL `JSON_VALUE` |
| **Flutter-style Navigator (Desktop)** | Inexistente | Push/Pop/PopUntil + 3 Adapters + Middleware Pipeline + Auth Guard |
| **Magic Binding (Desktop MVVM)** | Inexistente | `[BindEdit]`, `[BindText]`, `[OnClickMsg]` — two-way binding por atributos |
| **EntityDataSet zero-allocation** | Inexistente | Leitura via offsets `TEntityMap` + `LoadFromUtf8Json` + design-time Sync Fields |
| **Flyweight SSR Iterators** | Inexistente | 10K registros renderizados com O(1) memória — sem `ToList` |
| **HTMX Auto-Detection** | Inexistente | Pipeline suprime layout automaticamente para `HX-Request` headers |
| **REST Client com Connection Pool** | Inexistente | Record leve + async chaining (`ThenBy<T>`) + pluggable auth + cancellation |
| **TAsyncTask fluente** | Inexistente | `Run<T>.ThenBy<U>.OnComplete.OnException.Start` com cancellation |
| **IOptions<T> tipado** | Inexistente | Binding de seções JSON/YAML/ENV para classes tipadas — idêntico ao ASP.NET Core |
| **AI Skills nativas** | Inexistente | Skills modulares para Cursor/Antigravity/Copilot gerarem código idiomático Dext |
| **Multi-tenancy (Schema/DB/Column)** | Inexistente | 3 estratégias integradas com ORM |
| **SignalR-compatible Hubs** | Inexistente | `Dext.Web.Hubs` com grupos e broadcast |
| **AST Template Engine** | Inexistente | Parser → AST → Executor com layouts e herança |
| **DI Híbrido (ARC + Manual)** | Inexistente | Interface → ARC, Classe → Manual lifecycle |
| **Defer Pattern (Go-style)** | Inexistente | `IDeferred` / `TDeferredAction` |
| **ILifetime<T> (ARC wrapper)** | Inexistente | Wrap de objetos Non-ARC em ARC |
| **Code Coverage via CLI** | Inexistente | `dext test --coverage` com SonarQube |
| **Live Test Dashboard** | Inexistente | Dashboard web dark-theme em tempo real |

---

## 🛤️ Roadmap: Para Onde o Ecossistema Está Indo

### Onda Atual (Em Progresso)
- **S14 — SOA via Interfaces**: RPC/gRPC Code-First transparente — defina interfaces Delphi, o framework gera as camadas de transporte automaticamente
- **S02 — gRPC & Protobuf**: Motor nativo IOCP/EPOLL para comunicação binária de alta velocidade
- **S06 — OAuth2 & OIDC**: Login nativo com Google, Microsoft, JWT
- **S13 — Redis Client**: Client async de alta performance com RESP3 e RedisJSON

### Futuro
- HTTP Server nativo (IOCP/EPOLL/Kqueue — sem dependência de Indy)
- OData, GraphQL
- Microservices Mesh (service discovery + load balancing)
- UI Nativo com Skia

---

## 📐 Decisões de Engenharia: Por Que Funciona

### 1. Record Types Como Foundation
O Delphi moderno (10.4+) suporta **operator overloading em records**, **implicit/explicit operators** e **class operators**. O Dext explora isso ao máximo: `Prop<T>`, `Nullable<T>`, `TUUID`, `TByteSpan`, `TSpan<T>`, `BooleanExpression` — todos são records com semântica de valor que eliminam alocações de heap.

### 2. Hybrid Memory Model
Em vez de forçar uma única estratégia (ARC ou manual), o DI Container detecta automaticamente: interfaces usam ARC (reference counting nativo do Delphi), classes usam lifecycle gerenciado (Singleton = framework destrói na saída, Scoped = framework destrói no fim do scope, Transient = chamador destrói).

### 3. Driver Pattern Para Extensibilidade
JSON, HTTP Server, e Database usam o mesmo padrão: uma abstração de interface com múltiplos drivers plugáveis. Isso permite trocar `JsonDataObjects` por `System.JSON`, ou `Indy` por `DCS` ou `WebBroker`, sem alterar código de aplicação.

### 4. Reflection Cache (S07) Como Backbone
O cache RTTI thread-safe com fast paths lock-free é **o backbone** de todo o framework. JSON, ORM, Validation, Model Binding, Smart Types — todos consultam o mesmo cache singleton. Um único scan RTTI na inicialização serve **toda a vida útil** do processo.

### 5. Infrastructure Flywheel — Velocidade Exponencial de Features
A maturidade da infraestrutura cria um **efeito flywheel**: cada nova feature compõe de engines existentes, acelerando dramaticamente o desenvolvimento.

**Caso exemplar — Specification Pattern (inspirado por Steve "Ardalis" Smith)**:
O motor de Specifications foi construído originalmente para queries tipo-safe do ORM (`Prop<T>` → `IExpression` → SQL). Quando veio a necessidade de filtragem dinâmica no DataApi, o engine de Specifications **já sabia resolver** — `TStringExpressionParser` converte filtros da URL nos **mesmos nós `IExpression`** que `Prop<T>` gera em código tipado. A filtragem foi "grátis".

```
Engine Original                  →  Reuso Emergente
─────────────────────────────────────────────────────
Specification (ORM queries)      →  DataApi (URL filtering — grátis)
                                 →  In-Memory Evaluator (zero código extra)
Reflection Cache S07 (JSON)      →  ORM + Validation + Model Binding + EntityDataSet
TByteSpan (zero-allocation)      →  JSON Reader + EntityDataSet + Redis RESP3 (~80% pronto)
TConnectionPool (REST Client)    →  Redis Client (mesmo padrão)
TAsyncTask (async/await)         →  REST Client + Redis + Background Services
```

**Resultado prático**: Na análise de viabilidade do Redis Client, ~80% da infraestrutura já existia — `TByteSpan`, `TAsyncTask`, `TConnectionPool`, `ICancellationToken`. O único código genuinamente novo é o protocolo RESP3.

### 6. O Trade-Off da Integração
A profundidade da integração traz um **multiplicador de responsabilidade**: uma alteração no `IExpression` deve ser validada contra **todos os consumidores** — ORM, DataApi, Evaluator, EntityDataSet. Isso torna os testes automatizados não opcionais, mas **existenciais**. Os 165+ testes em 5 bancos de dados são o preço — e a garantia — da integração.

---

*Dext Framework — Performance nativa, produtividade moderna, ecossistema completo.*

*Construído em anos de estudo das melhores práticas de .NET, Go e Java — adaptadas com sabedoria para o que o Delphi faz de melhor.*

*Não é só Web. Não é só API. É Desktop, Networking, Testing, CLI, Observability e AI — tudo integrado.*
