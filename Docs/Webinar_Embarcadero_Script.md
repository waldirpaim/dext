# Dext Framework — Embarcadero Webinar Script
## Presenter: Cesar Romero | Host: Ian Barker

> **Focus**: Overview + Unique Features + Why Dext Matters for Delphi

---

## 📋 Agenda (Suggested ~45-60 min)

| Time | Section | Duration |
|---|---|---|
| 00:00 | Opening — The Problem Statement | 3 min |
| 03:00 | Part 1 — Overview: What is Dext? | 10 min |
| 13:00 | Part 2 — Unique Features (Live Code) | 20 min |
| 33:00 | Part 3 — Why Dext Matters for Delphi | 10 min |
| 43:00 | Part 4 — Roadmap & Vision | 5 min |
| 48:00 | Q&A | 10-15 min |

---

# 🎬 Opening — The Problem Statement (3 min)

### The Developer's Dilemma

> *"If I use Delphi, I have to glue 5 different libraries together to do what .NET gives me out of the box."*

This is what we hear from Delphi developers every day. They love the language, the performance, the native compilation — but they look at .NET and see:

- **One DI container** that everything uses
- **One ORM** that integrates with the web pipeline
- **One JSON engine** shared across the entire stack
- **One test framework** with mocking built-in

In Delphi, developers cobble together Spring4D for DI, mORMot or a custom ORM, a separate JSON library, Horse or MARS for REST, DUnitX for testing — and none of these were designed to work together.

**Dext changes this.** It's not another library. It's an **ecosystem**.

---

# Part 1 — Overview: What is Dext? (10 min)

## 1.1 The Elevator Pitch

**Dext is a full-stack development platform for Delphi**, inspired by ASP.NET Core and Spring Boot, providing:

- 🌐 **Web Framework** — Minimal API + Controllers + Middleware Pipeline + SSR + HTMX
- 🗄️ **ORM** — Code-First, Multi-Database, Change Tracking, Migrations, JSON/JSONB Queries
- 💉 **Dependency Injection** — Hybrid ARC/Manual lifecycle + IOptions<T> Configuration
- 🧪 **Testing** — Auto-Mocking, Snapshot Testing, Code Coverage
- 📡 **Real-Time** — SignalR-compatible Hubs, SSE
- 🔧 **CLI** — Scaffolding, Migrations, Test Runner
- 📊 **Observability** — Telemetry, Structured Logging, Diagnostics
- 🖥️ **Desktop UI** — Navigator (Flutter-style), Magic Binding, MVVM, EntityDataSet
- 🌍 **Networking** — Async REST Client with Connection Pooling + Cancellation
- 🤖 **AI-Ready** — Native AI Skills for IDE assistants (Cursor, Antigravity, Claude, Copilot)

All integrated. All designed together. **Apache 2.0 licensed.**

## 1.2 The 30-Second Demo

```pascal
program HelloDext;
uses Dext.Web;

begin
  var App := TWebApplication.Create;
  
  App.MapGet('/hello', function: string
  begin
    Result := 'Hello from Dext!';
  end);
  
  App.Run;
end.
```

**Key talking point**: "If you know ASP.NET Minimal APIs, you already know Dext. The patterns transfer directly."

## 1.3 Architecture at a Glance

```
┌──────────────────────────────────────────────────┐
│                  Your Application                │
├──────────────────────────────────────────────────┤
│  Web Pipeline  │  ORM/Entity  │  Testing         │
│  (Minimal API) │  (DbContext) │  (AutoMocker)    │
├──────────────────────────────────────────────────┤
│  DI Container │ JSON Engine  │ Template Engine   │
│  (Hybrid ARC) │ (Zero-Alloc) │ (AST-based)       │
├──────────────────────────────────────────────────┤
│  Reflection Cache (S07)  │  Smart Types (Prop<T>)│
├──────────────────────────────────────────────────┤
│  Collections (SIMD) │ Memory │ Logging │ Config  │
└──────────────────────────────────────────────────┘
```

## 1.4 Multi-Database Support

> "Write once, deploy to any database."

- ✅ PostgreSQL
- ✅ SQL Server
- ✅ MySQL / MariaDB
- ✅ Firebird
- ✅ SQLite
- 🟡 Oracle (beta)

**165+ tests pass on ALL databases.** Same ORM code, different connection string.

---

# Part 2 — Unique Features of Dext (20 min)

> **Ian asked for "unique features"** — these are capabilities that **do not exist** in any other Delphi framework or component.

## 🏆 Feature 1: Smart Properties — LINQ for Delphi (5 min)

**What it is**: Type-safe query expressions using operator overloading and expression trees — a LINQ-like DSL that compiles to SQL at runtime.

**Why it's unique**: No other Delphi framework has this. Queries in Delphi have always relied on magic strings. Dext changes that.

### Before Dext (Every other Delphi ORM)
```pascal
// Magic strings — no IntelliSense, no compile-time check
Session.CreateCriteria<TUser>
  .Add(Restrictions.Gt('Age', 18))         // 'Age' could be wrong
  .Add(Restrictions.Like('Name', 'Ce%'));   // Easy to mistype
```

### With Dext
```pascal
// Type-safe — compiler checks everything, IntelliSense works
var Users := Db.Users
  .Where((U.Age > 18) and (U.Name.StartsWith('Ce')))
  .OrderBy(U.Name.Asc)
  .Take(50)
  .ToList;
```

### How It Works (The Magic)

```pascal
TUser = class
  FAge: IntType;      // IntType = Prop<Integer>
  FName: StringType;   // StringType = Prop<string>
end;
```

1. `Prop<T>` operates in **dual mode**: runtime (stores values) or query (generates AST)
2. When `.Where(...)` executes, a **prototype** instance is created with metadata injected
3. `U.Age > 18` triggers `Prop<Integer>.GreaterThan` operator → generates `TBinaryExpression`
4. `and` combines into `TLogicalExpression`
5. The SQL Dialect Compiler walks the AST → generates correct SQL for each database

**Demo suggestion**: Show IntelliSense working on entity properties, then show the generated SQL.

### The Bridge: Specifications Pattern (Inspired by Ardalis)

> *This is the story that connects Feature 1 to Feature 2.*

The **Specification Pattern** (inspired by Steve "Ardalis" Smith's architecture) is the **engine behind the scenes**. Here's the key insight:

When I built Smart Properties (`Prop<T>`), the expression trees generated a reusable AST (Abstract Syntax Tree). That same AST became `ISpecification` — a composable, reusable query object.

```
Smart Properties (Prop<T>)  →  IExpression AST  →  ISpecification
                                      ↓                    ↓
                               SQL Compiler          In-Memory Evaluator
                               (generates SQL)       (filters objects)
                                      ↓                    ↓
                               Database Query         DataApi Filtering
```

**What this means in practice**: Instead of writing 10 different endpoints with different parameter combinations (`/products?minPrice=50`, `/products?category=shoes&inStock=true`, etc.), the Specification engine receives **any filter from the URL**, parses it via `TStringExpressionParser`, and converts it into the **same AST** that the ORM uses for SQL generation.

**One engine, three consumers**: ORM queries, in-memory evaluation, and API filtering — all sharing the same expression infrastructure. This is why DataApi needed zero extra query logic — Specifications had already solved it.

**Talking point**: *"When I was implementing DataApi, I expected it to take weeks to add dynamic filtering. It took hours — because the Specification engine I built for the ORM already knew how to do it. The same `IExpression` that generates `WHERE price > 50` in SQL also evaluates objects in memory. That's the power of integrated architecture."*

---

## 🏆 Feature 2: Database as API — Zero-Code REST (3 min)

**What it is**: Generate a full REST API from entity classes with a single line of code — no controllers, no handlers, no boilerplate.

**Why it's unique**: No Delphi framework offers automatic CRUD API generation with security, filtering, pagination, and Swagger documentation out of the box.

```pascal
[DataApi]              // ← This is everything.
[Table]
TProduct = class
  [PK, AutoInc] property Id: Integer;
  property Name: string;
  property Price: Double;
end;

// Startup:
App.MapDataApis;       // Scans RTTI, registers all [DataApi] entities
```

**What you get automatically**:

| Endpoint | What It Does |
|---|---|
| `GET /api/products` | List with pagination (`_limit`, `_offset`) |
| `GET /api/products/42` | Find by ID (Integer, UUID, GUID, composite) |
| `POST /api/products` | Create with JSON body |
| `PUT /api/products/42` | Update with JSON body |
| `DELETE /api/products/42` | Delete by ID |
| `GET /api/products?price_gt=50&name_cont=Dext` | 11 filter operators |
| Swagger UI | Auto-documented |

**The integration story**: One line of code activates **10 subsystems** — Reflection, DI, ORM, Specifications, JSON, Model Binding, Security, Swagger, Telemetry, and Naming Conventions — all working together seamlessly.

**The Specification payoff**: Those 11 filter operators (`_gt`, `_lt`, `_cont`, `_in`, etc.) don't use custom parsing logic. Each one maps to a `TStringExpressionParser.Parse` call that produces the **exact same `IExpression` nodes** that `Prop<T>` generates in typed code. The filtering engine was "free" — it was already built.

**Demo suggestion**: Create an entity, add `[DataApi]`, run the app, open browser → Swagger UI → test CRUD live.

---

## 🏆 Feature 3: Zero-Allocation Web Pipeline (3 min)

**What it is**: The entire HTTP request/response pipeline was engineered to minimize heap allocations.

**Why it's unique**: No other Delphi web framework has tackled zero-allocation at the pipeline level.

```
Request → TByteSpan (stack-allocated)
        → TUtf8JsonReader (zero-copy from raw buffer)
        → TUtf8JsonSerializer (PTypeInfo cache, no TValue boxing)
        → Handler logic
        → TUtf8JsonWriter (streaming to socket, no intermediate strings)
        → Response
```

**Key components**:
- `TByteSpan` — Avoids UTF-8 → UTF-16 → UTF-8 conversion
- `TUtf8JsonSerializer` — Cached `TJsonRecordInfo` per `PTypeInfo`
- `TDextSimd.EqualsBytes` — AVX2 (32 bytes/cycle) or SSE2 (16 bytes/cycle) acceleration
- `TUtf8JsonWriter` — Streams directly to output buffer

**Talking point**: "In traditional Delphi web frameworks, a single JSON response might allocate 5-6 temporary strings. In Dext, the response goes from the database driver to the socket with zero intermediate string allocations."

---

## 🏆 Feature 4: Integrated Testing Ecosystem (3 min)

**What it is**: A complete testing toolkit designed to work with the DI container and ORM.

**Why it's unique**: `TAutoMocker<T>` and `MatchSnapshot` don't exist in any other Delphi testing framework.

### Auto-Mocking Container
```pascal
var OrderServiceMocker := TAutoMocker<TOrderService>.Create;

// All dependencies are automatically mocked
OrderService := OrderServiceMocker.Mock<IOrderRepository>
  .Setup.WillReturn(TOrder.Create);

var OrderService := OrderServiceMocker.CreateInstance;
```

### Snapshot Testing
```pascal
Assert.MatchSnapshot(ComplexObject);
// First run: saves JSON baseline
// Subsequent runs: compares against baseline
// Failed? Run with --update-snapshots to accept changes
```

### Full Pipeline
```
Code → Unit Tests + Mocking → Auto-Mocking (TAutoMocker)
     → Snapshot Testing → Code Coverage (dext test --coverage)
     → Reports: JUnit XML, TRX (Azure DevOps), SonarQube, HTML
     → Live Dashboard (dext ui)
```

---

## 🏆 Feature 5: Collections (3 min)

**What it is**: Data structures from .NET 8, Go, and Java that were never available in Delphi.

| Collection | Inspiration | What It Does |
|---|---|---|
| `TFrozenDictionary<K,V>` | .NET 8 | Immutable, optimized for read-heavy workloads |
| `TFrozenSet<T>` | .NET 8 | Immutable set with O(1) lookup |
| `TChannel<T>` | Go Channels | Bounded/unbounded producer-consumer with back-pressure |
| `TConcurrentDictionary<K,V>` | .NET | Lock-striped with `TSpinLock` array |
| `TObservableCollection<T>` | .NET WPF | `OnChanged` events for UI binding |
| SIMD Algorithms | — | AVX2/SSE2-accelerated byte comparison |

**Talking point**: "These aren't academic exercises. `TChannel<T>` is what you use for producer-consumer patterns instead of rolling your own thread-safe queue. `TFrozenDictionary` is what configuration caches should use — optimized for millions of reads."

---

## 🏆 Feature 6: Modern Patterns (3 min)

Quick-fire round of patterns that don't exist in other Delphi frameworks:

| Pattern | What It Does |
|---|---|
| **Minimal API** (`App.MapGet`) | .NET-style route registration without controllers |
| **Hybrid DI** (ARC + Manual) | Interfaces use ARC, classes use managed lifecycle |
| **IOptions<T>** | Typed configuration binding from JSON/YAML/ENV — identical to ASP.NET Core |
| **IHostedService** | Background services with DI scope, cancellation, and lifecycle |
| **TAsyncTask** | Fluent async/await with `ThenBy`, `OnComplete`, `OnException`, `Cancellation` |
| **IDeferred** (Go-style `defer`) | Cleanup actions executed in reverse LIFO order |
| **ILifetime\<T\>** | Wraps non-ARC objects in ARC containers |
| **SignalR Hubs** | Real-time messaging with groups and user targeting |
| **AST Template Engine** | Parser → AST → Executor with layouts, partials and inheritance |
| **Flyweight Iterators** | O(1) memory rendering — stream 10,000 DB rows to HTML without `ToList` |
| **HTMX Detection** | Auto-suppresses layout for `HX-Request` headers |
| **Soft Delete** | `[SoftDelete]` attribute → `Remove` becomes UPDATE, `Restore`, `OnlyDeleted`, `IgnoreQueryFilters` |
| **JSON/JSONB Queries** | `.Json('path')` — query inside JSON columns, cross-database (PG, MySQL, SQLite, MSSQL) |
| **ProblemDetails (RFC 9457)** | Standardized error responses |
| **Health Checks** | Structured health monitoring endpoints |
| **Rate Limiting** | Fixed Window, Sliding Window, Token Bucket, Concurrency |
| **Multi-Tenancy** | 3 strategies: Column, Schema, Database |
| **TPH Inheritance** | Polymorphic hydration with discriminator |

---

## 🏆 Feature 7: Not Just Web — Desktop, Networking & AI (3 min)

**Dext is not a web-only framework.** It provides the same modern patterns for Desktop and Networking.

### Desktop UI: Navigator + Magic Binding

```pascal
// Flutter-style navigation with middleware pipeline
Navigator.Push(TCustomerEditFrame, TValue.From(Customer));
Navigator.Pop;
Navigator.PopUntil(THomeView);

// Declarative binding — no more OnChange handlers
[BindEdit('Name')]   NameEdit: TEdit;
[BindEdit('Email')]  EmailEdit: TEdit;
[OnClickMsg(TSaveMsg)] SaveButton: TButton;
```

**Navigator features**: Push/Pop/Replace/PopUntil, 3 adapters (Container, PageControl, MDI), Auth middleware, lifecycle hooks (`INavigationAware`), DI integration.

**Magic Binding**: Two-way binding via attributes, nested properties (`Customer.Address.City`), custom converters (`IValueConverter`), message dispatch (`[OnClickMsg]`).

### EntityDataSet: Bridge ORM ↔ VCL

```pascal
DataSet.Load(Context.Users.ToList, TUser);  // Smart binding to TDBGrid
DataSet.LoadFromUtf8Json(Span, TUser);       // Zero-allocation from JSON buffer
```

**Design-time integration**: Right-click → Sync Fields / Refresh Entity. The IDE reads your entity source code and creates `TField` definitions — **without compiling the project**.

### REST Client with Connection Pooling

```pascal
var Client := TRestClient.Create('https://api.example.com');

// Typed deserialization + async chaining
Client.Get<TUser>('/users/1')
  .ThenBy<Boolean>(function(User: TUser): Boolean begin Result := User.IsActive end)
  .OnComplete(procedure(IsActive: Boolean) begin UpdateUI end)
  .Start;
```

**Connection pooling**, thread-safe, pluggable auth (`Bearer`, `Basic`, `ApiKey`), cancellation tokens.

### AI Skills: Teaching Your IDE About Dext

```
Docs/ai-agents/skills/
├── dext-web.md       # Web patterns
├── dext-orm.md       # ORM idioms
├── dext-auth.md      # Auth patterns
└── ...               # Modular, atomic
```

Dext ships with **native AI Skills** — instruction files that teach Cursor, Antigravity, Copilot, Claude and other AI assistants to generate idiomatic Dext code instead of legacy Delphi patterns.

**Talking point**: "We're not just building a framework — we're building the developer experience around it. Your AI assistant knows Dext."

---

# Part 3 — Why Dext Matters for the Delphi Ecosystem (10 min)

## 3.1 The Talent Problem

> *"My junior developers don't want to use Delphi because it feels old."*

This is the single biggest threat to the Delphi ecosystem. Young developers learn .NET, Spring Boot, Express.js — and when they see Delphi code with manual memory management, DataModules, and string-based queries, they see a legacy language.

**Dext makes Delphi feel modern.** A developer who knows ASP.NET Core can pick up Dext in an afternoon. The patterns are the same: DI, middleware pipelines, minimal APIs, ORM with change tracking, expression trees.

**This is how you keep developers using Delphi.**

## 3.2 The Ecosystem Gap

The Delphi ecosystem has excellent individual components:

| Need | Available Solutions |
|---|---|
| DI Container | Spring4D |
| ORM | mORMot, Aurelius |
| REST Framework | Horse, MARS, RAD Server |
| JSON | JsonDataObjects, System.JSON |
| Testing | DUnitX, TestInsight |

**The problem**: None of these were designed to work together. You spend weeks integrating them, handling edge cases, and bridging APIs.

**Dext fills the gap** by providing a **single, coherent platform** where:
- The DI container knows about the ORM lifecycle
- The JSON engine shares the RTTI cache with the model binder
- The test framework can mock DI services automatically
- The template engine works in CLI scaffolding AND web rendering
- The expression trees work in ORM queries AND in-memory filtering

**This is what .NET has and Delphi didn't.** Until now.

## 3.3 The Performance Argument

> *"If I need performance, I use Delphi. If I need productivity, I use .NET."*

Dext eliminates this false choice. You get:
- **Delphi's native compilation speed**
- **Zero-allocation pipeline** (something even ASP.NET doesn't have by default)
- **SIMD-accelerated operations** (AVX2/SSE2)
- **.NET-level productivity** (DI, ORM, Minimal API, Auto-Mocking)

**Talking point**: "Dext doesn't just match .NET's developer experience — in some areas like zero-allocation pipelines and SIMD-accelerated collections, it goes further. Because Delphi compiles to native code, there's no GC pause, no JIT warmup. It's the best of both worlds."

## 3.4 The Community Argument

- **Apache 2.0 License** — Same license as .NET Core. Free for commercial use.
- **Open Source** — Full source code, no black boxes.
- **Modern Toolchain** — CLI, package management, code coverage, CI/CD integration.
- **Documentation** — Book, API reference, examples in 3 languages (PT, EN, ES).

**Talking point**: "Dext is the framework that the Delphi community has been asking for. Not a commercial component with a per-developer license. A community-driven, open-source platform that makes Delphi competitive with modern stacks."

## 3.5 The Infrastructure Flywheel

> *"New features used to take weeks. Now they take days — because the infrastructure already knows how to do most of it."*

This is the hidden superpower of integrated architecture. When the foundation is mature, new features **compose from existing engines**:

```
Specification Engine (built for ORM)
  → Reused by DataApi (dynamic filtering — "free")
  → Reused by In-Memory Evaluator (zero extra code)

Reflection Cache S07 (built for JSON)
  → Reused by ORM mapping
  → Reused by Model Binding
  → Reused by Validation
  → Reused by EntityDataSet

TByteSpan (built for zero-allocation)
  → Reused by JSON Reader/Writer
  → Reused by EntityDataSet.LoadFromUtf8Json
  → Will be reused by Redis RESP3 parser (~80% ready)
```

**Real example**: When I analyzed whether to implement a Redis client, I discovered that **~80% of the infrastructure already existed** — `TByteSpan` for protocol parsing, `TAsyncTask` for async I/O, `TConnectionPool` for connection management, `ICancellationToken` for timeouts. The only new code needed is the RESP3 wire protocol.

**The trade-off**: This integration power comes with a responsibility multiplier. Every change to a core engine (like `IExpression`) must be validated across **every consumer** — ORM, DataApi, Evaluator, EntityDataSet filters. That's why Dext invests heavily in automated testing: 165+ tests across 5 databases aren't optional — they're survival.

**Talking point**: *"In isolated libraries, a bug affects one thing. In an integrated platform, a bug in the expression engine could affect queries, API filtering, AND in-memory evaluation simultaneously. That's why we test everything end-to-end, on every database, on every commit. The integration is the product — and testing the integration is non-negotiable."*

## 3.6 The Business Case

For decision-makers choosing a technology stack:

| Concern | What Dext Provides |
|---|---|
| **"Can we hire developers?"** | Patterns identical to .NET — any C# developer adapts quickly |
| **"Is it maintained?"** | Active development, 14+ specs delivered, clear roadmap |
| **"Is it production-ready?"** | Beta status, 165+ tests across 5 databases |
| **"Can we extend it?"** | Driver pattern for JSON, HTTP Server, Database |
| **"Does it scale?"** | Zero-allocation pipeline, SIMD, connection pooling |
| **"Can we test it?"** | Auto-mocking, snapshot testing, code coverage |

---

# Part 4 — Roadmap & Vision (5 min)

## What's Done (V1.0 Beta)
- ✅ Web Framework (Minimal API + Controllers + 3 Server Adapters + SSR + HTMX)
- ✅ ORM (6 databases, migrations, multi-tenancy, TPH, JSON/JSONB, Soft Delete)
- ✅ DI Container (Hybrid ARC/Manual + IOptions<T> + Background Services)
- ✅ Smart Properties (Expression Trees + Dual-Mode AST)
- ✅ Database as API (11 filters, security, Swagger, telemetry)
- ✅ Template Engine (AST-based, 6 phases, Flyweight Iterators, HTMX)
- ✅ Testing (Auto-Mocking, Snapshots, Code Coverage, 5 report formats)
- ✅ Real-Time (Hubs, SSE, Groups, User Targeting)
- ✅ Observability (TDiagnosticSource + Telemetry Bridge)
- ✅ CLI (Scaffolding, Migrations, Test Runner)
- ✅ High-Performance Reflection (S07)
- ✅ Desktop UI (Navigator, Magic Binding, MVVM, EntityDataSet)
- ✅ REST Client (Connection Pooling, Async Chaining, Cancellation)
- ✅ Configuration (JSON/YAML/ENV, IOptions<T>, Environment-based)
- ✅ AI Skills (IDE assistant integration for idiomatic code generation)

## What's Coming (V1.0 Stable → V2.0)
- 🟡 **gRPC & Protobuf** — Native IOCP/EPOLL binary transport
- 🟡 **SOA via Interfaces** — Define Delphi interfaces, get RPC for free
- 🟡 **OAuth2 & OIDC** — Native Google/Microsoft login
- 🔴 **Redis Client** — Async RESP3 + RedisJSON
- 🔮 **Native HTTP Server** — IOCP/EPOLL/Kqueue (no Indy dependency)
- 🔮 **OData / GraphQL** — Query protocols
- 🔮 **Microservices Mesh** — Service discovery + load balancing

## The Vision

> *"Every modern platform has a canonical framework. Java has Spring. .NET has ASP.NET Core. Python has Django/FastAPI. Go has its standard library.*
>
> *Delphi deserves the same. Dext is that framework."*

---

# 🎤 Q&A Preparation — Likely Questions

| Question | Suggested Answer |
|---|---|
| **"How does Dext compare to mORMot?"** | mORMot is excellent for raw performance and SOA. Dext focuses on DX (developer experience) and ecosystem integration. They solve different problems — mORMot is a toolkit, Dext is a platform. |
| **"Why not just use Horse?"** | Horse is great for simple REST APIs. Dext provides the full stack: DI, ORM, testing, real-time, CLI. It's ASP.NET Core vs Express.js. |
| **"Is it stable enough for production?"** | Beta status with 165+ tests across 5 databases. APIs are stable, minor breaking changes possible before V1.0 final. |
| **"Performance vs RAD Server?"** | Zero-allocation pipeline + SIMD + native compilation. No comparison. |
| **"Can I use it with existing VCL apps?"** | Absolutely — EntityDataSet bridges Dext ORM with VCL data-aware controls including design-time field sync. Navigator brings Flutter-style navigation to VCL. Magic Binding eliminates OnChange boilerplate. DI container works in any Delphi application. |
| **"What Delphi version is required?"** | 10.4+ (requires operator overloading on records, inline variables). Recommended: 12.x. Web Stencils integration requires 12.2+. |
| **"How many people work on this?"** | Started as a solo project, now accepting community contributions. The architecture was designed by studying years of .NET, Go, and Java best practices. |
| **"Can I use just the ORM without the web framework?"** | Yes, every module is independent. You can use DI + ORM in a desktop app, just Collections in a console tool, or the REST Client standalone. |
| **"Does it support full-stack web (not just API)?"** | Yes — SSR with the Dext Template Engine (Razor-style) or Web Stencils (Delphi 12.2+). Flyweight Iterators stream DB results with O(1) memory. Built-in HTMX detection for partial rendering. |
| **"How does the ORM handle JSON columns?"** | Native `[JsonColumn]` attribute with cross-database `.Json('path')` queries — PostgreSQL (`#>>`), MySQL (`JSON_EXTRACT`), SQLite (`json_extract`), SQL Server (`JSON_VALUE`). |

---

# 📎 Resources to Share During Webinar

- **GitHub**: `github.com/cesarliws/dext` (or actual URL)
- **Documentation Book**: Available in PT, EN, ES
- **Examples**: `Examples/` folder with working projects
- **License**: Apache 2.0
- **Roadmap**: `Docs/ROADMAP.md`

---

# 💎 Hidden Gems — Quick Demo Ideas (If Time Permits)

These are small features that create "wow" moments in a live demo:

| Feature | Demo | Time |
|---|---|---|
| **Soft Delete** | Add `[SoftDelete('IsDeleted')]` → `.Remove()` becomes UPDATE → `.OnlyDeleted.ToList` shows trash | 30s |
| **JSON Column Query** | `.Where(Prop('Settings').Json('role') = 'admin')` → shows SQL generated per database | 30s |
| **Configuration** | `Services.Configure<TDbOptions>(Config.GetSection('Database'))` → change ENV var → restart → different DB | 45s |
| **Flyweight Streaming** | Pass `Db.Customers.QueryAll` to `Results.View<T>` → show 10K rows rendered with O(1) memory | 45s |
| **EntityDataSet Design-Time** | Right-click → Sync Fields → TDBGrid populates from entity metadata without compiling | 30s |
| **REST Client Chaining** | `Client.Get<TToken>('/auth').ThenBy<TUser>(...).OnComplete(...)` → shows fluent async | 30s |
| **Telemetry Bridge** | Enable `CaptureTelemetry: true` → show SQL + HTTP timing in console live | 30s |
| **Navigator Middleware** | Add `TAuthMiddleware` → navigate to protected view → get blocked | 30s |

---

*Document prepared for the Embarcadero Webinar with Ian Barker.*
*Last update: April 22, 2026*
