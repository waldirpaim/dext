# Dext in 15 Minutes — Embarcadero Webinar Demo

> **Purpose**: Live-coding demo project for the Embarcadero Webinar with Ian Barker.

## 🎯 What This Demo Covers

| Act | What You Show | Time |
|---|---|---|
| **Act 1** | `[DataApi]` → Swagger CRUD in seconds | 3 min |
| **Act 2** | Smart Properties → Same `IExpression` engine powers ORM AND DataApi | 3 min |
| **Act 3** | Telemetry → Live SQL + HTTP tracing in console | 2 min |
| **Act 4** | Testing → `TAutoMocker<T>` + Snapshot Testing | 3 min |

## 📁 Project Structure (Clean Architecture + DDD by Feature)

```
WebinarDemo/
├── WebinarDemo.dpr                     # Entry point
├── appsettings.json                    # Configuration (telemetry toggle)
│
├── Domain/                             # Domain Layer (Entities + Interfaces)
│   ├── Domain.Entities.pas             # TProduct entity with Smart Properties
│   └── Domain.Interfaces.pas           # IProductService interface
│
├── Infrastructure/                     # Infrastructure Layer (Data Access)
│   ├── Infra.Context.pas               # TAppDbContext (SQLite)
│   └── Infra.Services.pas              # TProductService implementation
│
├── Presentation/                       # Presentation Layer (API Configuration)
│   └── Presentation.Startup.pas        # TStartup: DI, Pipeline, DataApi, Swagger
│
└── Tests/                              # Test Project
    ├── WebinarDemo.Tests.dpr            # Test runner
    └── Tests.ProductService.pas         # TAutoMocker + Snapshot tests
```

## 🚀 How to Run

1. Open `WebinarDemo.dpr` in Delphi 12.x
2. Build & Run (F9)
3. Open browser → `http://localhost:5000/swagger`
4. Test CRUD via Swagger UI

## 🧪 How to Run Tests

1. Open `Tests/WebinarDemo.Tests.dpr`
2. Build & Run
3. Or via CLI: `dext test --coverage`

## 📋 Demo Script

See [Dext_In_15_Minutes.md](../Dext_In_15_Minutes.md) for the full presentation script.
