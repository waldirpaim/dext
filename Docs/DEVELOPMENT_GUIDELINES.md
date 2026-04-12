# 🏗️ Dext Framework: Development Guidelines

This document defines the architectural and coding standards for all contributors (Human and AI) to the Dext Framework.

## 1. Fluent DSL & Naming
We follow a modern "dotpas" DSL style. 
- **No "With" Prefixes**: Avoid redundant prefixes like `WithColor`. Use the property name directly as a method: `.Color(clRed)`.
- **Record Builders**: Use **Records** for configuration builders to avoid unnecessary allocations and separate them from Service classes.
- **Service Interfaces**: Core services should be interface-based to allow for Dependency Injection and Mocking.

## 2. Memory & Performance
- **Zero Leaks**: Every feature must be checked for memory leaks. Use the Dext Testing suite with leak detection active.
- **Zero-Allocation Parsing**: Prioritize usage of `TSpan<T>` (from `Dext.Core.Types`) for data manipulation.
- **Avoid Over-Generics**: Use Generics where they add value, but avoid excessive nesting that increases compilation time.

## 3. Implementation Rules
Every new feature MUST:
1.  Have a corresponding **technical specification** (Spec) in `/Docs/Specs`.
2.  Be verified against current source code to avoid duplication.
3.  Include **Unit Tests** using `Dext.Testing` only.
4.  Maintain **Bilingual Documentation** (EN/PT-BR) in the Dext Book.
5.  Update the **Features Implemented Index**, **Changelog**, and **Roadmap**.

## 4. Source Code Standards
- **Indentation**: 2 spaces.
- **Bilingual Source**: Comments in English. Identifier names in English.
- **Attributes**: Use PascalCase for Attribute names.

---
*Created: April 2026*
