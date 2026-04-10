# 🚀 Dext Framework — Oportunidades de Melhoria

> Consolidação das melhorias identificadas durante a auditoria de curadoria técnica (Abril 2026).  
> Organizadas por **fase de release**, agrupadas por área funcional e ordenadas por prioridade de impacto.

---

## 📊 Resumo Executivo

| Fase | Itens | Critério |
| :--- | :---: | :--- |
| 🔴 **Pré-1.0 (Obrigatório)** | 4 | APIs incompletas, bugs latentes, features padrão ausentes |
| 🟡 **Avaliar para 1.0** | 2 | Inconsistências visíveis ao usuário, fragilidade de integração |
| 🟢 **Pós-1.0 (Backlog)** | 21 | Otimizações de performance, refinamentos e extensibilidade |

**Total: 27 oportunidades de melhoria.**

---
---

# 🔴 Fase 1 — Pré-1.0 (Obrigatório)

> [!IMPORTANT]
> Estes itens representam **funcionalidade incompleta, gaps de feature padrão ou fragilidade estrutural**.
> Devem ser resolvidos **antes** do release RC 1.0.

### ~~1. Headers de Resposta — API Incompleta~~ ✅ Concluído

| | |
| :--- | :--- |
| **Unit** | `Dext.Net.RestClient` (`TRestResponse`) |
| **Área** | Networking |
| **Problema** | A implementação de `GetHeader` está incompleta. Inspecionar ETags, RateLimit headers e headers customizados é expectativa básica de qualquer HTTP client. |
| **Ação** | Finalizar a implementação de `GetHeader` em `TRestResponse` com suporte a lookup case-insensitive e multi-value headers. |

### ~~2. OAuth2 Client Credentials — Gap de Feature Enterprise~~ ✅ Concluído

| | |
| :--- | :--- |
| **Unit** | `Dext.Net.Authentication` |
| **Área** | Segurança & Autenticação |
| **Problema** | O fluxo Client Credentials (M2M — machine-to-machine) é o mais utilizado em integrações de backend Enterprise. Sem ele, o módulo de autenticação do RestClient está incompleto para o cenário alvo. |
| **Ação** | Implementar provedor de autenticação nativo para OAuth2 Client Credentials com suporte a token caching e refresh automático. |

### ~~3. Path Versioning — Feature Padrão Ausente~~ ✅ Concluído

| | |
| :--- | :--- |
| **Unit** | `Dext.Web.Versioning` |
| **Área** | Web Framework |
| **Problema** | O Dext já oferece Header e Query versioning, mas `/v1/api/...` é o padrão mais adotado na indústria. A ausência de Path versioning passa a impressão de feature inacabada. |
| **Ação** | Implementar `TPathApiVersionReader` para suportar versionamento diretamente na URL, complementando os readers existentes. |

### ~~4. Web Object Tracking — Fragilidade Estrutural~~ ✅ Concluído

| | |
| :--- | :--- |
| **Unit** | `Dext.Web.Core` (`THandlerInvoker`) |
| **Área** | Web Framework & Pipeline |
| **Problema** | O tracking de propriedade de objetos atualmente depende de heurísticas frágeis em `IsEntity`. Isso pode causar leaks ou double-frees sob carga variada — bug latente no pipeline crítico de requests. |
| **Ação** | Implementar tracking explícito de propriedade via `IAsyncDisposable` ou mecanismo de ownership similar, eliminando as heurísticas. |

---
---

# 🟡 Fase 2 — Avaliar para 1.0

> [!WARNING]
> Itens com **impacto direto na percepção de qualidade** ou **confiabilidade da integração**.
> Recomendados para inclusão no RC 1.0 se o cronograma permitir.

### 5. Logging de Startup — Concluído ✅

| | |
| :--- | :--- |
| **Unit** | `Dext.Hosting.BackgroundService` |
| **Área** | Hosting & Lifecycle |
| **Status** | Unificado com `ILogger` oficial. |

### 6. Robustez IDE — Concluído ✅

| | |
| :--- | :--- |
| **Unit** | `Dext.Testing.Host` |
| **Área** | Testing & QA |
| **Status** | Handshake explícito implementado, eliminando dependência de Sleep. |

---
---

# 🟢 Fase 3 — Pós-1.0 (Backlog)

> [!NOTE]
> Otimizações de performance, refinamentos de UX e extensibilidade avançada.
> O framework é funcional e estável sem estes itens; eles visam elevar a qualidade para **nível Enterprise premium**.

---

## 🔄 Status de Execução (Fase 3)

- A.1 **Web RTTI Pool**: ✅ Concluído
- A.2 **Activator Context Cache**: ✅ Concluído
- A.3 **Span SIMD**: ✅ Concluído
- A.5 **Limpeza de Partições**: ✅ Concluído
- B.1 **MIME Extensível**: 🟡 Implementado
- B.3 **Otimização JWT**: 🟡 Implementado
- C.1 **Multipart/Form-Data**: 🟡 Implementado
- E.1 **Configuration Watchers**: 🟡 Implementado
- E.2 **Validation in Config**: 🟡 Implementado
- G.3 **HTML Reporter Templates**: ✅ Concluído
- C.2 **Unificação de Escapes**: ✅ Concluído
- D.2 **Lazy Loading Interceptors**: ✅ Concluído
- D.3 **Metadata Parser (AST)**: ✅ Concluído
- H.1 **Filtro de Entidades**: ✅ Concluído
- H.2 **SQL Tab no Preview**: ✅ Concluído

---

## A. Core & Performance

Melhorias na fundação de baixo nível que impactam **todos os módulos** do framework.

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| A.1 | **Web RTTI Pool** | `Dext.Web.ModelBinding` / `Dext.Web.Core` | Compartilhar `TRttiContext` entre `ModelBinder` e `HandlerInvoker` para eliminar o overhead de criação de pool RTTI por requisição. |
| A.2 | **Activator Context Cache** | `Dext.Core.Activator` | Permitir compartilhamento de `TRttiContext` via `ThreadLocal` ou parâmetro opcional para evitar recriação massiva em loops de desserialização JSON. |
| A.3 | **Span SIMD** | `Dext.Core.Span` | Implementar `TByteSpan.Equals` usando instruções SIMD (SSE/AVX) para comparação de buffers de alta densidade no motor Web e JSON. |
| A.4 | **Config Key Hashing** | `Dext.Configuration.Core` | Otimizar busca em `TConfigurationRoot` utilizando hashes de strings para chaves compostas em árvores profundas. |
| A.5 | **Limpeza de Partições** | `Dext.RateLimiting.Limiters` | Otimizar `Cleanup` para evitar iteração total no dicionário em servidores de altíssimo tráfego. Migrar para background thread ou bucket expiry. |

---

## B. Web Framework & Pipeline

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| B.1 | **MIME Extensível** | `Dext.Web.StaticFiles` | Transformar o mapeamento de MIME types em provedor extensível ou carregável de arquivo externo, em vez de hardcoded. |
| B.2 | **DataApi Metadata** | `Dext.Web.DataApi` | Centralizar lógica de pluralização e descoberta de nomes de tags Swagger em unit de utilitários de metadados para evitar repetição de código RTTI. |
| B.3 | **Otimização JWT** | `Dext.Auth.JWT` | Refatorar `Base64UrlEncode` para realizar troca de caracteres em um único passo, evitando múltiplas alocações de string via `Replace`. |

---

## C. Networking (RestClient)

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| C.1 | **Multipart/Form-Data** | `Dext.Net.RestRequest` | Facilitar envio de arquivos e campos de formulário via métodos dedicados no builder (`AddFile`, `AddFormField`). |
| C.2 | **Unificação de Escapes** | `Dext.Text.Escaping` | Centralizar funções `EscapeXml` e `EscapeJson` em unit única para evitar duplicação entre reporters, serializers e RestClient. | ✅ Concluído |

---

## D. ORM & Persistência

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| D.1 | **DbSet Cache Lock** | `Dext.Entity.Context` | Avaliar substituição da `TCriticalSection` em `CreateDynamicDbSet` por lock mais leve para cenários de altíssima pressão paralela. |
| D.2 | **Lazy Loading Interceptors** | `Dext.Entity.Core` / `Dext.Entity.Query` | ✅ Concluído. Criar abstração `ILazyLoader` desvinculada para mover geração de proxies para fora do pipeline físico. |
| D.3 | **Metadata Parser (AST)** | `Dext.Entity.Metadata` | ✅ Concluído. Expandir `TEntityMetadataParser` para identificar automaticamente relações complexas (`Join`/`Include` hints) diretamente dos `.pas`. |

---

## E. Configuração & Options

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| E.1 | **Configuration Watchers** | `Dext.Configuration.Core` | Implementar `ReloadOnChange` utilizando `TFileSystemWatcher` para atualização automática da configuração ao detectar mudanças no disco. |
| E.2 | **Validation in Config** | `Dext.Configuration.Core` / `Dext.Options` | Permitir registro de Validadores para seções de configuração, impedindo o `Build` se valores obrigatórios estiverem ausentes ou inválidos. |

---

## F. Hosting & Lifecycle

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| F.1 | **Eventos de Estado** | `Dext.Hosting.AppState` | Disparar notificações via `TMessageManager` em cada mudança de estado (`asMigrating`, `asRunning`) para monitoramento desacoplado. |

---

## G. Testing & QA

| # | Melhoria | Unit Afetada | Descrição | Status |
| :---: | :--- | :--- | :--- | :--- |
| G.1 | **Soft Assertions Thread-Safety** | `Dext.Assertions` | Validar thread-safety do `Assert.Multiple` com `ThreadLocal` em cenários multithread massivos. | [TODO] |
| G.2 | **Snapshots Inteligentes** | `Dext.Assertions` | Evoluir `MatchSnapshot` para ignorar diferenças irrelevantes em JSON (ordem de campos, espaços em branco). | ✅ Concluído |
| G.3 | **HTML Reporter Templates** | `Dext.Testing.Report` | Refatorar `THTMLReporter` para usar `Dext.Templating`, convertendo estruturas para classes e unificando escapes. | ✅ Concluído |

---

## H. Design-Time (IDE Experience)

| # | Melhoria | Unit Afetada | Descrição |
| :---: | :--- | :--- | :--- |
| H.1 | **Filtro de Entidades** | `Dext.EF.Design.Editors` | ✅ Concluído. Implementar SearchBox no editor de classes de entidade para projetos com centenas de modelos. |
| H.2 | **SQL Tab no Preview** | `Dext.EF.Design.Preview` | ✅ Concluído. Adicionar aba "SQL" no `TPreviewForm` para visualizar o comando SQL gerado. |
| H.3 | **Visualização de Tipos** | `Dext.EF.Design.Preview` | Exibir detalhes de metadados (tipo real, tamanho, precisão) no cabeçalho ou hint das colunas do grid de preview. |

---
---

## 📋 Roadmap Sugerido

### Pré-RC 1.0

1. ~~Finalizar `GetHeader` em `TRestResponse` (item 1)~~ ✅
2. ~~Implementar OAuth2 Client Credentials (item 2)~~ ✅
3. ~~Implementar `TPathApiVersionReader` (item 3)~~ ✅
4. ~~Corrigir Object Tracking no `THandlerInvoker` (item 4)~~ ✅
5. Unificar Logging de Startup (item 5) e Robustez IDE (item 6) ✅

### Pós-1.0 — Sprint 1 (Performance)

- ~~Core RTTI Pool (A.1, A.2)~~ ✅
- ~~Span SIMD (A.3)~~ ✅
- ~~Rate Limiting Cleanup (A.5)~~ ✅

### Pós-1.0 — Sprint 2 (Extensibilidade)

- ~~Configuration Watchers e Validation (E.1, E.2)~~ ✅
- ~~Multipart/Form-Data (C.1)~~ ✅
- ~~MIME extensível (B.1)~~ ✅

### Pós-1.0 — Sprint 3 (Refinamento)

- ORM: Lazy Loading e AST Parser (D.2, D.3) ✅ Concluído
- ~~Testing: Snapshots e Templates (G.2, G.3)~~ ✅
- Design-Time: SQL Tab e SearchBox (H.1, H.2) ✅ Concluído

---

## 🧪 Cobertura de Testes Unitários (Estabilidade da Fase 3)

> Testes estruturais elaborados para blindar as melhorias implementadas na Fase 3 e garantir ausência de regressões ("Memory Leaks" e "Acesso a Ponteiros de RTTI").

| Ref | Teste de Cobertura | Status | Descrição |
| :---: | :--- | :---: | :--- |
| T.1 | **Serialização de Interfaces (`IList<T>`)** | ✅ | Assegurar que `TDextSerializer` extrai dados por iteradores (`Count`, `GetItem`) corretamente a partir de `IInterface`. |
| T.2 | **Memory Leak Guard (`TActivator` Cache)** | ✅ | Loop massivo para instanciar contextos no RTTI Pool constatando o retorno seguro de instâncias sem vazar memória. |
| T.3 | **Validação JWT & Multipart (Amarelos)** | ✅ | Asserts baseados em dados variados para garantir que `B.3` (JWT) e `C.1` (Multipart) estão sólidos em tráfego real. |
| T.4 | **Configuration Pipeline (`E.1` e `E.2`)** | ✅ | Testar validações obrigatórias de Options e hot-reload via `FileSystemWatcher`. |


---

*Documento gerado em 08 de Abril de 2026 a partir da curadoria técnica do Dext Framework.*  
*Revisado com classificação de fases de release baseada em análise de completude e risco.*
