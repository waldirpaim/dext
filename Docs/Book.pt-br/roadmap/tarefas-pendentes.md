# 📋 Dext Framework: Tarefas Pendentes (Backlog V1 Stable)

Este documento lista as funcionalidades e correções necessárias para o lançamento da versão 1.0 estável.

## 🟢 Onda 1: Quick Wins & Visibilidade (Imediato)
Status | Tarefa | Descrição
:---: | :--- | :---
✅ | **Portas Dinâmicas** | Suporte a Porta 0 (SO escolhe porta livre) para Demos e CI.
✅ | **Convenções DataAPI (S04)** | Auto-discovery, remover prefixo 'T' e Smart Attributes.
✅ | **Observabilidade DataAPI** | Logs de diagnóstico CRUD e rastreamento de mapeamento.
🟡 | **Roadmap de Exemplos** | Criar exemplos de alta fidelidade para features existentes.
🟡 | **Agent Guidelines** | Finalizar o `CONTRIBUTING_AI.md` e Workflows.

---

## 🔵 Onda 2: Performance & Produtividade (Fundação)
Status | Tarefa | Descrição
:---: | :--- | :---
🔴 | **High-Perf Reflection (S07)** | Registry de Handlers para eliminar overhead de RTTI/TValue.
🟡 | **Scaffolding Avançado (S01)** | Novo motor de templates CLI (`dext new`, `dext add`).
🟡 | **Dext IDE Explorer (S05)** | Ferramenta visual inicial para Migrations na IDE.
🟡 | **Middleware Pack** | SPA Fallback, Forwarded Headers e Resiliência.

---

## 🔴 Onda 3: Enterprise & Modernização (Estabilidade)
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **gRPC & Protobuf (S02)** | Motor nativo IOCP/EPOLL para comunicação binária.
🟡 | **OAuth2 & OIDC (S06)** | Suporte nativo a JWT, Google/Microsoft Login.
🔴 | **Tracing Distribuído (S03)** | Dashboard de instrumentação em tempo real.
🔴 | **Provider de EntityDataSet** | Providers plugáveis (REST/gRPC) para o EntityDataSet.

---

## 🔮 Futuro / Pós-V1
- [ ] **Suporte a OData**: Suporte completo a queries OData.
- [ ] **GraphQL**: Camada nativa para exposição de grafos de dados.
- [ ] **Microservices Mesh**: Service discovery e Load Balancing nativo.

---
*Última atualização: 12 de Abril de 2026*
