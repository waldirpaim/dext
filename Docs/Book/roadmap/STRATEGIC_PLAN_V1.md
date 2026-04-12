# 🚁 Dext Framework: Strategic Execution Plan (V1.0 Stable)

**Author:** Antigravity (AI Project Manager)  
**Target:** Dext Engineering Team  
**Focus:** Commercial Readiness, Performance, and Ecosystem Growth

---

## 🏗️ Executive Summary

Following the professionalization of the Dext Framework codebase and documentation (RC 1.0), the project must now transition from a "Developer's Tool" to a "Production-Ready Ecosystem." This plan outlines four strategic pillars (Work Packets) designed to ensure high-fidelity adoption, proven performance, and long-term sustainability.

---

## 🏁 Pillar 1: The "North Star" (Performance & Evidence)
Dext's ultimate competitive advantage is native Object Pascal performance combined with .NET-style productivity. We must move from subjective claims to objective, verifiable data.

### 📋 Key Objectives:
- [ ] **Establish Dext.Benchmarks**: A dedicated repository or module for standardized performance testing.
- [ ] **Competitive Matrix**: Benchmarking "Hello World" (throughput/latency) and JSON Serialization against **ASP.NET Core 8**, **Go (Fiber)**, and **Delphi (Horse/Mars)**.
- [ ] **ORM Stress Testing**: Bulk-insert validation (100k+ rows) and complex hydration (Joins/Nested) comparison against vanilla FireDAC and ADO.
- [ ] **The Baseline Report**: A technical whitepaper published in the `/Docs` directory documenting these results.

> **Rationale**: Proof of performance is the single most effective tool for convincing CTOs and Architects to adopt a new framework for legacy modernization.

---

## 🛡️ Pillar 2: The "Safety Net" (Industrial-Grade QA)
To support critical enterprise applications, Dext must prove stability across a heterogeneous matrix of environments.

### 📋 Key Objectives:
- [ ] **The "Matrix" (Docker-Compose)**: A standardized Docker environment to spin up all supported databases (SQL Server, Postgre, MySQL, Firebird) simultaneously for local development and CI.
- [ ] **Cross-Database Integration Testing**: Execute the 165+ test suite against the entire matrix automatically.
- [ ] **End-to-End (E2E) Web Scenarios**: Validate real-world HTTP traffic including large binary uploads, GZip compression, and complex Cookie/JWT auth flows.
- [ ] **The 24h Soak Test**: Run an Indy/WebBroker server under sustained load for 24 hours to monitor memory heap and handle fragmentation.

---

## 📥 Pillar 3: The "Onboarding" (Frictionless Day 1)
High friction in the first 5 minutes results in 80% developer drop-off. We must make the start-up path effortless.

### 📋 Key Objectives:
- [ ] **Advanced Scaffolding**: Modular templates using the new template processor for Startup, Entities, Minimal APIs, Controllers, and Swagger.
- [ ] **Tooling & Package Support**: Implement or formalize support for **Boss** (Delphi package manager) and **TMS Smart Setup**.
- [ ] **Dext CLI (Doctor)**: Implement `dext doctor` to verify Environment Variables, Library Path, and binary compatibility.
- [ ] **Template Parity**: High-feature templates compatible with both Web Stencils (D12.2+) and "Native/Legacy" Delphi versions.
- [ ] **CONTRIBUTING_AI.md**: Create specific guidelines to help other AI assistants (Claude, GPT, Codex) contribute to Dext following the strict architectural rules set in the Skills.

---

## 🖥️ Pillar 4: The "Ecosystem" (Dext.UI & Visuals)
Backend developers in the Delphi world often lead to Desktop UI projects. Strengthening the UI layer bridges the gap between API and Application.

### 📋 Key Objectives:
- [ ] **Navigator Authorization**: Implement functional middlewares in the Navigator (e.g., `OnBeforeNavigate` checks for roles/auth).
- [ ] **Magic Binding Performance**: Audit and optimize two-way binding for large-scale VCL forms (100+ bound inputs).
- [ ] **Rich Visuals**: Create native Dext.UI components for common modern patterns: Toasts, Notification Overlays, and Dark/Light mode synchronization.

---

## 📡 Pillar 5: The "Modernizer" (gRPC, Observability & DataProviders)
Disrupting the legacy Delphi connectivity market by providing high-speed, modern alternatives to DataSnap, RDW, and RemObjects.

### 📋 Key Objectives:
- [ ] **gRPC & Protobuf Integration**: High-speed binary transport layer for cross-platform and remote services.
- [ ] **TEntityDataSet & DataProviders**: Native integration of `TEntityDataSet` with both REST and gRPC providers for "Drop-in" legacy replacement in VCL/FMX.
- [ ] **Distributed Tracing & Dashboard**: Implementation of instrumentation (via dynamic proxies) for real-time tracing of SQL, Requests, and Exceptions.
- [ ] **PDF Engine & Signing**: Utility module for signed PDF generation (ERP-focused).

---

## 📅 Roadmap to Stable

1.  **Phase A (The Evidence)**: Pillar 1 (Benchmarks) + Pillar 2 (Matrix Setup).
2.  **Phase B (The Experience)**: Pillar 3 (Advanced Scaffolding) + Documentation Technical Review.
3.  **Phase C (The Modernizer)**: Pillar 5 (Protobuf/gRPC Alpha) + Distributed Tracing MVP.
4.  **Phase D (The Polish)**: Pillar 4 (UI Refresh) + Final RC Audit.

---
*Document generated by Antigravity AI - April 2026*
