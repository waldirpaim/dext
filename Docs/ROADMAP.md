# ðŸ—ºï¸ Dext Framework: Master Roadmap

This is the centralized roadmap for the Dext Framework. It tracks the progress of core features, architectural specifications, and the path to the V1.0 Stable release.

> [!TIP]
> This document is the Single Source of Truth for project status. Individual language-specific guides in the Book point here.

---

# ðŸ‡¬ðŸ‡§ English: Roadmap & Backlog

## ðŸŸ¢ Wave 1: Quick Wins & Visibility (Immediate)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
âœ… | **Dynamic Port Binding** | [S08](Specs/S08-Dynamic-Ports.md) | Support for Port 0 (OS chooses free port) for Demos and CI.
âœ… | **DataAPI Conventions** | [S04](Specs/S04-DataApi-Conventions.md) | Auto-discovery, 'T' prefix stripping, and Smart Attributes.
âœ… | **DataAPI Observability** | - | CRUD diagnostic logs and mapping tracking.
ðŸŸ¡ | **Examples Roadmap** | [Ref](roadmap/EXAMPLES_ROADMAP.md) | Create high-fidelity examples for existing features.
ðŸŸ¡ | **Agent Guidelines** | [AI](CONTRIBUTING_AI.md) | Finalize `CONTRIBUTING_AI.md` and related Workflows.

## ðŸ”µ Wave 2: Performance & Productivity (Foundation)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
âœ… | **High-Perf Reflection** | [S07](Specs/S07-High-Perf-Reflection.md) | Thread-safe RTTI cache with lock-free fast paths, zero-boxing type handlers, and ISO 8601 date binding.
âœ… | **Advanced Scaffolding** | [S01](Specs/S01-Advanced-Scaffolding.md) | New CLI template engine (`dext new`, `dext add`).
âœ… | **Template Engine** | [S09](Specs/S09-Template-Engine.md) | Zero-dependency AST-based template engine (Razor-like).
✅ | **Advanced Template Engine** | [S12](Specs/S12-Template-Engine-Advanced.md) | Phases 1-6 complete: layouts, partials, inheritance, AST cache, smart positions, @encoded, and high-performance TDataSet/Streaming iterators.
âœ… | **Schema Migrations** | [S11](Specs/S11-Migration-Finalization.md) | Attribute-based renaming detection and CLI automation.
ðŸŸ¡ | **Dext IDE Explorer** | [S05](Specs/S05-Advanced-Tooling.md) | Initial visual tool for Migrations inside the IDE.
ðŸŸ¡ | **Production Middleware** | - | SPA Fallback, Forwarded Headers, and Resilience.

## ðŸ”´ Wave 3: Enterprise & Modernization (Stability)
Status | Task | Spec | Description
:---: | :--- | :---: | :---
ðŸŸ¡ | **gRPC & Protobuf** | [S02](Specs/S02-Modernizer-gRPC.md) | Native IOCP/EPOLL engine for high-speed binary communication.
ðŸŸ¡ | **OAuth2 & OIDC** | [S06](Specs/S06-Security-Identity.md) | Native support for JWT, Google, and Microsoft Login.
âœ… | **Live Tracing (Core)** | [S03](Specs/S03-Live-Observability.md) | Real-time instrumentation infrastructure (TDiagnosticSource).
ðŸŸ¡ | **Observability Dashboard**| - | Built-in web UI for real-time log and SQL visualization.
ðŸ”´ | **EntityDataSet Providers** | - | Pluggable providers (REST/gRPC) for EntityDataSet.
ðŸ”´ | **Redis Client (Dext.Redis)** | [S13](Specs/S13-Redis-Client.md) | High-performance async Redis client with RESP3 and RedisJSON support.

## ðŸ”® Future / Post-V1
- [ ] **OData Support**: Full OData query support.
- [ ] **GraphQL**: Native layer for data graphs.
- [ ] **Microservices Mesh**: Service discovery and native Load Balancing.

---

# ðŸ‡§ðŸ‡· PortuguÃªs: Roadmap & Backlog

## ðŸŸ¢ Onda 1: Quick Wins & Visibilidade (Imediato)
Status | Tarefa | Spec | DescriÃ§Ã£o
:---: | :--- | :---: | :---
âœ… | **Portas DinÃ¢micas** | [S08](Specs/S08-Dynamic-Ports.md) | Suporte a Porta 0 (SO escolhe porta livre) para Demos e CI.
âœ… | **ConvenÃ§Ãµes DataAPI** | [S04](Specs/S04-DataApi-Conventions.md) | Auto-discovery, remover prefixo 'T' e Smart Attributes.
âœ… | **Observabilidade DataAPI** | - | Logs de diagnÃ³stico CRUD e rastreamento de mapeamento.
ðŸŸ¡ | **Roadmap de Exemplos** | [Ref](roadmap/EXAMPLES_ROADMAP.md) | Criar exemplos de alta fidelidade para features existentes.
ðŸŸ¡ | **Agent Guidelines** | [AI](CONTRIBUTING_AI.md) | Finalizar o `CONTRIBUTING_AI.md` e Workflows.

## ðŸ”µ Onda 2: Performance & Produtividade (FundaÃ§Ã£o)
Status | Tarefa | Spec | DescriÃ§Ã£o
:---: | :--- | :---: | :---
âœ… | **High-Perf Reflection** | [S07](Specs/S07-High-Perf-Reflection.md) | Cache de RTTI thread-safe com fast paths lock-free, handlers sem boxing e binding ISO 8601.
âœ… | **Scaffolding AvanÃ§ado** | [S01](Specs/S01-Advanced-Scaffolding.md) | Novo motor de templates CLI (`dext new`, `dext add`).
âœ… | **Motor de Templates** | [S09](Specs/S09-Template-Engine.md) | Motor de templates baseado em AST, zero dependÃªncia (estilo Razor).
✅ | **Motor de Templates Avançado** | [S12](Specs/S12-Template-Engine-Advanced.md) | Fases 1-6 completas: layouts, partials, herança, cache de AST, posições inteligentes, @encoded e iteradores TDataSet/Streaming de alta performance.
âœ… | **Migrations de Schema** | [S11](Specs/S11-Migration-Finalization.md) | DetecÃ§Ã£o de renomeaÃ§Ã£o por atributos e automaÃ§Ã£o CLI.
ðŸŸ¡ | **Dext IDE Explorer** | [S05](Specs/S05-Advanced-Tooling.md) | Ferramenta visual inicial para Migrations na IDE.
ðŸŸ¡ | **Middleware Pack** | - | SPA Fallback, Forwarded Headers e ResiliÃªncia.

## ðŸ”´ Onda 3: Enterprise & ModernizaÃ§Ã£o (Estabilidade)
Status | Tarefa | Spec | DescriÃ§Ã£o
:---: | :--- | :---: | :---
ðŸŸ¡ | **gRPC & Protobuf** | [S02](Specs/S02-Modernizer-gRPC.md) | Motor nativo IOCP/EPOLL para comunicaÃ§Ã£o binÃ¡ria.
ðŸŸ¡ | **OAuth2 & OIDC** | [S06](Specs/S06-Security-Identity.md) | Suporte nativo a JWT, Google/Microsoft Login.
âœ… | **Live Tracing (Core)** | [S03](Specs/S03-Live-Observability.md) | Infraestrutura de instrumentaÃ§Ã£o em tempo real.
ðŸŸ¡ | **Dashboard Log Live** | - | Interface web para visualizaÃ§Ã£o de logs e SQL em tempo real.
ðŸ”´ | **Provider de EntityDataSet** | - | Providers plugÃ¡veis (REST/gRPC) para o EntityDataSet.
ðŸ”´ | **Redis Client (Dext.Redis)** | [S13](Specs/S13-Redis-Client.md) | Client Redis async de alta performance com suporte a RESP3 e RedisJSON.

## ðŸ”® Futuro / PÃ³s-V1
- [ ] **Suporte a OData**: Suporte completo a queries OData.
- [ ] **GraphQL**: Camada nativa para exposiÃ§Ã£o de grafos de dados.
- [ ] **Microservices Mesh**: Service discovery e Load Balancing nativo.

- HTTP Server nativo IOCP, EPOLL, Kqueue
- UI Nativo com Skia

---
*Last update: April 17, 2026*

