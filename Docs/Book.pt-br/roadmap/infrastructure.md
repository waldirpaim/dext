# 🏗️ Infraestrutura Dext - Roadmap

Este documento centraliza o desenvolvimento da infraestrutura de baixo nível do framework, com foco em **Performance Extrema**.

> **Visão:** Prover uma fundação sólida, "Metal-to-the-Pedal", que permita ao Dext competir em performance com frameworks Go, Rust e .NET.

---

## 📊 Status Atual: **Release Candidate 1.0** 🚀

A infraestrutura base está estabilizada, com drivers plugáveis para alta performance e suporte a zero-allocation parsing.

*Última atualização: 07 de Abril de 2026*

## 🚀 Servidores HTTP de Alta Performance

Estratégia de servidores plugáveis (`Server Adapters`) para permitir estabilidade imediata e performance extrema futura, sem quebrar a API pública.

### 1. V1: Driver Indy (Estabilidade) - ✅ Concluído

- [x] **TDextIndyWrapper**: Wrapper para compatibilidade Indy. Renomeado para clareza de licenciamento.
- [x] **Avaliação Preguiçosa (Lazy)**: Headers e Query String processados sob demanda.
- [x] **Encapsulamento de Stream**: Manipulação de buffers sem cópia de memória (Zero-Copy).

### 2. V2: Enterprise Driver (Kestrel NativeAOT) - 📅 Planejado

Estratégia para performance "estado da arte" usando o motor do ASP.NET Core via interoperabilidade nativa.

- [ ] **Wrapper NativeAOT**: Biblioteca C# compilada como Native Library (`.dll`/`.so`) exportando interface C.
- [ ] **Ponte Zero-Copy**: Passagem de ponteiros de memória (Pinned Memory) do .NET para o Delphi.
- [x] **TSpan<T>**: Implementação de `Span<T>` no Delphi para ler os buffers do Kestrel sem alocação de strings intermediárias.

### 3. V3: Native Drivers (Bare Metal) - 🔮 Futuro

Implementações 100% Pascal para cenários onde dependências externas não são desejadas.

- [ ] **Windows**: Integração direta com `http.sys` (Kernel Mode).
- [ ] **Linux**: Event Loop baseado em `epoll` integrado ao Scheduler do Dext.Async.

Reescrita do núcleo HTTP para eliminar gargalos de arquiteturas legadas (Indy/WebBroker) e explorar recursos nativos do SO.

### 1. Windows: Kernel Mode (`http.sys`)

Integração direta com o driver `http.sys` do Windows (mesma stack do IIS e Kestrel).

- [ ] **Native API Binding**: Importação da `httpapi.dll` (HttpInitialize, HttpCreateHttpHandle).
- [ ] **Zero-Copy**: Utilizar buffers do kernel para evitar cópias desnecessárias de memória.
- [ ] **Kernel-Mode Caching**: Servir arquivos estáticos e respostas cacheadas diretamente do Kernel.
- [ ] **Port Sharing**: Permitir compartilhar a porta 80/443 com IIS e outras apps.
- [ ] **HTTP/3 (QUIC)**: Suporte experimental ao novo protocolo HTTP sobre UDP para performance em redes instáveis.

### 2. Linux: Event-Driven I/O (`epoll`)

Modelo não-bloqueante para alta concorrência no Linux.

- [ ] **Epoll Integration**: Uso de `epoll_create1`, `epoll_ctl`, `epoll_wait`.
- [ ] **Thread Pool**: Workers fixos (CPU Bound) processando eventos de I/O de milhares de conexões.
- [ ] **Non-Blocking Sockets**: Eliminar o modelo "Thread-per-Connection".

### 3. Otimização de Memória & Strings (Zero-Allocation)

Eliminar o custo de conversão `UTF-8` <-> `UTF-16` (UnicodeString) no core do framework.

- [x] **RawUTF8 / Span<byte>**: Tipo de dados base para manipulação de strings sem conversão.
- [x] **Zero-Allocation Parsing**: Roteamento e Headers processados varrendo bytes diretamente.
- [x] **UTF-8 JSON Parser**: Novo parser JSON otimizado para ler/escrever UTF-8 diretamente, sem alocações intermediárias de strings Delphi.

---

## 🛠️ Infraestrutura Core

### 1. Otimização de Memória

- [x] **TSpan<T>**: Estrutura para fatiamento de arrays/memória sem alocação (essencial para o JSON Parser V2).
- [x] **JSON Zero-Allocation**: Parser JSON baseado em `TSpan<Byte>` (UTF-8) para evitar transcoding para UTF-16.

### 2. Melhorias em Configurações JSON

- [x] **Configurações Globais Padrão**: Via `TDextJson.SetDefaultSettings` para aplicar case-insensitivity e outras opções globalmente.
- [ ] **Configurações por Contexto**: Permitir configuração de JSON settings por contexto/endpoint via middleware ou atributos.

### 3. Fundação de Telemetria & Observabilidade

- [ ] **API de Activity/Span**: Abstração para rastreamento distribuído (Tracing).
- [ ] **API de Métricas**: Contadores, Histogramas e Gauges de alta performance.
- [ ] **Abstração de Logging**: Interface de logging com foco em zero-allocation.

### 4. Assincronia Avançada & Concorrência

- [x] **Tasks Fluentes Core**: Implementação base (`TAsyncTask`, `ThenBy`, `WithCancellation`).
- [x] **Callbacks Não-Sincronizados**: Execução de callbacks em thread de background (evitando gargalos na Main Thread).
- [ ] **Testing Scheduler**: Scheduler para permitir testes unitários determinísticos de código assíncrono.
- [ ] **Padrões de Composição (Fork/Join)**: `WhenAll` e `WhenAny`.
- [ ] **Padrões de Resiliência**: `Retry`, `Circuit Breaker` e `Timeout`.
- [ ] **Relatório de Progresso**: Suporte a `IProgress<T>` para notificações granulares.

---

## 🧪 Ecossistema de Testes & QA (Dext.Testing)

### 1. Dext.Mock (Baseado em AST)

Motor de Mocks construído sobre a engine `Dext.Expressions`.

- [ ] **Evolução da AST (Core)**: Implementar `IMethodCallExpression` (para representar a chamada) e `TArgExpression` (para representar o argumento sendo validado) na engine de expressões.
- [ ] **Interceptor**: Uso de `TVirtualInterface` conectado à AST para gravar as chamadas no `MethodCallExpression`.
- [ ] **DSL de Argument Matchers**: Record `It` para definição de regras (`It.IsAny<int>`, `It.Matches(Arg > 10)`).
- [ ] **Async Mocking**: Suporte nativo a `ReturnsAsync` (fabricação de Tasks completadas para evitar boilerplate em testes).

### 2. Asserções Fluentes (Fluent Assertions)

- [ ] **API Fluente**: Sintaxe `Expect(Value).Should.Be(10)`.
- [ ] **Helpers**: Métodos de extensão para tipos nativos (`String`, `Integer`, `TObject`).

### 3. Test Runner & Cobertura (Processo Separado)

- [ ] **Runner Service**: Executável separado para rodar testes (evita crash da IDE).
- [ ] **Protocolo IPC**: Comunicação JSON/WebSocket entre Runner e Plugin da IDE.
- [ ] **Cobertura via Instrumentação AST**: Code Coverage preciso via injeção de contadores na AST (suporte real a Generics e Anonymous Methods).

---

## 📦 Deploy & Modularização

### 1. Drivers de Banco Plugáveis (Suporte Professional/Community)

Evitar dependências obrigatórias de todos os bancos de dados no package principal.

- [x] **Diretivas de Compilação**: Implementação de `DEXT_ENABLE_DB_*` no `Dext.inc` para isolar unidades físicas do FireDAC.
- [ ] **Pacotes Modulares**: Separar drivers físicos em packages específicos (ex: `Dext.EF.Driver.PostgreSQL.dpk`).
- [ ] **Auto-Discovery/Factory**: Sistema para registrar drivers dinamicamente via `initialization`.

### 2. Instalador Dext & CLI

Facilitar o setup do ambiente e seleção de módulos.

- [ ] **Modularity Web UI**: Gerador de projetos onde o dev seleciona os bancos e middlewares desejados.
- [ ] **Gerenciador de Library Path**: Ferramenta CLI para configurar caminhos do Delphi automaticamente.
- [ ] **Modern CLI Argument Parser**: Criar uma classe robusta para parsing de argumentos de linha de comando (CLI), inspirada nos padrões do .NET (`System.CommandLine`). O atual `FindCmdLineSwitch` da RTL é limitado.

## 📚 Gerador de Documentação (dext doc)

Ferramenta para geração de sites estáticos de documentação a partir do código fonte (AST).

### 1. Customização & Temas

- [ ] **Customização de Metadados**: Opções CLI/Config para definir Título do Site, Autor, Copyright e Footer personalizado.
- [ ] **CSS/JS Customizado**: Suporte a injeção de arquivos `.css` e `.js` do usuário para alterar o tema padrão.
- [ ] **Templates**: Suporte a templates customizáveis (Mustache/Handlebars) para alterar o layout HTML.

### 2. Navegação & Links

- [ ] **Hiperlinks de Tipos**: Criar links navegáveis automaticamente entre tipos (ex: clicar no tipo de retorno de um método e ir para a página daquele tipo).
- [ ] **Breadcrumbs**: Implementar navegação de "migalhas de pão" baseada em namespaces.
- [ ] **Link "Ver Código Fonte"**: Link direto para o repositório (GitHub/GitLab) na linha exata da declaração.
- [ ] **Gráficos de Dependência**: Diagrama Mermaid de dependências entre Units.

### 3. Conteúdo Avançado & Parsing

- [ ] **Documentação XML**: Suporte completo às tags XML (`<summary>`, `<param>`, `<returns>`, `<remarks>`, `<code`, `<see cref>`).
- [ ] **Versionamento**: Suporte a dropdown de versões (v1, v2) no cabeçalho.
- [ ] **Intelligent Search**: Atalho (Ctrl+K), filtros por tipo (ex: `I:Service`) e busca fuzzy.
- [ ] **Badges**: Badges de métricas (Linhas de código, número de métodos, estabilidade).

---
*Infraestrutura Dext - Criando a base para software de alta performance.*
