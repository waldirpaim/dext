[🇺🇸 English](README.md)

# Dext Framework - Modern Full-Stack Development for Delphi

> ⚠️ **Status: Beta (v1.0 Preview)**
> O projeto alcançou o marco Beta. As APIs principais estão estáveis, mas pequenas alterações (breaking changes) ainda podem ocorrer antes do lançamento final v1.0.
>
> 📌 **Confira o [Roadmap & Plano V1.0](Docs/Book.pt-br/roadmap.md)** para a lista detalhada de funcionalidades, tarefas pendentes e planos futuros.

> 📢 **[Novidades / Changelog](CHANGELOG.md)** — Últimas atualizações, breaking changes e novas features

**Dext** é um ecossistema completo para desenvolvimento moderno em Delphi. Ele traz a produtividade e os padrões arquiteturais de frameworks como **ASP.NET Core** e **Spring Boot** para a performance nativa do Object Pascal.

O objetivo não é apenas criar APIs, mas fornecer uma fundação sólida (DI, Configuration, Logging, ORM) para que você construa aplicações enterprise robustas e testáveis.

## 🎯 Filosofia e Objetivos

* **Inspirado nos Padrões .NET**: O objetivo é trazer os robustos padrões arquiteturais do ecossistema .NET (ASP.NET Core, EF Core) para o Delphi, alcançando alta compatibilidade com seus princípios de design.
* **Performance Nativa**: Após a estabilização funcional da v1, o foco total será em **otimização de performance**, visando competir com frameworks de alta velocidade.
* **Inovação**: Embora inspirado no .NET, o Dext não se limita a ele, buscando implementar soluções que façam sentido especificamente para a linguagem Delphi.

## 📄 Licença

Este projeto é licenciado sob a **Apache License 2.0** (a mesma utilizada pelo .NET Core). Isso permite o uso livre em projetos comerciais e open-source, com a segurança de uma licença permissiva e moderna.

## 🧠 Design & Filosofia

O desenvolvimento do Dext é guiado por dois princípios de engenharia que definem cada decisão de arquitetura tomada no projeto:

> **"Simplicity is Complicated."** — *Rob Pike*

Esconder a complexidade de servidores HTTP, gerenciamento de memória e concorrência exige uma engenharia interna sofisticada. Nós abraçamos essa complexidade interna para garantir que a sua API pública seja **limpa, intuitiva e livre de ruído**.

* **Na prática:** Você escreve `App.MapGet`, e o framework resolve roteamento, serialização JSON e tratamento de erros silenciosamente.

> **"Make what is right easy and what is wrong difficult."** — *Steve "Ardalis" Smith*

Um bom framework deve guiar o desenvolvedor para o "Caminho Feliz" (*Pit of Success*). O Dext foi desenhado para que as boas práticas — como Injeção de Dependência, segregação de interfaces e uso de DTOs — sejam o padrão natural, e não uma configuração extra trabalhosa.

## 🚀 Módulos Principais

### 🌐 Dext.Web (Web Framework)

Um framework HTTP leve e poderoso para construir REST APIs e microserviços.

* **Minimal APIs**: Sintaxe fluente e concisa para definição de rotas.
* **Controllers**: Suporte tradicional baseado em classes para APIs complexas.
* **Model Binding Avançado**: Binding automático de múltiplas fontes (Body, Query, Route, Header, Services) diretamente para Records/Classes.
* **Middlewares**: Pipeline de requisição modular e extensível.
* **SSL/HTTPS**: Suporte plugável para OpenSSL e TaurusTLS (OpenSSL 1.1x/3.x).
* **UUIDs de Primeira Classe**: Suporte nativo para binding de `TUUID` (RFC 9562) em Rotas/Body.
* **Multipart/Form-Data**: Suporte nativo a upload de arquivos via `IFormFile`.
* **Response Compression**: Middleware integrado de compressão GZip.
* **Cookies**: Suporte completo a leitura e escrita com `TCookieOptions`.
* **OpenAPI**: Integração nativa com Swagger e geração automática de documentação.
* **Database as API**: REST endpoints zero-code a partir de entities com `TDataApiHandler<T>.Map` ou via nova sintaxe fluente `App.Services.MapDataApi<T>`.
* **Zero-Allocation JSON**: Geração de resposta extremamente rápida via `TUtf8JsonWriter` para streaming direto.
* **Dynamic Specification Mapping**: Integração automática de filtros via QueryString (`_gt`, `_lt`, `_sort`, etc).
* **WebBroker Server Adapter** ⭐ NOVO: Faça deploy via WebBroker (ISAPI/CGI) no IIS/Apache sem alterar o código da aplicação, operando lado a lado com o Indy.
* **DCS Server Adapter** ⭐ NOVO: Motor HTTP não bloqueante de altíssima performance (epoll/IOCP) usando Delphi-Cross-Socket.
* **Comunicação em Tempo Real** ⭐ NOVO: Hubs compatíveis com SignalR para messaging em tempo real. Suporta grupos, targeting por usuário e broadcast com `Dext.Web.Hubs`. [Saiba mais](Docs/Book.pt-br/07-tempo-real/hubs-signalr.md)
* **SSR & View Engines** ⭐ NOVO: Renderização Server-Side agnóstica com Flyweight Iterators para O(1) de memória em loops e integração nativa com **Web Stencils** (Delphi 12.2+) via DSL fluente otimizada.
* **Observabilidade & Telemetria (S03)** ⭐ NOVO: Infraestrutura de instrumentação em tempo real via `TDiagnosticSource`. Inclui `Telemetry Bridge` para log direto de eventos HTTP e SQL no console.
* **Auto-Migrations (S11)** ⭐ NOVO: Sincronização automática de schema durante o startup do servidor web com detecção inteligente de renomeação.

### 🗄️ Dext.Entity (ORM)

Um ORM moderno focado em produtividade e performance.

* **Code-First**: Defina seu banco de dados usando classes Delphi.
* **Scaffolding**: Suporte a Database-First para gerar entidades a partir de esquemas existentes e scaffolding de projetos via CLI.
* **Migrations (S11)**: Controle de versão do esquema (`migrate:up`, `migrate:down`, `migrate:generate`) com detecção de renomeação via atributos.
* **Fluent Query API**: Consultas fortemente tipadas e expressivas.
* **Smart Properties**: Expressões de query type-safe sem magic strings. Escreva `u.Age > 18` e ganhe checagem em tempo de compilação, IntelliSense e geração automática de SQL. [Saiba mais](Docs/Book.pt-br/05-orm/smart-properties.md)
* **Change Tracking**: Controle automático de mudanças e persistência otimizada.
* **Tipos Avançados**: Suporte nativo para **UUID v7** (Ordenado por Tempo), JSON/JSONB e Arrays.
* **Propagação de DbType**: Controle explícito de tipos de banco via atributo `[DbType]`, garantindo integridade além dos tipos Delphi.
* **Suporte a Paginação Legada**: Envelopamento automático de queries (ex: `ROWNUM`) para versões antigas de Oracle e SQL Server.
* **Multi-Tenancy**:
  * **Banco Compartilhado**: Filtros automáticos por `TenantId`.
  * **Isolamento por Schema**: Performance extrema via schemas (PostgreSQL `search_path`, SQL Server prefixing).
  * **Tenant por Banco de Dados**: Resolução dinâmica de Connection String baseada no tenant.
  * **Criação Automática**: `EnsureCreated` configura automaticamente os schemas por tenant.
* **Consultas Avançadas**:
  * **FromSql**: Execute SQL puro e mapeie os resultados para entidades automaticamente.
  * **Multi-Mapping ([Nested])**: Hidratação recursiva estilo Dapper para objetos complexos.
  * **Pessimistic Locking**: Suporte a `FOR UPDATE` e `UPDLOCK` em consultas fluentes.
  * **Stored Procedures**: Mapeamento declarativo via `[StoredProcedure]` e `[DbParam]`.
* **Mapeamento de Herança**:
  * **Table-Per-Hierarchy (TPH)**: Suporte total para classes base e subclasses em uma única tabela.
  * **Hydration Polimórfica**: Instanciação automática da subclasse correta durante a recuperação de dados.
  * **Mapeamento via Atributos**: Uso de `[Inheritance]`, `[DiscriminatorColumn]`, e `[DiscriminatorValue]`.
* **Multi-Database**: Suporte totalmente testado para **SQL Server, PostgreSQL, Firebird, MySQL/MariaDB** e **SQLite** (165 testes passando em todos). Oracle em beta.
* **Auto-Detecção de Dialeto**: Identificação determinística via Enum (`ddPostgreSQL`, etc) para configuração zero.
* **Drivers de Alta Performance**:
  * **Driver FireDAC Padrão**: Completo com compatibilidade TDataSet
  * **Driver FireDAC Phys**: Acesso "bare metal" sem TDataSet para máxima performance
  * Acesso direto à camada física do FireDAC (IFDPhysConnection) para queries ultra-rápidas
* **Performance**: Cache de Metadados de Alta Velocidade (singleton) para minimizar overhead de Reflection.

### 🌐 Dext.Net (Networking) ⭐ NOVO

Um cliente HTTP fluente de alto desempenho para conectividade moderna.

* **API Fluente**: Padrão Builder para construção intuitiva de requisições (`Client.Get('/api').Header(...).Start`).
* **Connection Pooling**: Pool nativo thread-safe reutiliza instâncias de `THttpClient` para throughput máximo.
* **Resiliência**: Suporte integrado para Retries, Timeouts e Circuit Breaker patterns.
* **Autenticação**: Providers plugáveis (Bearer, Basic, ApiKey).
* **Serialização**: Integração automática de serialização/deserialização JSON com `Dext.Json`.
* **Parser de Arquivos HTTP** ⭐ NOVO: Parse e execute arquivos `.http` (formato VS Code/IntelliJ REST Client) com interpolação de variáveis e suporte a variáveis de ambiente.

### ⚙️ Dext.Core (Infraestrutura)

A fundação do framework, utilizável em qualquer tipo de aplicação.

* **Dependency Injection**: Container IOC completo e rápido.
* **Configuration**: Sistema de configuração flexível (JSON, YAML, Variáveis de Ambiente).
* **Logging**: Abstração de log estruturado.
* **Async/Await**: Primitivas para programação assíncrona real.
* **Coleções Genéricas** ⭐ **NOVO**: Coleções baseadas em interfaces (`IList<T>`, `IDictionary<K,V>`) com gerenciamento manual de memória ZERO e amplo suporte inspirado em LINQ (`Where`, `Select`, `Any`, `OrderBy`). Elimina "Memory Leaks" e simplifica a lógica de dados.
* **Specifications**: Encapsulamento e composição de regras de negócio (DDD).
* **Expressions**: Primitivas de árvores de expressão para avaliação dinâmica de lógica.
* **Serialização JSON**:
  * **UTF-8 de Alta Performance**: Serialização/desserialização direta em UTF-8 sem conversões intermediárias
  * **Parsing Zero-Copy**: Otimizado para mínimas alocações de memória
  * **Suporte Inteligente a Tipos**: Tratamento nativo de GUID, Enums, DateTime e tipos customizados
  * **Drivers Plugáveis**: Suporte para JsonDataObjects (padrão) e System.JSON

### 🧪 Dext.Testing

O framework de testes definitivo e moderno para Delphi, inspirado em NUnit, FluentAssertions e Moq.

* **Attribute-Based Runner** ⭐ NOVO: Escreva testes com `[TestFixture]`, `[Test]`, `[Setup]`, `[TearDown]` - sem herança de classe base.
* **Asserções Fluentes Unificadas**: Uma sintaxe rica `Should(Value)` para tudo—de Primitivos (Int64, GUID, Variant) a Objetos, Listas e Actions. Inclui **Soft Asserts** (`Assert.Multiple`) para agregação de falhas, Encadeamento (`.AndAlso`), verificações localizadas (`.BeOneOf`, `.Satisfy`) e inspeção via RTTI (`.HaveProperty`).
* **Mocking Poderoso**: Crie mocks strict ou loose para Interfaces e Classes com `Mock<T>`. Suporta Mocks Parciais (`CallsBase`), setup de Sequência e Argument Matchers (`Arg.Is<T>`).
* **Auto-Mocking Container**: Teste classes com muitas dependências sem esforço. `TAutoMocker` injeta automaticamente mocks no seu Sistema Sob Teste (SUT).
* **Snapshot Testing**: Simplifique a verificação de objetos complexos comparando contra baselines em JSON (`MatchSnapshot`).
* **DI Orientada a Testes**: `TTestServiceProvider` especializado para substituir facilmente serviços de produção por mocks durante testes de integração.
* **Integração CI/CD** ⭐ NOVO: Exporte relatórios para JUnit XML, JSON, xUnit, TRX (Azure DevOps), SonarQube e HTML standalone moderno.
* **Live Dashboard** ⭐ NOVO: Monitore seus testes em tempo real com um dashboard web dark-theme moderno e histórico de execuções.
* **Code Coverage & CLI (S01)**: Rode testes e gere relatórios de cobertura prontos para o SonarQube com `dext test --coverage`. Garanta qualidade com thresholds (Quality Gates).
* **Advanced Scaffolding (S01)** ⭐ NOVO: Potente motor CLI para geração de projetos e componentes (`dext new`, `dext add`) utilizando o motor de templates integrado.

### 🧩 Dext.Collections ⭐ **NOVO**

Biblioteca de coleções de alta performance inspirada no .NET 8.

* **Standard & Concurrent**: Implementações otimizadas de List, Dictionary, HashSet e versões thread-safe como `ConcurrentQueue`.
* **Frozen Collections**: Estruturas de dados imutáveis de alto desempenho para cenários de leitura intensa.
* **Channels**: Primitivas de comunicação assíncrona estilo Go (Producer/Consumer) para pipelines de dados.
* **Aceleração de Hardware**: Suporte a SIMD & Vectors (AVX/SSE) para processamento em lote.

### 🖥️ Dext.UI (Desktop Framework) ⭐ NOVO

Um framework de UI moderno para construir aplicações desktop VCL profissionais.

* **Navigator Framework**: Navegação inspirada no Flutter com suporte a middleware pipeline.
  * Padrões Push/Pop/Replace de navegação
  * Suporte a Middleware (Logging, Auth guards, Role checks)
  * Adapters plugáveis (Container, PageControl, MDI)
  * Hooks de ciclo de vida `INavigationAware` (`OnNavigatedTo`, `OnNavigatedFrom`)
* **Magic Binding**: Binding bidirecional automático via atributos.
  * `[BindEdit]`, `[BindText]`, `[BindCheckBox]` para sincronização de propriedades
  * `[OnClickMsg]` para despacho de eventos baseado em mensagens
* **Padrões MVVM**: Arquitetura limpa para aplicações desktop.
  * Padrão ViewModel com validação
  * Padrão Controller para orquestração  
  * Interfaces de View para desacoplamento

### ⚙️ Dext.Core (Extensões)

* **Smart Reflection**: Motor de metadados de alta performance com cache global de tipos.
* **Greedy Activator**: Resolução inteligente de construtores para árvores de dependência complexas.
* **Otimização de Memória**: `Dext.Core.Span` (Zero-allocation) e gerenciamento avançado de memória.

---

## 📚 Índice de Documentação

### 🚀 Começando

* **📖 [O Livro do Dext](Docs/Book.pt-br/README.md)** ⭐ NOVO - Guia completo da instalação aos tópicos avançados | [🇺🇸 English](Docs/Book/README.md)

### 🌐 Web API

* **Roteamento & Endpoints**
  * [Minimal API](Docs/Book.pt-br/02-framework-web/minimal-apis.md)
  * [Validação & Binding](Docs/Book.pt-br/02-framework-web/model-binding.md)

* **Segurança & Middleware**
  * [Autenticação JWT](Docs/Book.pt-br/03-autenticacao/jwt-auth.md)
  * [Configuração HTTPS/SSL](Examples/Web.SslDemo/README.pt-br.md)
  * [CORS](Docs/Book.pt-br/04-recursos-api/cors.md)
  * [Rate Limiting](Docs/Book.pt-br/04-recursos-api/rate-limiting.md)
* **Avançado**
  * [Database as API](Docs/Book.pt-br/06-database-as-api/crud-zero-codigo.md)
  * [Background Services](Docs/Book.pt-br/10-avancado/background-services.md)
  * [Action Filters](Docs/Book.pt-br/04-recursos-api/filtros.md)
  * [Swagger / OpenAPI](Docs/Book.pt-br/04-recursos-api/openapi-swagger.md)
  * [Comunicação em Tempo Real (Hubs)](Docs/Book.pt-br/07-tempo-real/hubs-signalr.md) ⭐ NOVO

### 🗄️ Acesso a Dados (ORM)

* [Configuração de Banco de Dados](Docs/Book.pt-br/05-orm/primeiros-passos.md)
* [Fluent Query API](Docs/Book.pt-br/05-orm/consultas.md)
* [Smart Properties](Docs/Book.pt-br/05-orm/smart-properties.md) ⭐ NOVO
* [Migrations](Docs/Book.pt-br/05-orm/migrations.md)
* [Relacionamentos (Lazy/Eager)](Docs/Book.pt-br/05-orm/relacionamentos.md)
* [Bulk Operations](Docs/Archive/loose/bulk-operations.md)
* [Soft Delete](Docs/Book.pt-br/05-orm/soft-delete.md)

### ⚙️ Core & Infraestrutura

* [Injeção de Dependência & Scopes](Docs/Book.pt-br/10-avancado/injecao-dependencia.md)
* [Configuração & Options Pattern](Docs/Book.pt-br/10-avancado/configuracao.md)
* [Ciclo de Vida & Integridade](Docs/Book.pt-br/02-framework-web/ciclo-de-vida.md)
* [Async Programming](Docs/Book.pt-br/10-avancado/async-api.md)
* [Caching](Docs/Book.pt-br/04-recursos-api/cache.md)
* [Dext CLI Tool](Docs/Book.pt-br/09-cli/comandos.md) ⭐ NOVO

### 🧪 Testes

* [Começando](Docs/Book.pt-br/08-testes/README.md)

### 📰 Artigos e Tutoriais

* [A História por trás do Dext Framework: Por que criamos?](https://www.cesarromero.com.br/blog/dext-story/)

* [Domain Model e CQRS: Modernizando sua Arquitetura Delphi](https://www.cesarromero.com.br/blog/enterprise-patterns-delphi/)
* [Como implementar CQRS e APIs de Alta Performance sem escrever Controllers](https://www.cesarromero.com.br/blog/database-as-api-cqrs/)

---

## 💻 Requisitos

* **Delphi**: Recomendado Delphi 10.4 Sydney ou superior (devido ao uso extensivo de features modernas da linguagem).
* **Indy**: Utiliza componentes Indy (já inclusos no Delphi) para a camada de transporte HTTP (sujeito a substituição/otimização futura).

## 📦 Instalação e Configuração

> 📖 **Guia Detalhado**: Para um passo a passo completo e configuração avançada, leia o [Guia de Instalação](Docs/Book.pt-br/01-primeiros-passos/instalacao.md).

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/dext-framework/dext.git
   ```

   > 📦 **Nota sobre Pacotes**: O projeto está organizado em pacotes modulares localizados no diretório `Sources` (ex: `Dext.Core.dpk`, `Dext.Web.Core.dpk`, `Dext.Data.dpk`). Você pode abrir `Sources/DextFramework.groupproj` para carregar todos os pacotes de uma vez.

2. **Configure Variável de Ambiente (Opcional, mas Recomendado):**
   Para simplificar a configuração e trocar facilmente entre versões, crie uma Variável de Ambiente de Usuário chamada `DEXT` apontando para o diretório `Sources`.

   * Vá em: **Tools** > **Options** > **IDE** > **Environment Variables**
   * Em **User System Overrides**, clique em **New...**
   * **Variable Name**: `DEXT`
   * **Variable Value**: `C:\caminho\para\dext\Sources` (ex: `C:\dev\Dext\Sources`)

   ![Variável de Ambiente DEXT](Docs/Images/ide-env-var.png)

3. **Configure os Paths no Delphi:**

   * **Library Path** (para compilação):
       * `$(DEXT)\..\Output\$(ProductVersion)_$(Platform)_$(Config)`

   * **Browsing Path** (para navegação no código):
       * `$(DEXT)`
       * `$(DEXT)\Core`
       * `$(DEXT)\Data`
       * `$(DEXT)\Hosting`
       * `$(DEXT)\Web`
       * *(Veja o [Guia de Instalação](Docs/Book.pt-br/01-primeiros-passos/instalacao.md) para a lista completa)*

   > 📝 **Nota**: Arquivos compilados (`.dcu`, binários) serão gerados no diretório `.\Output`.

4. **Dependências:**
   * O framework utiliza `FastMM5` (recomendado para debug de memória).
   * Drivers de banco de dados nativos (FireDAC, etc) são suportados.

---

## ⚡ Exemplo Rápido (Minimal API)

```pascal
program MyAPI;

uses
  Dext.Web;

begin
  // A função global WebApplication retorna IWebApplication (ARC safe)
  var App := WebApplication;
  var Builder := App.Builder;

  // Rota simples
  Builder.MapGet<IResult>('/hello', 
    function: IResult
    begin
      Result := Results.Ok('{"message": "Hello Dext!"}');
    end);

  // Rota com parâmetro e binding
  Builder.MapGet<Integer, IResult>('/users/{id}',
    function(Id: Integer): IResult
    begin
      Result := Results.Json(Format('{"userId": %d}', [Id]));
    end);

  App.Run(8080);
end.
```

## 🧩 Model Binding & Injeção de Dependência

Dext resolve dependências automaticamente e deserializa JSON bodies para Records/Classes:

```pascal
// 1. Registre os Serviços
App.Services.AddSingleton<IEmailService, TEmailService>;

// 2. Defina o Endpoint com Dependências
// - 'Dto': Automaticamente populado a partir do JSON Body (Smart Binding)
// - 'EmailService': Automaticamente injetado do Container de DI
App.Builder.MapPost<TUserDto, IEmailService, IResult>('/register',
  function(Dto: TUserDto; EmailService: IEmailService): IResult
  begin
    EmailService.SendWelcome(Dto.Email);
    Result := Results.Created('/login', 'User registered');
  end);
```

## 💎 Exemplo ORM (Fluent Query)

O Dext ORM permite consultas expressivas e fortemente tipadas, eliminando SQL strings mágicas:

```pascal
// Consulta complexa com Joins e Filtros
// O: TOrder (Alias/Proxy)
var Orders := DbContext.Orders
  .Where((O.Status = TOrderStatus.Paid) and (O.Total > 1000))
  .Include('Customer')
  .Include('Items')
  .OrderBy(O.Date.Desc)
  .Take(50)
  .ToList;

// Bulk Update de alta performance
DbContext.Products
  .Where(P.Category = 'Outdated') // P: TProduct
  .Update                         // Inicia update em massa
  .Execute;
```

## ⚡ Exemplo Async (Fluent Tasks)

Esqueça a complexidade de `TThread`. Use uma API moderna baseada em Promises/Tasks:

```pascal
// Encadeamento de tarefas assíncronas
var Task := TAsyncTask.Run<TUserProfile>(
  function: TUserProfile
  begin
    // Executa em background
    Result := ExternalApi.GetUserProfile(UserId);
  end)
  .ThenBy<Boolean>(
    function(Profile: TUserProfile): Boolean
    begin
      Result := Profile.IsVerified and Profile.HasCredit;
    end)
  .OnComplete( // Volta para a UI Thread automaticamente
    procedure(IsVerified: Boolean)
    begin
      if IsVerified then
        ShowSuccess('User Verified!')
      else
        ShowError('Verification Failed');
    end)
  .Start; // Inicia a execução

// Controle de Timeout e Cancelamento
var CTS := TCancellationTokenSource.Create;

TAsyncTask.Run<TReport>(
  function: TReport
  begin
    // Passa o token para operação de longa duração
    Result := ReportService.GenerateHeavyReport(CTS.Token);
  end)
  .WithCancellation(CTS.Token) // Vincula token à pipeline da Task
  .OnComplete(
    procedure(Report: TReport)
    begin
      ShowReport(Report);
    end)
  .OnException(
    procedure(Ex: Exception)
    begin
      if Ex is EOperationCancelled then
        ShowMessage('Operação expirada (Timeout)!')
      else
        ShowError(Ex.Message);
    end)
  .Start;
```

## 🧪 Exemplos e Testes

O repositório contém projetos de exemplo práticos:

* **`Examples/Orm.EntityDemo`**: Demonstração abrangente dos recursos do ORM (CRUD, Migrations, Consultas).
* **`Examples/Web.ControllerExample`**: Demonstra implementação de API baseada em Controllers (inclui um cliente web em **Vite**).
* **`Examples/Web.SwaggerExample`**: Mostra como integrar e customizar a documentação OpenAPI/Swagger.
* **`Examples/Web.TaskFlowAPI`**: Uma API REST "Mundo Real" completa demonstrando arquitetura em camadas, ORM, Auth e DI.
* **`Examples/Web.SslDemo`**: Demonstra configuração de SSL/HTTPS usando OpenSSL ou TaurusTLS.
* **`Examples/Web.Dext.Starter.Admin`**: **(Recomendado)** Um Painel Administrativo Moderno com HTMX, Camada de Serviço e Minimal APIs. [Leia o Guia](Examples/Web.Dext.Starter.Admin/README.md).
* **`Examples/Web.DatabaseAsApi`**: Demonstra a feature Database as API - REST endpoints zero-code a partir de entities.
* **`Examples/Web.SmartPropsDemo`**: Demonstra o uso de Smart Properties com Model Binding e persistência ORM.
* **`Examples/Hubs/HubsExample`** ⭐ NOVO: Demo de comunicação em tempo real com grupos, mensagens e broadcast de hora do servidor. [Leia o Guia](Examples/Hubs/README.md).
* **`Examples/Desktop.MVVM.CustomerCRUD`** ⭐ NOVO: Desktop moderno com padrão MVVM, Navigator, DI e testes unitários. [Leia o Guia](Examples/Desktop.MVVM.CustomerCRUD/README.md).
* **`Examples/Web.MultiTenancy`** ⭐ NOVO: Demonstra estratégias de isolamento multi-tenant (Schema vs Database).
* **`Examples/Web.HelpDesk`** ⭐ NOVO: Sistema de help desk completo com arquitetura em camadas e testes de integração.
* **`Examples/Web.MinimalAPI`** ⭐ NOVO: Exemplos de APIs minimalistas mostrando o poder das definições de rotas fluentes.
* **`Personal/Web.eShopOnWebByDomain`** ⭐ NOVO: Implementação clássica do eShopOnWeb, demonstrando todo o potencial do Dext em domínios complexos.

---

---

## 🗺️ Roadmaps

Acompanhe o desenvolvimento do projeto:

* [Roadmap Principal](Docs/Book.pt-br/roadmap.md) 🚀
* [Tarefas Pendentes (Trackers)](Docs/Book.pt-br/roadmap/tarefas-pendentes.md) 📋
* [Guia de Arquitetura](Docs/architecture/README.pt-br.md) 🏗️

#### Documentos Históricos
* [Arquitetura & Performance](Docs/History/loose/architecture-performance.pt-br.md)
* [ORM Roadmap (Legado)](Docs/History/roadmaps/orm-roadmap.md)
* [Web Framework Roadmap (Legado)](Docs/History/roadmaps/web-roadmap.md)
* [Infra & IDE Roadmap (Legado)](Docs/History/roadmaps/infra-roadmap.md)
* [Plano de Lançamento V1.0 (Legado)](Docs/History/roadmaps/v1-release-plan.md)

---

**Dext Framework** - *Performance nativa, produtividade moderna.*
Desenvolvido com ❤️ pela comunidade Delphi.
