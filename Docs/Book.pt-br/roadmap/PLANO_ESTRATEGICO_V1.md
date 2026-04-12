# 🚁 Dext Framework: Plano Estratégico de Execução (V1.0 Stable)

**Autor:** Antigravity (Gerente de Projeto AI)  
**Alvo:** Time de Engenharia Dext  
**Foco:** Maturidade Comercial, Performance e Crescimento do Ecossistema

---

## 🏗️ Resumo Executivo

Após a profissionalização da base de código e documentação (RC 1.0), o projeto deve agora transicionar de uma "Ferramenta para Desenvolvedores" para um "Ecossistema Pronto para Produção". Este plano define quatro pilares estratégicos (Pacotes de Trabalho) desenhados para garantir a adoção em larga escala, performance comprovada e sustentabilidade a longo prazo.

---

## 🏁 Pilar 1: A "North Star" (Performance & Evidência)
A vantagem competitiva definitiva do Dext é a performance nativa do Object Pascal combinada com a produtividade do estilo .NET. Devemos sair de afirmações subjetivas para dados objetivos e verificáveis.

### 📋 Objetivos Chave:
- [ ] **Estabelecer Dext.Benchmarks**: Um repositório ou módulo dedicado para testes de performance padronizados.
- [ ] **Matriz Competitiva**: Benchmark de "Hello World" (throughput/latência) e Serialização JSON contra **ASP.NET Core 8**, **Go (Fiber)** e **Delphi (Horse/Mars)**.
- [ ] **Stress Test de ORM**: Validação de Bulk-insert (100k+ linhas) e comparação de hidratação complexa (Joins/Nested) contra FireDAC puro e ADO.
- [ ] **O Relatório Baseline**: Um whitepaper técnico publicado no diretório `/Docs` documentando estes resultados.

> **Racional**: A prova de performance é a ferramenta mais eficaz para convencer CTOs e Arquitetos a adotarem um novo framework para modernização de sistemas legados.

---

## 🛡️ Pilar 2: A "Rede de Segurança" (QA de Nível Industrial)
Para suportar aplicações críticas de enterprise, o Dext deve provar estabilidade em uma matriz heterogênea de ambientes.

### 📋 Objetivos Chave:
- [ ] **A "Matrix" (Docker-Compose)**: Um ambiente Docker padronizado para subir todos os bancos suportados (SQL Server, Postgre, MySQL, Firebird) simultaneamente para desenvolvimento local e CI.
- [ ] **Testes de Integração Cruzados**: Executar a suíte de 165+ testes contra toda a Matrix automaticamente.
- [ ] **Cenários Web End-to-End (E2E)**: Validar tráfego HTTP real incluindo grandes uploads binários, compressão GZip e fluxos complexos de autenticação via Cookies/JWT.
- [ ] **Suporte a Portas Dinâmicas**: Implementar suporte a Porta 0 para testes de integração headless e ambientes de CI.
- [ ] **O Soak Test de 24h**: Rodar um servidor Indy/WebBroker sob carga sustentada por 24 horas para monitorar o heap de memória e fragmentação.

---

## 📥 Pilar 3: O "Onboarding" (Fricção Zero no Dia 1)
Uma barreira alta nos primeiros 5 minutos resulta em 80% de abandono pelos desenvolvedores. Devemos tornar o caminho inicial sem esforço.

### 📋 Objetivos Chave:
- [ ] **Scaffolding Avançado**: Templates modulares usando o novo processador de templates para Startup, Entidades, Minimal APIs, Controllers e Swagger.
- [ ] **Suporte a Ferramentas & Pacotes**: Implementar ou formalizar o suporte ao **Boss** (gerenciador de pacotes Delphi) e ao **TMS Smart Setup**.
- [ ] **Dext CLI (Doctor)**: Implementar o comando `dext doctor` para verificar Variáveis de Ambiente, Library Path e compatibilidade de binários.
- [ ] **Paridade de Templates**: Templates equivalentes em recursos para Web Stencils (D12.2+) e versões "Nativas/Legadas" do Delphi.
- [ ] **CONTRIBUTING_AI.md**: Criar diretrizes específicas para ajudar outros assistentes de IA (Claude, GPT, Codex) a contribuir com o Dext seguindo as regras arquiteturais estritas.

---

## 🖥️ Pilar 4: O "Ecossistema" (Dext.UI & Visuais)
Desenvolvedores backend no mundo Delphi frequentemente lideram projetos de UI Desktop. Fortalecer a camada de UI preenche a lacuna entre a API e a Aplicação.

### 📋 Objetivos Chave:
- [ ] **Autorização no Navigator**: Implementar middlewares funcionais no Navigator (ex: checagem de roles/auth antes de trocar de aba).
- [ ] **Performance do Magic Binding**: Auditar e otimizar o binding bidirecional em formulários VCL de larga escala (100+ inputs vinculados).
- [ ] **Visuais Ricos**: Criar componentes nativos no Dext.UI para padrões modernos: Toasts, Notification Overlays e sincronização de Dark/Light mode.

---

## 📡 Pilar 5: O "Modernizador" (gRPC, Observabilidade & DataProviders)
Desafiando o mercado legatário de conectividade Delphi ao fornecer alternativas modernas e de alta velocidade ao DataSnap, RDW e Rem Objects.

### 📋 Objetivos Chave:
- [ ] **Integração gRPC & Protobuf**: Camada de transporte binário de alta velocidade para serviços remotos e cross-platform.
- [ ] **TEntityDataSet & DataProviders**: Integração nativa do `TEntityDataSet` com providers REST e gRPC para substituição "drop-in" de legados em VCL/FMX.
- [ ] **Tracing Distribuído & Dashboard**: Implementação de instrumentação (via proxies dinâmicos) para tracing em tempo real de SQL, requisições e exceções.
- [ ] **Motor de PDF & Assinatura**: Módulo utilitário para geração de PDFs assinados (foco em ERP).

---

## 🔐 Pilar 6: O "Enterprise" (Security & Advanced Tooling)
Segurança e produtividade são os requisitos finais para a adoção comercial profissional.

### 📋 Objetivos Chave:
- [ ] **OAuth2/OIDC Nativo**: Implementação de autenticação baseada em JWT e provedores de Identidade (Google/Microsoft).
- [ ] **Auth Baseada em Políticas**: Lógica de autorização flexível inspirada no ASP.NET Core.
- [ ] **IDE Wizards**: Ferramentas visuais para Migrations e Scaffolding dentro do ambiente Delphi (Dext Explorer).
- [ ] **O Middleware Pack de Produção**: Entregar uma suíte de middlewares essenciais: 
    - **CORS** (Suporte multiorigem seguro).
    - **SPA Fallback** (Suporte ao History Mode de Vue/React).
    - **Forwarded Headers** (Integração com Nginx/Cloudflare/IIS).
    - **Resiliência & Políticas** (Retentativas e Circuit Breakers).
    - **Localização (i18n)** (Detecção automática de cultura).

---

## 📅 Roadmap para o Stable

1.  **Fase A (A Evidência)**: Pilar 1 (Benchmarks) + Pilar 2 (Matrix Setup).
2.  **Fase B (A Experiência)**: Pilar 3 (Scaffolding Avançado) + Pilar 5 (Alpha do Modernizador).
3.  **Fase C (A Profissionalização)**: Pilar 6 (Security & Tooling) + Middleware Pack.
4.  **Fase D (O Polimento)**: Pilar 4 (Refinamento de UI) + Auditoria Final de RC.

---
*Documento gerado por Antigravity AI - Abril de 2026*
