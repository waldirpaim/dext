# 📋 Dext V1.0 Stable - Tarefas Pendentes (Backlog)

Este documento centraliza as pendências técnicas e de ecossistema necessárias para declarar o **Dext Framework** como estável (V1.0).

---

## 🛠️ Qualidade de Código & Ecossistema
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **Scaffolding Avançado** | Novo motor de templates para Startup, Entidades, Endpoints e Controllers.
🟡 | **Paridade de Templates** | Templates de alta fidelidade para Web Stencils e Delphi Nativo.
🟡 | **Dext IDE Explorer** | Ferramenta visual para Migrations e Scaffolding na IDE.
🟡 | **OAuth2 & OIDC** | Suporte nativo a JWT e Social Login (Google/Microsoft).
🟡 | **Portas Dinâmicas** | Suporte a Porta 0 (SO escolhe porta livre) com descoberta pós-bind.
🟡 | **Agent Guidelines** | Finalizar o `CONTRIBUTING_AI.md` para orientar assistentes de IA.

---

## 🧪 Infraestrutura de Testes & QA
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **Docker-Compose Environment** | Ambiente pronto para subir todos os bancos de dados simultaneamente para testes de integração.
🟡 | **Matriz de Dialetos (Oracle/IB)** | Finalizar a automação dos testes para Oracle e InterBase.
🟡 | **Testes de Integração Web** | Validar cenários reais de Cookies, Upload binário e Compressão via HTTP.
🟡 | **HTTPS/SSL Validation** | Validar exaustivamente OpenSSL 3.0 e Taurus TLS.

---

## 🏎️ Benchmarks (Baseline V1.0)
Status | Tarefa | Descrição
:---: | :--- | :---
🔴 | **Web Framework Benchmark** | Hello World, JSON Serialization e DB Read (comparar vs ASP.NET Core e Horse).
🔴 | **ORM Benchmark** | Bulk Insert 10k e Select com Hydration de alto volume vs FireDAC puro.

---

## 📖 Documentação & Atendimento
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **Revisão Técnica do Livro** | Validar todos os exemplos de código em todos os capítulos do Book.
🔴 | **Série de Vídeos (Screencasts)** | Gravação de demonstrações rápidas para as funcionalidades principais (Web Hubs, Smart Properties).

---

## 📡 Modernização & Serviços (O Modernizador)
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **gRPC & Protobuf** | Implementação inicial da camada de transporte binário.
🔴 | **High-Perf Reflection** | Substituir RTTI genérico por Handlers de tipo acelerados.
🔴 | **Provider de EntityDataSet** | Providers plugáveis (REST/gRPC) para o EntityDataSet.
🔴 | **Tracing Distribuído** | UI de instrumentação e tracing baseado em proxies dinâmicos.
🟡 | **Motor de PDF & Assinatura** | Módulo para geração de PDFs assinados.

---

## 🛡️ Production Middleware Pack
Status | Tarefa | Descrição
:---: | :--- | :---
🟡 | **Middleware de CORS** | Suporte a múltiplas origens para frontends SPA.
🟡 | **SPA Fallback** | Suporte ao History Mode (index.html redirection).
🟡 | **Forwarded Headers** | Confiar em X-Forwarded-* vindo de Proxies.
🔴 | **Resiliência (Tipo Polly)** | Políticas de Retry e Circuit Breaker.
🔴 | **Localização (i18n)** | Detecção automática de cultura via Headers.

---

## 🔮 Futuro / Pós-V1
- [ ] **Suporte a OData**: Suporte completo a queries OData.
- [ ] **GraphQL**: Camada nativa para exposição de grafos de dados.
- [ ] **Skia UI (Revolucionário)**: Exploração de motor de UI customizado de alta performance.
- [ ] **Background Jobs (Redis/RabbitMQ)**: Sistema de filas persistentes com retentativas.
- [ ] **CancellationToken Timeout**: Suporte nativo a `.WithTimeout(Duration)`.

---
*Última atualização: 11 de Abril de 2026*
