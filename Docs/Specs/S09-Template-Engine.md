# S09 — Motor de Templates (Dext.Templating): Arquitetura e Sintaxe

## 1. Visão Geral

O Dext Framework exige um motor de geração (scaffolding) de altíssima performance e com excelente Developer Experience (DX). 

Conforme definido na arquitetura evolutiva do framework, o mecanismo de *scaffolding* ocorre em dois níveis separados inspirados no ecossistema .NET:

1. **Project Templates (`dotnet new` style):**
   Projetos-base que são mantidos como código Delphi 100% válido (arquivos `.dpr`, `.pas`, `.dproj` que compilam isoladamente na sua pasta). São controlados por um manifesto (`dext-template.json`) que orienta substituições globais de texto (como Nomes de Projeto, Namespaces e GUIDs do sistema). É muito mais fácil para nós mantermos projetos base sem templates inline intrusivos.
   
2. **Code Scaffolding (T4 / Razor Engine style):**
   Utilizado para geração de arquivos baseados em modelos reais (ex: ler o banco de dados via `ISchemaProvider` e cuspir uma Unit de Entidade preenchida). Para essa fase, o motor precisa de abstração imperativa: laços (`for`), condições (`if`) e formatações parciais. 

---

## 2. A Sintaxe Razor-Inspired (DX-Friendly)

Concordando 100% com a visão arquitetural moderna: **rejeitamos a limitação "logic-less" do Mustache (`{{ }}`)**. Embora o Mustache sirva bem para views muito simples, o Scaffolding avançado demanda acesso a sub-nós organizados. Além disso, a sintaxe T4 (`<#= Model #>`) polui excessivamente a leitura do programador.

O Dext adota uma sintaxe similar ao **Razor** (no .NET) e ao **WebStencils**, baseada no indicador `@`, que flui naturalmente sem concorrer com a gramática rígida do Delphi (como chaves e colchetes).

### 2.1. Expressões e Variáveis

A avaliação de expressões utiliza o prefixo `@`.

```delphi
// Template Válido em Sintaxe Dext-Razor
unit @Model.Namespace.Entities;

interface

type
  [Table('@Model.TableName')]
  T@Model.EntityName = class(TEntity)
  private
    FId: Integer;
  public
    // ...
  end;
```

### 2.5. Escaping & Web Views (Modo Híbrido)

O Motor de Templates do Dext operará em dois contextos principais: **Scaffolding de Código-Fonte** e **Web Views (Frontend)**. O motor exigirá uma política configurável de *Escaping*:

1. **Raw Mode (Code Generation):** 
   - Ao processar código nativo (`.pas.template`, `.json`, etc.), utilizamos texto puro (Raw). Símbolos estruturais (`>`, `<`, `&`) permanecem imutáveis.
2. **HTML Mode (Web Views / Reports):** 
   - Ao processar web views, as variáveis reativas (`@Model.TextoUsuario`) devem sofrer HTML Escape automático na saída prevenindo XSS.
3. **Mecanismo de ByPass (Raw Output):**
   - Caso uma Web View precise renderizar HTML não-escapado explicitamente, um modifier como `@Html.Raw(Model.Prop)` ou `@Model.Prop.AsRaw()` deve ser fornecido.

*(Nota: Diferente do Razor Web puro, o padrão da nossa configuração de Engine na CLI dext_gen será sempre Raw, enquanto os endpoints Web dentro do Server ativarão Html Mode por padrão no ITemplateEngine).*
Caso o código original Delphi realmente necessite imprimir um literal `@`, basta ser duplicado: `@@`.

### 2.2. Lógica de Decisão (If/Else)

Diferente do C# no Razor, que acopla blocos estruturais em chaves `{ }`, no Delphi as chaves são meros comentários. Logo, para suportar indentação adequada sem depender do parser imperfeito do texto, adotamos delimitação clara via `@endif` ou blocos inline:

```razor
@if (Col.IsPrimaryKey)
  [PK, AutoInc]
@elseif (Col.IsUnique)
  [Unique]
@else
  [Column('@Col.DBName')]
@endif
property @Col.Name: @Col.DataType;
```

### 2.3. Lógica de Iteração (Foreach)

O motor entende a capacidade de caminhar em Generics e listas que foram registradas para a RTTI otimizada.

```razor
  private
@foreach (Col in Model.Columns)
    F@Col.Name: @Col.DataType;
@endforeach

  public
@foreach (Col in Model.Columns)
    property @Col.Name: @Col.DataType read F@Col.Name write F@Col.Name;
@endforeach
```

### 2.4. Funções Padrões e Mutators

String manipulations nativos acoplados por sintaxe pipe/dot na avaliação sem gerar ruído:

```razor
T@Model.TableName.ToPascalCase() = class(TDataApi)
// Output: TCustomerOrder = class(TDataApi)
```
Extensões Built-in fundamentais para o Scaffolding:
- `.ToPascalCase()`, `.ToCamelCase()`, `.ToSnakeCase()`
- `.Pluralize()`, `.Singularize()`

---

## 3. Arquitetura Interna (`Dext.Templating.pas`)

### 3.1. Parsing e Árvore de Sintaxe Abstrata (AST)

A implementação do motor precisa varrer o template em um parser "Token-Lexer" e preencher uma AST simples, recusando a abordagem ingênua de mero *"String.Replace"*:
1. `TTextNode`: Texto fonte cru.
2. `TExpressionNode`: A injeção reativa (`@EntityName.ToPascalCase()`).
3. `TConditionalNode`: Bloco em memória avaliado lazily se a condição `@if` for Truthy.
4. `TLoopNode`: Bloco em memória repetido com base num iterável interno.

### 3.2. Sinergia de Alta Performance (Alinhado à S07)

Dado que a geração de arquivos pode lidar com varreduras longas:
- Acessos como `@Model.Field.Value` **NÃO usarão RTTI tradicional pesada por Reflection** em loop profundo se pudermos evitar.
- O motor `Dext.Templating.pas` consultará diretamente o `TTypeHandlerRegistry` idealizado na especificação S07 (High-Performance Reflection). Dele obteremos delegados cacheados `TFunc` ultravelozes.

### 3.3. Contratos de API (`ITemplateEngine`)

```delphi
type
  ITemplateEngine = interface
    ['{GUID}']
    // Registro de Mutators extendíveis (Ex: para plugins do dext.cli adicionarem .ToLower)
    function AddFilter(const AName: string; AFilter: TFunc<string, string>): ITemplateEngine;
    
    // Renders de runtime baseados no modelo objeto fortemente tipado
    function Render(const ATemplate: string; AModel: TObject): string;
    function RenderFile(const AFilePath: string; AModel: TObject): string;
  end;
```

### 3.4. Integração Agnóstica de Web Views (`IViewEngine`)

Conforme arquitetura existente (`Dext.Web.View.pas`), as views no Dext são resolvidas pela interface agnóstica `IViewEngine`. Atualmente, essa camada é provida por um plugin WebStencils. 

Para que o novo **Motor Nativo (Dext.Templating)** assuma o controle (ou sirva de alternativa plug&play robusta) em ambientes Web, ele **deverá implementar** nativamente uma ponte para a pipeline Web do Dext, traduzindo o dicionário `IViewData` para a árvore AST e resolvendo dinamicamente.

```delphi
  // Estrutura Conceitual da Integração
  TDextNativeViewEngine = class(TInterfacedObject, IViewEngine)
  public
    // Intercepta a chamada agnóstica de Controller (View(Nome, ViewData))
    function Render(AContext: IHttpContext; const AViewName: string; AViewData: IViewData): string;
  end;
```
Na injeção de dependência (`IServiceCollection`), deve ser possível trocar o fornecedor com facilidade (ex: `services.AddNativeViewEngine()` substituindo o `services.AddWebStencils()`).


---

## 4. Próxima Ação de Execução

Se esta especificação for aprovada como baseline estrutural (o "Modelo" base exigido):
1. Limparemos os resquícios Handlebars/DMustache no tooling atual voltando a visão para a AST Razor-like descrita acima.
2. Construiremos o core Lexer/Parser para identificar o token `@`.
