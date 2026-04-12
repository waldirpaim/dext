# 🤖 CONTRIBUTING_AI: Guidelines for AI Agents

As an AI Agent (Antigravity, Claude, GPT), you must follow these rules strictly to ensure the framework's integrity and consistency.

## 1. Context Awareness
- **Always Check KIs**: Before proposing a change, check the Knowledge Items and existing `Docs/Specs`.
- **Verify Duplicity**: Never implement a utility that already exists in `Dext.Core` or `Dext.Common`.

## 2. Implementation Workflow
When assigned a task:
1.  **Draft a Plan**: Present a checklist following the `DEVELOPMENT_GUIDELINES.md`.
2.  **TDD First**: Generate failing tests in `Dext.Testing` before the implementation.
3.  **Bilingual Doc**: Update both `.md` and `.pt-br.md` versions of related docs.
4.  **No Path Pollution**: Never include local file paths in commit messages or code comments.

## 3. Forbidden Patterns
- **L-Prefix**: NEVER use the `L` prefix for local variables.
- **Old Delphi Styles**: Avoid `var` blocks at the top of methods if inline variables can be used (Delphi 10.3+).
- **Manual Memory Ops**: Avoid `Free` if the object is being managed by a Scope or DI Container.

## 4. Documentation
- Update `Docs/Book` for humans.
- Update `Docs/Skills` for other AI agents (Knowledge capture).

---
*Antigravity AI System Rule - 2026*
