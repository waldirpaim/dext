# ðŸ“‘ Dext Framework: Engineering Specifications

This directory contains the formal technical specifications and requirements for the Dext Framework evolution. Each "Spec" defines the architecture, user experience (CLI/API), and implementation constraints for a core feature.

## ðŸš€ Active Specifications

ID | Title | Status | Goal
:---: | :--- | :---: | :---
**S01** | [Advanced Scaffolding](S01-Advanced-Scaffolding.md) | âœ… Finalized | Automate the creation of Startups, Entities, and Endpoints using templates.
**S02** | [Modernizer: gRPC & Protobuf](S02-Modernizer-gRPC.md) | ðŸ“ Draft | High-speed binary communication as a legacy replacement for DataSnap/RDW.
**S03** | [Live Observability Dashboard](S03-Live-Observability.md) | ðŸŸ¡ In Progress | Real-time debugging of SQL, HTTP and Exceptions via Telemetry.
**S04** | [DataAPI Conventions](S04-DataApi-Conventions.md) | âœ… Finalized | Simplify REST endpoint exposure using attributes and global defaults.
**S05** | [Advanced Tooling](S05-Advanced-Tooling.md) | ðŸ“ Draft | IDE Wizards, Code-First Parsers, and UI-driven scaffolding.
**S06** | [Security & Identity](S06-Security-Identity.md) | ðŸ“ Draft | Native OAuth2, OpenID Connect, and JWT policy-based authorization.
**S07** | [High-Performance Reflection](S07-High-Performance-Reflection.md) | âœ… Finalized | Zero-boxing type handlers, fast-path reflection registry, and thread-safe RTTI caches.
**S08** | [Dynamic Ports](S08-Dynamic-Ports.md) | âœ… Finalized | Support for Port 0 (OS picks free port) for Demos and CI.
**S09** | [Template Engine](S09-Template-Engine.md) | âœ… Finalized | Zero-dependency AST-based template engine (Razor-like).
**S11** | [Migration Audit & Finalization](S11-Migration-Finalization.md) | âœ… Finalized | Safe schema evolution with renaming detection and CLI automation.
**S12** | [Advanced Template Engine](S12-Template-Engine-Advanced.md) | ✅ Finalized | Phases 1-6 complete: layouts, partials, inheritance, AST cache, smart positions, @encoded, and high-performance TDataSet/Streaming iterators.
**S13** | [Redis Client](S13-Redis-Client.md) | ðŸ“ Draft | High-performance async Redis client with RESP3 and RedisJSON support.

---

## ðŸ” Project Status & Roadmap
For a high-level view of all roadmap items and their current waves, see the [Master Roadmap](../ROADMAP.md).

---

## ðŸ—ï¸ Spec Maturity Levels
1. **Draft**: Conceptual stage, requirements gathering.
2. **Review**: Architectural design refined, seeking feedback.
3. **Approved**: Ready for implementation.
4. **Implementing**: Currently being developed.
5. **Finalized**: Feature delivered and documented in the Book.

---
*Last update: April 17, 2026*

