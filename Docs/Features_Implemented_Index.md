# 📑 Dext Framework — Exhaustive Technical Features Index

Índice mestre exaustivo de todas as funcionalidades implementadas no Dext Framework. Cada item referencia diretamente a unit de implementação nos `Sources/`.

> [!IMPORTANT]
> Gerado via auditoria técnica ("Raio-X") diretamente nos fontes. Nenhuma feature foi omitida ou simplificada.

---

## 🧩 1. Dext Core Foundation (`Sources\Core` + `Sources\Core\Base`)

### 1.1 Reflection Engine (`Dext.Core.Reflection`)
- **TReflection** — Fachada estática de alto desempenho para o sistema RTTI do Delphi. Mantém um `TRttiContext` compartilhado globalmente.
- **Metadata Cache** (`TTypeMetadata`) — Cache global de metadados de tipo (propriedades, campos, atributos) com inicialização thread-safe via `TMREWSync` (Multiple-Read Exclusive-Write). Caminhos hot-path são lock-free (leitura sem lock).
- **Smart Properties** (`Prop<T>`, `Nullable<T>`, `Lazy<T>`) — Detecção automática de wrappers genéricos via análise de `PTypeInfo.Name`. O metadata cache armazena `IsSmartProp`, `IsNullable`, `IsLazy`, `InnerType` e ponteiro direto para `FValue` field.
- **Property Path Resolution** — Resolução recursiva de caminhos aninhados (ex: `User.Address.Street`) via `TReflection.GetPropertyValue` com cache de `TRttiProperty` por segmento.
- **Custom Attribute Scanning** — `GetAttributes<T>` e `HasAttribute<T>` com varredura em campos, propriedades e métodos. Usado por DI, Validation, JSON e ORM.
- **Property Handlers** — `TPropertyHandler` para acesso otimizado a propriedades com cache de getter/setter.

### 1.2 Dependency Injection (`Dext.DI.Core`, `Dext.DI.Interfaces`, `Dext.DI.Attributes`)
- **TDextServices** — Fachada fluente para registro de serviços. Métodos: `AddSingleton<T>`, `AddTransient<T>`, `AddScoped<T>`, `AddSingletonInstance<T>`, `AddSingletonFactory<T>`.
- **TServiceCollection** — Repositório interno de `TServiceDescriptor` com busca reversa (LIFO) para permitir override de registros.
- **TDextServiceProvider** — Container IoC com armazenamento híbrido: `FSingletonInstances` (ARC/Interfaces) + `FSingletonObjects` (Non-ARC/Classes manuais) + `FScopedInstances`/`FScopedObjects` para escopo.
- **Ciclos de Vida** — `Singleton` (instância única global), `Transient` (nova instância por resolução), `Scoped` (instância única por escopo DI via `CreateScope`).
- **Scope Isolation** — `IServiceScope` com `TDextServiceScope` que cria um provider filho isolado. Destruição do scope libera todos os objetos scoped.
- **Auto-Collections** — Resolução automática de `IList<T>`, `IEnumerable<T>`, `IDictionary<K,V>` via `TActivator.IsListType`/`IsDictionaryType`.
- **Atributos DI** — `[Inject]` para injeção em propriedades/campos, `[ServiceConstructor]` para seleção explícita de construtor, overriding a estratégia Greedy.

### 1.3 Object Activator (`Dext.Core.Activator`)
- **TActivator** — Motor central de instanciação dinâmica via RTTI com 4 overloads de `CreateInstance`:
  1. **Manual** — Argumentos posicionais explícitos.
  2. **Pure DI (Greedy Strategy)** — Seleciona o construtor com MAIS parâmetros resolvíveis pelo container. Prioriza construtores da classe mais derivada em caso de empate.
  3. **Hybrid** — Argumentos posicionais iniciais + resolução DI para os restantes.
  4. **PTypeInfo-based** — Instanciação por `PTypeInfo` (suporta classes e interfaces, incluindo auto-instanciação de coleções).
- **[ServiceConstructor] Attribute** — First-pass: se encontrado, o construtor anotado tem prioridade absoluta sobre a estratégia Greedy.
- **Constructor Cache** — Cache thread-safe (`TMREWSync`) de `TConstructorEntry` (método + array de `PTypeInfo` dos parâmetros) para evitar re-scanning RTTI.
- **Field/Property Injection** — `InjectFields` processa `[Inject]` em campos e propriedades após a construção, suportando `TargetTypeInfo` customizado.
- **Default Implementation Registry** — `RegisterDefault(TBase, TImpl)` e `RegisterDefault<TService, TImpl>` para mapeamento base→implementação (ex: `TStrings→TStringList`).

### 1.4 JSON Engine (`Dext.Json`, `Dext.Json.Types`)
- **TDextJson** — Fachada estática de serialização/deserialização com `Serialize<T>` e `Deserialize<T>`.
- **Driver Architecture** — `IDextJsonProvider` plugável (`DextJsonDataObjects` padrão, `System.JSON` alternativo). Drivers implementam `CreateObject`, `CreateArray`, `Parse`.
- **TJsonSettings (Fluent Record API)** — Configuração imutável via chaining: `.CamelCase`, `.SnakeCase`, `.PascalCase`, `.EnumAsString`, `.EnumAsNumber`, `.IgnoreNullValues`, `.CaseInsensitive`, `.ISODateFormat`, `.UnixTimestamp`, `.CustomDateFormat(fmt)`, `.ServiceProvider(p)`.
- **Automatic Casing** (`TCaseStyle`) — 5 modos: `CaseInherit`, `Unchanged`, `CamelCase`, `PascalCase`, `SnakeCase`. Aplicado automaticamente durante serialização.
- **Enum Serialization** (`TEnumStyle`) — `AsNumber` (ordinal) ou `AsString` (nome RTTI do enum).
- **Date Formats** (`TDateFormat`) — `ISO8601`, `UnixTimestamp`, `CustomFormat`. Default: `yyyy-mm-dd"T"hh:nn:ss.zzz`.
- **DOM Abstraction** — `IDextJsonNode`, `IDextJsonObject`, `IDextJsonArray` com tipagem forte (6 node types: Null, String, Number, Boolean, Object, Array).
- **TJsonBuilder** — Builder fluente para construção programática de JSON sem strings.
- **Atributos** — `[JsonName]` (renomear campo), `[JsonIgnore]` (excluir campo), `[JsonCaseStyle]` (override por classe).
- **TUtf8JsonSerializer** (`Dext.Json.Utf8.Serializer`) — Serializador zero-allocation para records. Opera diretamente sobre `TByteSpan` (UTF-8 raw) sem conversão intermediária para `string`. Cache de `TJsonRecordInfo` por `PTypeInfo` para eliminar overhead RTTI em hot-paths. `ToUtf8JSON` no driver `DextJsonDataObjects` para output UTF-8 nativo.

### 1.5 Configuration System (`Dext.Configuration.Core`)
- **TDextConfiguration (Fluent Builder)** — `.AddJsonFile(path)`, `.AddYamlFile(path)`, `.AddEnvironmentVariables(prefix)`, `.AddCommandLine`, `.AddInMemoryCollection`.
- **TConfigurationRoot** — Agregador multi-provider com precedência LIFO (último provider registrado vence). Implementa `IConfiguration`.
- **Hierarchical Keys** — Acesso via `:` separator (ex: `Database:ConnectionString`). `GetSection(key)` retorna sub-árvore.
- **Options Pattern** — `IOptions<T>`, `IOptionsSnapshot<T>`, `IOptionsMonitor<T>` para binding tipado de seções de configuração em records/classes.
- **Section Validators** — `AddSectionValidator(section, validator)` para validação de configuração no startup.
- **Change Tracking** — `IChangeToken` com `OnReload` callback para hot-reload de configuração.

### 1.6 Type System (`Dext.Types.*`)
- **TUUID** (`Dext.Types.UUID`) — Tipo RFC 9562 com armazenamento Big-Endian (Network Byte Order). `NewV4` (random), `NewV7` (time-ordered, 48-bit Unix timestamp ms + random). Conversão implícita bidirecional com `TGUID` (endianness swap automático) e `string`. Operadores `=` e `<>` via `CompareMem`. Compatível com PostgreSQL `uuid` e Web APIs.
- **Nullable\<T\>** (`Dext.Types.Nullable`) — Wrapper genérico para value types anuláveis. `HasValue`, `Value`, `GetValueOrDefault`, `Clear`. Operadores implícitos: `T→Nullable<T>`, `Nullable<T>→T`, `Variant→Nullable<T>`, `Nullable<T>→Variant`. Comparação via `TEqualityComparer<T>.Default`. `TNullableHelper` para acesso low-level via raw `PTypeInfo` sem genéricos.
- **Lazy\<T\>** (`Dext.Types.Lazy`) — Inicialização lazy thread-safe via `TCriticalSection` (double-checked locking). `ILazy` e `ILazy<T>` interfaces. `TLazy<T>` (factory-based) e `TValueLazy<T>` (pre-computed). Operadores implícitos: `T→Lazy<T>`, `Lazy<T>→T`, `TFunc<T>→Lazy<T>`. Ownership management: `AOwnsValue` parameter controla se o valor é destruído com o lazy.

### 1.6b Smart Types & Expression Trees (`Dext.Core.SmartTypes`, `Dext.Specifications.*`)
- **Prop\<T\>** (`Dext.Core.SmartTypes`) — Record genérico que opera em **modo dual**: (1) **Runtime Mode** — armazena valor `T` normalmente, (2) **Query Mode** — gera árvores de expressão (`IExpression` / AST) automaticamente via operator overloading. É o pilar central da **DSL fluente LINQ-like** do Dext.
- **BooleanExpression** — Record híbrido que pode conter um `Boolean` literal OU um nó `IExpression` (AST). Operadores `and`, `or`, `not`, `xor` geram nós `TLogicalExpression` automaticamente em query mode.
- **Type Aliases** — `StringType`, `IntType`, `Int64Type`, `BoolType`, `FloatType`, `CurrencyType`, `DateTimeType`, `DateType`, `TimeType` — aliases semânticos para `Prop<T>` que tornam as entidades autodocumentadas.
- **Operator Overloading Completo** — `=`, `<>`, `>`, `>=`, `<`, `<=`, `+`, `-`, `*`, `/`, negação unária — todos geram `TBinaryExpression` com `boEqual`, `boGreaterThan`, etc., em query mode.
- **String Methods** — `Like`, `StartsWith`, `EndsWith`, `Contains` geram `TFunctionExpression` com a operação correspondente.
- **Collection Methods** — `In(values)`, `NotIn(values)`, `Between(lower, upper)`, `IsNull`, `IsNotNull`.
- **OrderBy** — `Prop.Asc` / `Prop.Desc` retornam `IOrderBy` para composição de ordenação.
- **IPropInfo** — Metadata portado que carrega o nome da coluna física no banco, injetado por `TPrototype`.
- **TQueryPredicate\<T\>** — Delegate `function(Arg: T): BooleanExpression` usado pelo ORM como predicado de query.
- **Expression Tree Nodes** (`Dext.Specifications.Types`) — `TPropertyExpression`, `TLiteralExpression`, `TConstantExpression`, `TBinaryExpression`, `TLogicalExpression`, `TUnaryExpression`, `TFunctionExpression`, `TFluentExpression`.
- **Nullable\<T\> Interop** — Conversão implícita bidirecional entre `Prop<T>` e `Nullable<T>`.
- **Variant Interop** — Conversão implícita bidirecional entre `Prop<T>` e `Variant`.

### 1.7 Value Converter Engine (`Dext.Core.ValueConverters`)
- **TValueConverterRegistry** — Registro global de conversores com lookup em 3 níveis: (1) Exact Match por `PTypeInfo` pair, (2) Kind Match por `TTypeKind` pair, (3) Fallback para `tkVariant` source.
- **TValueConverter** — Motor de execução que orquestra conversões, com tratamento automático de Smart Types (`Prop<T>`) e `Nullable<T>` (detecta via `TReflection.GetMetadata`).
- **20+ Conversores Built-in** — `Variant→Integer/String/Boolean/Float/DateTime/Date/Time/Enum/GUID/Class/TBytes/TUUID`, `Integer→Enum/String`, `String→GUID/TBytes/TUUID/Integer/Float/DateTime/Boolean`, `Float→String`, `Boolean→String`, `Class→Class`.
- **ConvertAndSet / ConvertAndSetField** — Conversão + atribuição via RTTI em uma única chamada (usado pelo ORM e Model Binding).

### 1.8 Memory & Span (`Dext.Core.Span`, `Dext.Core.Memory`)
- **TSpan\<T\>** — Referência zero-allocation a região contígua de memória. `Slice`, `ToArray`, `Clear`, `GetEnumerator` (for-in). Bounds checking em todos os acessos.
- **TReadOnlySpan\<T\>** — Versão imutável de `TSpan<T>`. Operador implícito `TSpan<T>→TReadOnlySpan<T>` e `TArray<T>→TReadOnlySpan<T>`.
- **TByteSpan** — Span especializado para bytes. `Equals` via `TDextSimd.EqualsBytes` (SIMD-accelerated). `EqualsString` compara com UTF-8 sem alocação. `IndexOf`, `ToString` (UTF-8→string), `ToBytes`. Otimizado para parsers JSON/REST e protocolos de rede.
- **ILifetime\<T\>** (`Dext.Core.Memory`) — Wrapper ARC para gerenciamento de lifecycle de objetos Non-ARC. `TLifetime<T>` encapsula objeto e o libera automaticamente quando a interface sai de escopo.
- **IDeferred / TDeferredAction** (`Dext.Core.Memory`) — Padrão Defer (inspirado em Go). Ação executada automaticamente no destructor quando a interface sai de escopo. Útil para cleanup de recursos temporários.

### 1.9 Threading & Async (`Dext.Threading.*`)
- **TAsyncTask** — Implementação fluente de Async/Await para operações assíncronas.
- **ICancellationToken** — Cancelamento cooperativo com `WaitForCancellation(timeout)` e `IsCancellationRequested`. Integrado com Event Bus Lifecycle e Background Services.

### 1.10 Logging Pipeline (`Dext.Logging`)
- **ILoggerFactory** — Factory de loggers com registro de múltiplos providers. `CreateLogger(categoryName)` retorna `ILogger` composto.
- **ILogger** — Interface com métodos por nível: `Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`. Suporte a structured templates com placeholders.
- **Aggregate Logger** — Cada `ILogger` criado pela factory agrega todos os providers registrados, despachando cada log entry para todos simultaneamente.
- **Log Scopes** — `BeginScope(state)` para contexto hierárquico (ex: RequestId, CorrelationId).
- **Níveis** — `Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`, `None`.

### 1.11 I/O Writers (`Dext.Core.Writers`)
- **IDextWriter** — Abstração thread-safe para output do framework. Implementações: `TConsoleWriter` (stdout), `TWindowsDebugWriter` (OutputDebugString com buffering), `TStringsWriter` (TStringList/TMemo), `TNullWriter` (silent).
- **SafeWrite / SafeWriteLn** (`Dext.Utils`) — Funções globais que roteiam output via `IDextWriter` ativo. Detecção automática de console disponível. Escrita Unicode nativa via `WriteConsoleW` (Windows) com fallback UTF-8 para pipes.
- **SafeAttachConsole** — Attach ao console do processo pai (CMD/PowerShell) ou `AllocConsole` para aplicações GUI executadas via F5.

### 1.12 Text Escaping (`Dext.Text.Escaping`)
- **TDextEscaping** — Utilitários centralizados para escaping de texto: `Html`, `Xml`, `Json` (manual character-by-character com suporte a `\uXXXX`), `Url`. Usado por Reporters, Serializers e RestClient.

### 1.13 Date Utilities (`Dext.Core.DateUtils`)
- **TryParseISODateTime** — Parser robusto de ISO 8601 (`YYYY-MM-DDTHH:NN:SS.ZZZ`) com suporte a variações (separador `T` ou espaço, milissegundos opcionais).
- **TryParseCommonDate** — Parser multi-formato: ISO 8601 → `dd/mm/yyyy` → `mm/dd/yyyy` → `yyyy/mm/dd` com detecção automática de formato.

---

## 📚 2. Dext Collections Library (`Sources\Core`)

### 2.1 Core Collections (`Dext.Collections`, `Dext.Collections.Base`)
- **TRawList\<T\>** — Backbone de todas as coleções. Lista genérica baseada em array dinâmico com `Move`-based insertion/deletion para minimizar overhead. Suporte a `for-in` via enumerator customizado.
- **TList\<T\>** / **IList\<T\>** — Lista genérica de alto desempenho. Operações: `Add`, `Insert`, `Remove`, `IndexOf`, `Sort`, `BinarySearch`, `Contains`, `ToArray`.
- **TDictionary\<K,V\>** / **IDictionary\<K,V\>** — Hash map genérico com suporte a `TryGetValue`, `AddOrSetValue`, `ContainsKey`, `Keys`, `Values`.
- **THashSet\<T\>** / **IHashSet\<T\>** — Conjunto de valores únicos com operações de teoria dos conjuntos: `UnionWith`, `IntersectWith`, `ExceptWith`.
- **TCollections (Factory)** — Factory estática: `CreateList<T>`, `CreateDictionary<K,V>`, `CreateHashSet<T>`, `CreateSortedList<T>`, etc.
- **TSmartEnumerator\<T\>** — Enumerador base extensível para iteração customizada em coleções derivadas.

### 2.2 LINQ Extensions (`Dext.Collections.Extensions`)
- **Operações Fluentes** — `Where`, `Select`, `OrderBy`, `OrderByDescending`, `First`, `FirstOrDefault`, `Last`, `Any`, `All`, `Count`, `Sum`, `Min`, `Max`, `Average`, `Distinct`, `Take`, `Skip`, `GroupBy`, `SelectMany`, `Aggregate`, `Contains`, `ToList`, `ToDictionary`, `ForEach`.

### 2.3 Concurrent Collections (`Dext.Collections.Concurrent`)
- **TConcurrentDictionary\<K,V\>** — Dicionário thread-safe com **Lock Striping** via array de `TSpinLock` (múltiplos buckets de lock independentes para reduzir contenção).
- **TConcurrentQueue\<T\>** / **TConcurrentStack\<T\>** — Filas e pilhas thread-safe para cenários producer/consumer.

### 2.4 Frozen Collections (`Dext.Collections.Frozen`)
- **TFrozenDictionary\<K,V\>** / **TFrozenSet\<T\>** — Estruturas imutáveis otimizadas para cenários de leitura intensa (estilo .NET 8 `FrozenDictionary`). Após construção, nenhuma modificação é permitida, permitindo otimizações de layout em memória.

### 2.5 Channels (`Dext.Collections.Channels`)
- **TChannel\<T\>** — Primitiva de comunicação assíncrona estilo Go channels para pipelines Producer/Consumer.
- **Bounded Channel** — Capacidade fixa com back-pressure (writer bloqueia quando cheio).
- **Unbounded Channel** — Capacidade ilimitada (writer nunca bloqueia).
- **ChannelReader / ChannelWriter** — Interfaces segregadas para leitura e escrita.

### 2.6 SIMD & Hardware Acceleration (`Dext.Collections.Simd`)
- **TDextSimd** — Operações vetorizadas com detecção automática de instruction set:
  - `EqualsBytes` — Comparação de arrays de bytes via **AVX2** (32 bytes/ciclo), **SSE2** (16 bytes/ciclo) ou fallback Pascal.
  - `IndexOfByte` — Busca linear acelerada via instruções vetoriais.
  - `FillByte` / `MoveMem` — Preenchimento e cópia de memória otimizados.
- **Runtime Detection** — Detecção via CPUID no startup. Seleção automática do melhor path disponível.

### 2.7 Comparers & Algorithms (`Dext.Collections.Comparers`, `Dext.Collections.Algorithms`)
- **TEqualityComparer\<T\>** / **TComparer\<T\>** — Comparadores genéricos padrão com suporte a tipos primitivos, records e classes.
- **Algoritmos** — `Sort` (IntroSort), `BinarySearch`, `Reverse`, `Shuffle`.

---

## 🌐 3. Dext Web Framework (`Sources\Web`)

### 3.1 Bootstrapping & Minimal API
- **TWebApplication** — Fachada fluente para inicialização: carrega automaticamente `appsettings.json`, `appsettings.yaml`, Environment Variables, registra serviços e constrói o pipeline em uma única cadeia.
- **Minimal API** — Registro direto de handlers via delegates sem controllers (`app.MapGet`, `app.MapPost`).

### 3.2 Middleware Pipeline
- **Chain of Responsibility** — Middlewares funcionais (delegates anônimos) e baseados em classe com injeção de dependência via construtor.
- **Built-in Middlewares** — Logger, Compression (GZip/Brotli), Exception Handling (**ProblemDetails** RFC 9457), **DeveloperExceptionPage**, CORS, StartupLock.

### 3.3 Routing Engine
- **Parâmetros Dinâmicos** — Rotas com `{id}`, `{slug}`, restrições de tipo.
- **API Versioning** — `THeaderApiVersionReader`, `TQueryStringApiVersionReader`, `TPathApiVersionReader`, `TCompositeApiVersionReader` (composição de múltiplas estratégias).

### 3.4 Model Binding
- **Hybrid Binding** — Atributos `[FromBody]`, `[FromQuery]`, `[FromRoute]`, `[FromHeader]`, `[FromServices]`.
- **Zero-Allocation** — Deserialização UTF-8 direta para records e classes via `TByteSpan`.
- **Multipart/Form-Data** — Processamento de uploads via abstração `IFormFile`.
- **Object Lifecycle Management** — Tracking de objetos criados por Model Binding com integração ao **ChangeTracker** do ORM para transferência automática de ownership.

### 3.5 Hosting
- **IWebHost / IWebHostBuilder** — Abstrações de hospedagem. Suporte a **Portas Dinâmicas (Porta 0)** com atribuição automática pelo SO.
- **Server Adapters** — Indy (padrão, OpenSSL/Taurus SSL), **WebBroker Adapter** (ISAPI/CGI para IIS/Apache), **DCS Adapter** (Delphi-Cross-Socket, non-blocking).
- **IHostedService** — Tarefas de background com `StartAsync`/`StopAsync`. `TBackgroundService` com `Execute(ICancellationToken)`.
- **IHostApplicationLifetime** — Tokens para `ApplicationStarted`, `ApplicationStopping`, `ApplicationStopped`.

### 3.6 Security & Identity
- **IClaimsPrincipal** — Autenticação JWT, Basic Auth (RFC 7617) e Cookies.
- **Rate Limiting** — Fixed Window, Sliding Window, Token Bucket, Concurrency Limiter.

### 3.7 Real-time & Caching
- **SSE (Server-Sent Events)** — Streaming unidirecional de eventos.
- **Hubs (SignalR-compatible)** — Grupos, targeting por usuário, broadcast via JSON.
- **Caching** — In-Memory e Redis. **Health Checks** detalhados.

### 3.8 API Documentation & Scaffolding
- **OpenAPI / Swagger** — Geração automática de especificação.
- **Auto-Migrations (S11)** — Sincronização automática de schema durante startup com detecção de renomeação de tabelas/colunas via atributos.
- **View Engine & WebStencils (S09)** — Motor de templates baseado em AST (estilo Razor), zero-dependência.

### 3.9 Database as API (`Dext.Web.DataApi`)
Uma das features mais poderosas do Dext: **geração automática de APIs REST completas a partir de entidades ORM — com uma única linha de código**. Não é um scaffold que gera código — é um runtime handler que mapeia entities para endpoints dinamicamente.

#### Registro (3 modos coexistentes)
- **Automático por Atributo** — `[DataApi]` na entidade + `App.MapDataApis` no startup. `TDataApi.MapAll` escaneia RTTI e registra todas as entidades decoradas automaticamente.
- **Manual tipado** — `TDataApiHandler<TProduct>.Map(App, '/api/products')`.
- **Manual Fluente** — `App.Builder.MapDataApi<T>(path, DataApiOptions.AllowRead.RequireAuth)`.

#### 5 Endpoints CRUD Gerados
| Método | Rota | Handler |
|---|---|---|
| `GET` | `/api/{entity}` | `HandleGetList` — Lista com paginação, ordenação e filtros |
| `GET` | `/api/{entity}/{id}` | `HandleGet` — Busca por PK (simples ou composta) |
| `POST` | `/api/{entity}` | `HandlePost` — Cria novo registro, retorna 201 |
| `PUT` | `/api/{entity}/{id}` | `HandlePut` — Atualiza registro existente |
| `DELETE` | `/api/{entity}/{id}` | `HandleDelete` — Remove registro |

#### Dynamic Specification Mapping (Filtros via QueryString)
- **11 operadores** parseados automaticamente da URL: `_eq`, `_neq`, `_gt`, `_gte`, `_lt`, `_lte`, `_cont` (LIKE %x%), `_sw` (LIKE x%), `_ew` (LIKE %x), `_in` (IN), `_null` (IS NULL).
- **Paginação** — `?_limit=20&_offset=40`.
- **Ordenação** — `?_orderby=price desc,name asc`.
- **Resolução de nomes** — `ResolvePropertyName` via `TReflection.GetMetadata().GetHandlerBySnakeCase` para converter snake_case da URL para PascalCase da propriedade Delphi.
- Cada filtro gera um `IExpression` via `TStringExpressionParser.Parse` e é injetado no `ISpecification` — a mesma AST usada pelas Smart Properties.

#### TDataApiOptions — API Fluente de Configuração
- **Segurança** — `RequireAuth`, `RequireRole(roles)`, `RequireReadRole(roles)`, `RequireWriteRole(roles)` — Separação de permissões read/write com validação JWT integrada via `IClaimsPrincipal`.
- **Métodos Permitidos** — `Allow([amGet, amGetList])` restringe quais endpoints são gerados.
- **Multi-Tenancy** — `RequireTenant` para isolamento por tenant.
- **Naming Strategy** — `UseSnakeCase`, `UseCamelCase` para controle de casing na serialização.
- **Enum Style** — `EnumsAsStrings`, `EnumsAsNumbers`.
- **DbContext Explícito** — `DbContext<TMyContext>` para selecionar qual contexto usar.
- **SQL Customizado** — `UseSql('SELECT ...')` para queries customizadas.
- **Swagger** — `UseSwagger`, `Tag('Products')`, `Description('...')` para documentação automática.

#### Convenções de Nomenclatura (`TDataApiNaming`)
- **Auto-Discovery** — Prefixo `T` removido automaticamente via `TReflection.NormalizeFieldName`.
- **Pluralização** — Inglês: `y→ies`, `ch/sh/x/s→es`, default `→s` (ex: `TCategory` → `/api/category`).
- **Rotas Customizadas** — `[DataApi('/meu/caminho')]` sobrescreve convenção.
- **Case Mapping** — `PascalCase` na propriedade Delphi → `snake_case` na URL para filtros.

#### Entity ID Resolver (`TEntityIdResolver`)
- **Resolução automática de tipo de PK** — Delega ao `IModelBinder` para conversão transparente: Integer, String, TUUID, TGUID.
- **Composite Keys** — Separador `|` para chaves compostas (ex: `/api/entity/1|ABC`).

#### Integração com o Ecossistema
- **DI Scope** — `GetDbContext` resolve o `TDbContext` do DI container (suporta múltiplos contextos via `ContextClass`).
- **Telemetria** — `TDiagnosticSource.Write('DataApi.ModelBinding.Start/Complete')` emite eventos rastreáveis.
- **Logging** — Todos os handlers emitem logs via `Log.Debug`/`Log.Error` com structured templates.
- **Serialização** — `TDextJson.Deserialize` + `TDextSerializer` com settings configuráveis per-endpoint.
- **Swagger** — Endpoints registrados aparecem automaticamente na documentação OpenAPI.
- **`[DataApiIgnore]`** — Atributo para excluir entidades específicas do scan automático.

---

## 📊 4. Dext ORM & Entity Framework (`Sources\Data`)

### 4.1 Core Persistence
- **TDbContext** — Unit of Work com **Change Tracking** automático (estados: Added, Modified, Deleted, Unchanged). **Identity Map** para unicidade de instâncias por chave primária.
- **DbSet\<T\>** — Repository genérico. Operações: `Add`, `Update`, `Remove`, `Find`, `FirstOrDefault`, `Where`, `Include`, `ToList`.
- **SaveChanges** — Persiste todas as mudanças rastreadas em uma transação.

### 4.2 Query Engine (LINQ-like)
- Query fluída com **Projeção (Select)**, **Paging** (`Skip`/`Take`), **Aggregates** (`Count`, `Sum`, `Max`, `Min`, `Average`).
- **SQL Cache** — Reaproveitamento de comandos SQL gerados para queries repetidas.
- **Pessimistic Locking** — `FOR UPDATE` para controle de concorrência.
- **Multi-Mapping** (estilo Dapper) — Recursive hydration via atributo `[Nested]`.

### 4.3 Specification Pattern (`Dext.Specifications`)
- **Fluent Specification Builder** — `Where`, `OrderBy`, `Include`, `Take`, `Skip` para regras de negócio desacopladas e reutilizáveis.
- **TExpressionEvaluator** (`Dext.Specifications.Evaluator`) — Avaliador **in-memory** da mesma AST usada pelo SQL Compiler. Avalia `IExpression` contra objetos (`TObject`) ou dicionários (`TDictionary<string, Variant>`). Suporta: comparações (`=`, `<>`, `>`, `>=`, `<`, `<=`), `LIKE` (case-insensitive com `%`), `IN`/`NOT IN`, `IS NULL`/`IS NOT NULL`, operações bitwise (`AND`/`OR`/`XOR`), aritmética (`+`, `-`, `*`, `/`, `mod`, `div`), short-circuit em `AND`/`OR`. Faz **unwrap automático de `Prop<T>`** (Smart Types) via RTTI.
- **TStringExpressionParser** (`Dext.Specifications.Parser`) — Parser que converte strings no formato `"Campo Operador Valor"` para nós `IExpression`. Conversão automática de tipos: Boolean, Float (invariant), Integer, String. Usado internamente pelo **Database as API** para transformar filtros da QueryString em expression trees.
- **IExpressionVisitor** — Padrão Visitor para percorrer a árvore de expressão, usado tanto pelo SQL Compiler (gerando SQL) quanto pelo Evaluator (filtrando in-memory).

### 4.4 Relationships & Loading
- **One-to-One**, **One-to-Many**, **Many-to-Many**.
- **Lazy Loading** via Proxy Objects (interceptação transparente).
- **Eager Loading** — `Include`/`ThenInclude` para pré-carregamento de grafos.

### 4.5 Migrations System
- Evolução Code-First automatizada com snapshots cronológicos do modelo de dados.

### 4.6 Dialect Support (Poliglota)
- PostgreSQL, SQL Server, MySQL, SQLite, Oracle, Firebird.
- **Legacy Paging** — Envelopamento automático para `ROWNUM` em Oracle/SQL Server antigos.

### 4.7 Soft Delete (`[SoftDelete]`)
- **Atributo Declarativo** — `[SoftDelete('IsDeleted')]` transforma `Remove()` em `UPDATE` automático.
- **Valores Customizados** — `[SoftDelete('Status', 99, 0)]` para inteiros/enums.
- **HardDelete** — `Db.Tasks.HardDelete(Task)` para exclusão física.
- **Restore** — `Db.Tasks.Restore(Task)` para restaurar registros soft-deleted.
- **Query Filters Automáticos** — Registros excluídos ficam **invisíveis** por padrão. `IgnoreQueryFilters` para ver tudo, `OnlyDeleted` para a lixeira.
- **IdentityMap Cleanup** — Entidades soft-deleted são removidas do cache de memória após `SaveChanges`.

### 4.8 JSON/JSONB Column Queries (`[JsonColumn]`)
- **Atributo `[JsonColumn]`** — Marca propriedades string como colunas JSON. `[JsonColumn(True)]` para JSONB no PostgreSQL.
- **Query Fluente** — `.Json('path')` para consultar propriedades dentro de colunas JSON: `Prop('Settings').Json('role') = 'admin'`.
- **Propriedades Aninhadas** — `Prop('Settings').Json('profile.details.level') = 5` com notação de ponto.
- **IS NULL** — `Prop('Settings').Json('nonexistent').IsNull` para chaves inexistentes.
- **Cross-Database** — PostgreSQL (`#>>` / JSONB indexado), MySQL (`JSON_EXTRACT` / `JSON_UNQUOTE`), SQLite (`json_extract` + JSON1), SQL Server (`JSON_VALUE`).
- **INSERT com Cast** — `::jsonb` automático no PostgreSQL para `[JsonColumn(True)]`.

### 4.9 EntityDataSet (`Dext.Data.EntityDataSet`)
- Componente VCL/FMX com **Design-Time Data Preview**, Sorting e Filtering inline.
- **Zero-Allocation** — Leitura via offsets de memória via `TEntityMap`, sem replicação de objetos.
- **`LoadFromUtf8Json`** — Carregamento direto de `TByteSpan` JSON sem conversão de encoding.
- **Filtros por Expressão** — `DataSet.Filter := 'Score > 100'` com avaliação in-memory.
- **Design-Time Verbs** — "Sync Fields" (incremental, preserva customizações) e "Refresh Entity" (hard reset).
- **Auto-Stabilization** — `Active` nunca é salvo como `True` no DFM; trocar `EntityClassName` reconstrói campos automaticamente.
- **DML Memory Mode** — Append, Edit, Delete operacionais em memória.

### 4.10 Inheritance Mapping
- **TPH (Table-Per-Hierarchy)** — Hidratação polimórfica automática baseada em discriminadores via atributos.

### 4.11 Advanced Features
- **Streaming Iterators** (Flyweight pattern) — O(1) de memória para renderizar grandes volumes em views SSR. `TStreamingViewIterator<T>` itera sob demanda durante o `@foreach` do template.
- Conversores automáticos para GUID, Enums, JSONB e UUID v7.
- **Stored Procedures** — Execução declarativa via `[StoredProcedure]` e `[DbParam]`.
- **Multi-Tenancy** — Banco Compartilhado (TenantId), Isolamento por Schema (`search_path`), Tenant per Database.

---

## 🔌 5. Dext Net — HTTP Client & Authentication (`Sources\Net`)

### 5.1 REST Client (`TRestClient`)
- **Record Leve** — `TRestClient` é um record; pool de conexões compartilhado e thread-safe internamente.
- API fluente com Connection Pooling, retry automático com backoff exponencial e suporte a Async/Await.
- **Typed Responses** — `Client.Get<TUser>('/users/1')` com deserialização automática.
- **Async Chaining** — `Client.Get<TToken>('/auth').ThenBy<TUser>(...)`.OnComplete(...)`.Start`.
- **Cancellation** — `ICancellationToken` para abortar requisições em andamento.
- **Pluggable Auth** — `TBearerAuthProvider`, `TBasicAuthProvider`, `TApiKeyAuthProvider`.
- **Thread Safety** — Snapshot imutável da configuração no `Execute`; execução isolada via pool.
- **Response Headers** — Acesso completo via `GetHeader` (case-insensitive) e `GetHeaders` (TNetHeaders array).
- **THttpRequestInfo** — Integração com parsers `.http` para execução de requisições ad-hoc.

### 5.2 Authentication Providers
- **Bearer Token (JWT)** — Envio automático de `Authorization: Bearer <token>`.
- **Basic Auth (RFC 7617)** — Encoding Base64 de `user:password`.
- **API Key** — Header ou query string customizável.
- **OAuth 2.0 Client Credentials (RFC 6749 §4.4)** — Token caching automático, refresh thread-safe com margem de segurança de 30s para evitar uso de tokens expirados.

---

## 📢 6. Dext Event Bus (`Sources\Events`)

### 6.1 Core Architecture (`Dext.Events.Interfaces`, `Dext.Events.Bus`)
- **IEventBus** — Barramento central de eventos in-memory para desacoplamento total entre produtores e consumidores.
- **IEventHandler\<T\>** — Interface tipada para handlers de eventos. Múltiplos handlers por tipo de evento, executados em ordem de registro.
- **IEventPublisher\<T\>** — Fachada ISP (Interface Segregation Principle) para componentes que publicam apenas um tipo de evento.
- **Dispatch Síncrono** — `IEventBus.Dispatch` invoca todos os handlers e retorna `TPublishResult` com estatísticas (`HandlersInvoked`, `HandlersFailed`, `HandlersSucceeded`).
- **Dispatch Assíncrono** — `DispatchBackground` executa handlers em thread separada com escopo DI isolado (fire-and-forget).
- **TEventBusExtensions** — Helpers estáticos genéricos `Publish<T>` e `PublishBackground<T>` que fazem boxing do evento para `TValue` e delegam ao `IEventBus`.

### 6.2 Behavior Pipeline (`Dext.Events.Behaviors`)
- **IEventBehavior** — Middleware cross-cutting para o pipeline de eventos. Método `Intercept(AEventType, AEvent, ANext)` — chamar `ANext()` continua o pipeline; omitir short-circuits.
- **TEventLoggingBehavior** — Logging estruturado via `ILogger`. Debug antes/depois do handler com elapsed time. Error com re-raise em falhas.
- **TEventTimingBehavior** — Debug-only, registra tempo de dispatch via `OutputDebugString`.
- **TEventExceptionBehavior** — Wrapping estruturado de exceções em `EEventDispatchException` com nome do tipo de evento. Re-raise preserva contexto original.
- **Behaviors Globais vs Per-Event** — Globais aplicam-se a todos os eventos; Per-event aplicam-se apenas ao tipo específico e executam DENTRO dos globais.

### 6.3 DI Extensions (`Dext.Events.Extensions`)
- **`Services.AddEventBus`** — Registra `IEventBus` como Singleton (cada Publish cria escopo DI filho).
- **`Services.AddScopedEventBus`** — Registra como Scoped (handlers compartilham o mesmo escopo, ideal para web requests com DbContext compartilhado).
- **`Services.AddEventHandler<TEvent, THandler>`** — Registro tipado de handler com auto-registro Transient (respeita registros existentes).
- **`Services.AddEventBehavior<T>`** — Behavior global. **`AddEventBehaviorFor<TEvent, T>`** — Behavior per-event.
- **`Services.AddEventPublisher<T>`** — Registra `IEventPublisher<T>` transient para injeção ISP.
- **`Services.AddEventBusLifecycle`** — Registra `TEventBusLifecycleService` como `IHostedService`.

### 6.4 Lifecycle Events (`Dext.Events.Lifecycle`)
- **TEventBusLifecycleService** — Background service que escuta `IHostApplicationLifetime` e publica `TApplicationStartedEvent`, `TApplicationStoppingEvent`, `TApplicationStoppedEvent` no `IEventBus`.
- **Hosting Bridge** (`Dext.Hosting.Events.Bridge`) — `THostingLifecycleEventBridge` para integração com o background services builder via `AddLifecycleEvents`.

### 6.5 Testing Support (`Dext.Events.Testing`)
- Infraestrutura para testes de handlers e behaviors com mocking do pipeline.

### 6.6 Aggregate Exception Handling
- **EEventDispatchAggregate** — Exceção agregada contendo `Errors: TArray<string>` com uma entrada por handler que falhou. Todos os handlers sempre são invocados antes do raise.

---

## 🧪 7. Dext Testing Framework (`Sources\Testing`)

### 7.1 Test Runner & Dashboard
- Executor CLI de alta velocidade e host visual interno para monitoramento em tempo real com histórico de falhas.

### 7.2 Attribute-Based Runner
- Escrita de testes baseada em atributos: `[Fixture]`, `[Test]`, `[Setup]`, `[TearDown]`, `[TestCase]` — sem necessidade de herança de classes base.

### 7.3 Assertions & Mocking
- API fluente de asserções rica. Framework de **Mocking dinâmico** via Proxies.
- **Soft Asserts** — `Assert.Multiple` para coletar múltiplas falhas antes de reportar.
- **Auto-Mocking Container** — `TAutoMocker` para injeção automática de mocks em testes unitários e de integração.

### 7.4 Snapshot Testing
- `MatchSnapshot` — Verificação de objetos complexos e payloads via comparação de baselines JSON.

### 7.5 IDE Integration & CI/CD
- Suporte nativo ao **TestInsight**. Geração de relatórios em HTML, JSON, XML (JUnit), xUnit, TRX (Azure DevOps) e SonarQube.

### 7.6 Code Coverage
- **`dext test --coverage`** — Geração de relatórios de cobertura de código prontos para integração com SonarQube.
- **Quality Gates** — Thresholds configuráveis de cobertura mínima para CI/CD pipelines.

---

## 🎨 8. Dext Template Engine (`Sources\Core\Base\Dext.Templating`)

### 8.1 Core Architecture
- **ITemplateEngine** — Interface principal: `Render(template, context)` e `RenderTemplate(name, context)`.
- **TDextTemplateEngine** — Implementação completa com parser de AST (Abstract Syntax Tree). Cada diretiva é compilada em um nó (`TTemplateNode`) com método `Render`.
- **ITemplateContext** — Contexto hierárquico com valores string, objetos e listas. `CreateChildScope` para escopo aninhado.

### 8.2 Template Loader
- **ITemplateLoader** — Interface plugável para carregamento de templates. Implementações: FileSystem e In-Memory.

### 8.3 Node Types (AST)
- `TTextNode` (texto literal), `TExpressionNode` (interpolação `{{ var }}`), `TIfNode`/`TElseIfNode`/`TElseNode` (condicionais), `TForEachNode` (iteração com `@index`, `@first`, `@last`), `TBlockNode` (blocos nomeados), `TExtendsNode` (herança de layout), `TSectionNode` (seções), `TMacroNode` (macros reutilizáveis), `TBreakNode`/`TContinueNode` (controle de fluxo em loops).

### 8.4 Expression Engine
- Parser de expressões com suporte a operadores aritméticos, comparação, lógicos (`and`, `or`, `not`).
- **Chained Filters** — `{{ value | upper | truncate(10) }}` com pipeline de filtros.
- **Filter Registry** (`ITemplateFilterRegistry`) — `RegisterFilter(name, func)` para filtros customizados.
- **Built-in Filters** — `upper`, `lower`, `capitalize`, `truncate`, `default`, `date`, `html_escape`, etc.

### 8.5 Advanced Features
- **Layout Inheritance** — `{% extends "base.html" %}` com override de blocos.
- **Whitespace Control** — `{%- -%}` para controle de whitespace em diretivas.
- **HTML Mode** — `IsHtmlMode` para auto-escaping de output.
- **Source Position Tracking** — `TSourcePos` com linha, coluna e filename para error reporting preciso.
- **ETemplateException** — Exceções com posição e snippet do template para debugging.

---

## ✅ 9. Dext Validation Engine (`Dext.Validation`)

- **Attribute-Based Validation** — Decoradores RTTI: `[Required]`, `[StringLength(min, max)]`, `[Range(min, max)]`, `[RegularExpression(pattern)]`, `[EmailAddress]`, `[Url]`.
- **TValidator** — Helper não-genérico: `Validate(obj)` retorna `TValidationResult` com lista de `TValidationError` (campo + mensagem).
- **TValidator\<T\>** — Versão genérica tipada.
- **Custom Validators** — Herança de `ValidationAttribute` para regras de negócio customizadas.
- **Integração Web** — Validação automática de models no Model Binding pipeline.

---

## 🔄 10. Dext Mapper (`Dext.Mapper`)

- **TMapper** — AutoMapper-like para transformação DTO↔Entity.
- **CreateMap\<TSource, TDest\>** — Registro de mapeamento com reflexão automática de propriedades por nome.
- **ForMember** — Override de mapeamento para propriedades específicas com expressões lambda customizadas.
- **Map\<TSource, TDest\>** — Execução de mapeamento com criação automática da instância destino.
- **Collection Mapping** — Mapeamento automático de listas e arrays.

---

## 🏢 11. Dext Multi-Tenancy (`Dext.MultiTenancy`)

- **ITenantProvider** — Abstração para identificação do tenant atual.
- **ITenantConnectionStringProvider** — Resolução dinâmica de connection strings por tenant.
- **Estratégias** — Shared Database (discriminador TenantId), Schema Isolation (`search_path` no PostgreSQL), Database per Tenant.
- **Integração DI** — Registro como serviço Scoped para resolução por request.

---

## 🖥️ 12. Desktop UI & Design-Time (`Sources\UI`, `Sources\Design`)

### 12.1 Navigator Framework (Flutter-style)
- **ISimpleNavigator** — Navegação Push/Pop/Replace/PopUntil com passagem de dados via `TValue`.
- **3 Adapters** — `TCustomContainerAdapter` (embutir frames em painel), `TPageControlAdapter` (tabs), `TMDIAdapter` (janelas filhas).
- **Middleware Pipeline** — `TLoggingMiddleware`, `TAuthMiddleware`, `TRoleMiddleware` — mesma arquitetura do Web pipeline.
- **Lifecycle Hooks** — `INavigationAware` com `OnNavigatedTo(Context)` e `OnNavigatedFrom`.
- **DI Integration** — Navigator registrado como serviço Singleton no container.

### 12.2 Magic Binding (`Dext.UI.Binding`)
- **Two-Way Binding por Atributos** — `[BindEdit('Name')]`, `[BindCheckBox('Active')]`, `[BindText('ErrorMessage')]`.
- **Nested Properties** — `[BindEdit('Customer.Address.City')]` com notação de ponto.
- **Message Dispatch** — `[OnClickMsg(TSaveMsg)]` elimina handlers `OnClick` manuais.
- **Custom Converters** — `IValueConverter` com `Convert`/`ConvertBack` para tipos complexos (ex: `TCurrencyConverter`).
- **TBindingEngine** — Motor central que sincroniza ViewModel ↔ UI automaticamente.

### 12.3 MVVM Patterns
- Arquitetura limpa com ViewModel + Controller + DI.
- **Integração com Validação** — `FViewModel.Validate` com erros automaticamente refletidos na UI via binding.

### 12.4 Infraestrutura
- **Interception Engine** — Motor de proxy para intercepção de métodos, base para Mocks e recursos de AOP (Aspect-Oriented Programming).
- **Design-Time Experts** — Data Preview em IDE Grid e editores de propriedades especializados para metadados.

---

## 🛠️ 13. Dext CLI & Scaffolding (`Tools\Dext.Tool.Scaffolding`)

- **Dext CLI (S01)** — Motor CLI unificado (`dext.exe`) para gerenciamento de projetos.
- **Advanced Scaffolding** — Geração de projetos e arquivos via templates inteligentes: `dext new` (projetos), `dext add` (controllers, entidades, middlewares).
- **Template Logic** — Integração direta com o motor **Dext.Templating** para lógica complexa dentro dos templates de scaffolding.
- **Dext Doc** — Geração automatizada de documentação técnica do projeto.
- **`dext test`** — Execução de testes e geração de relatórios de cobertura via CLI.
- **`dext ui`** — Dashboard web para monitoramento de testes em tempo real.

---

## 🔍 14. Observabilidade & Telemetria (`Sources\Core\Base`)

- **TDiagnosticSource (S03)** — Publicador de eventos centralizado baseado em payloads JSON, garantindo desacoplamento entre produtores (ORM, Web) e consumidores.
- **Telemetry Bridge** (`Dext.Logging.Telemetry`) — Integração automática com `ILogger`, permitindo visualizar telemetria HTTP e SQL no console ou arquivos de log.
- **SQL Capture** — Extração e formatação de instruções SQL nativas do ORM para auditoria em tempo real.
- **HTTP Life-cycle** — Tracing de latência, códigos de status e rotas do framework web.

---

## 🤖 15. AI Skills & Developer Experience (`Docs\ai-agents`)

- **Native AI Skills** — Arquivos de instrução modulares (`dext-web.md`, `dext-orm.md`, `dext-auth.md`) que ensinam assistentes de IA (Cursor, Antigravity, Copilot, Claude) a gerar código idiomático Dext.
- **3 modos de integração** — Cópia direta para `.agents/skills/`, configuração global customizada, ou symlinks.
- **Modular por Design** — Skills atômicos para poupar tokens de contexto; carregue apenas o módulo relevante para a feature atual.
- **Compatibilidade** — Claude Code, Cursor, Antigravity, Cline, OpenCode, GitHub Copilot.

---

## 🌐 16. SSR & View Engines — Features Avançadas

### 16.1 HTMX Integration
- **Auto-Detection** — O pipeline detecta automaticamente headers `HX-Request` vindos do navegador e **suprime o layout global** em endpoints compatíveis.
- **Partial Rendering** — `Results.View<T>('fragment', Query).WithLayout('')` para renderização de fragmentos parciais sem layout.
- **Full-Stack SPA Feel** — Combina SSR server-side com substituições dinâmicas HTMX para apps altamente responsivos sem JavaScript pesado.

### 16.2 Flyweight Iterators (Streaming SSR)
- **O(1) Memory** — `TStreamingViewIterator<T>` itera sob demanda durante o `@foreach` do template. 10.000 registros renderizados usando memória equivalente a **um único objeto**.
- **Sem `ToList`** — Passe `Db.Customers.QueryAll` diretamente para `Results.View<T>('customers', Query)` e o framework engata o streaming automaticamente.
- **Smart Properties in Templates** — `@(Prop(item.Name))` para unwrap automático de `Prop<T>` dentro de templates HTML.

### 16.3 Web Stencils (Delphi 12.2+)
- **Provider Nativo** — `Services.AddWebStencils(...)` com whitelist de entidades via `TWebStencilsProcessor.Whitelist.Configure`.
- **Agnóstico** — Mesma interface `IViewEngine` para Dext Template Engine e Web Stencils; troque sem alterar código.

---

*Dext Framework — Exhaustive Technical Map & Features Index. (Revision: April 22, 2026).*
