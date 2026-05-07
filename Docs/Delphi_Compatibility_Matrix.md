# Dext Framework: Delphi Compatibility Matrix

This document defines the minimum supported Delphi versions for the Dext Framework and maps specific features to the required compiler and RTL versions.

## 1. Version Support Overview

| Version Tier | Delphi Versions | Support Level | Notes |
| :--- | :--- | :--- | :--- |
| **Tier 1 (Main)** | 10.4 Sydney to 12 Athens | Full Support | Primary development and testing environment. |
| **Tier 2 (Legacy)** | 10.1 Berlin to 10.3 Rio | Supported | No inline variables. Uses `Dext.Threading.Sync` for backported locking. |
| **Tier 3 (Extended)** | XE8 to 10 Seattle | Limited | Requires fallback for `[Weak]` attributes. NetHTTPClient available. |
| **Tier 4 (Minimal)** | XE7 | Experimental | Minimum for PPL and modern JSON `TryGetValue`. No NetHTTPClient. |

---

## 2. Feature vs. Version Mapping

| Feature | Min Delphi Version | Required For | Fallback / Workaround |
| :--- | :--- | :--- | :--- |
| **Generics & Anon Methods** | 2009 | Collections, DI, Reflection | None (Hard Requirement) |
| **Attributes & RTTI** | 2010 | DI, ORM, Web API | None (Hard Requirement) |
| **TInterlocked / Atomic** | XE | Collections, Sync | Manual ASM (Not implemented) |
| **PPL (Parallel Library)** | XE7 | `Dext.Threading.Async` | Simplified Task Runner |
| **JSON `TryGetValue<T>`** | XE7 | `Dext.Json` | Manual casting |
| **TNetHTTPClient** | XE8 | `Dext.Net.RestClient` | Indy (via `DEXT_FORCE_INDY`) |
| **System.Hash** | XE8 | Core Utils | Indy / Custom |
| **`[Weak]` Attribute** | 10.1 Berlin | ORM (Lazy Loading) | Manual reference management |
| **Inline Variables** | 10.3 Rio | Code Aesthetics | Refactored to scoped vars |
| **TLightweightMREW** | 10.4 Sydney | High-Perf Sync | `TSpinLock` / `TMREWSync` |
| **Managed Records** | 10.4 Sydney | Performance Ops | Traditional Records |

---

## 3. Technical Rationale for 10.1 Berlin Baseline

While Dext can be compiled on older versions with some effort, **Delphi 10.1 Berlin** is established as the recommended minimum floor for the following reasons:

1.  **Reference Counting Safety ([Weak])**: The ORM's Lazy Loading mechanism relies on the `[Weak]` attribute to prevent circular references between the `IDbContext` and entities. Without this, manual "breaking" of cycles would be required, increasing API complexity.
2.  **RTL Stability**: Modern `System.JSON` and `System.Net.HttpClient` reached a high level of maturity in the 10.x era.
3.  **Compiler Performance**: 10.1 introduced significant improvements to the compiler's handling of deep generic hierarchies, which are used extensively in Dext.Collections.

---

## 4. How to Support Older Versions (XE7 - 10 Seattle)

To compile Dext on versions earlier than 10.1, the following compiler directives must be configured in `Dext.inc`:

-   `DEXT_FORCE_INDY`: Replaces `TNetHTTPClient` with Indy for the REST Client.
-   `DEXT_LEGACY_SYNC`: Forces usage of `TSpinLock` instead of Sydney's concurrency primitives.
-   `DEXT_NO_WEAK`: Disables `[Weak]` attributes (Requires careful memory management in the ORM).

---

*Last Updated: May 2026*
