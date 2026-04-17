# S12 — Advanced Template Engine: Finalization & Feature Parity
>
> **Status:** Implementing - April 17, 2026  
> Spec criada a partir de solicitação de usuário + análise comparativa contra TemplatePro e WebStencils.
---

## 1. Contexto & Motivação

O Dext possui um motor de templates AST-based (`Dext.Templating`) funcional mas incompleto. Ele resolve o caso de uso de **scaffolding** (geração de código via CLI), mas para SSR de HTML e geração de emails ainda faltam funcionalidades críticas que os concorrentes já possuem.

### 1.1 Concorrentes Analisados

| Produto | Sintaxe | Herança | Macros | Filtros | TDataSet | Expressões |
|---|---|---|---|---|---|---|
| **TemplatePro** (Daniele Teti) | `{{:var}}` | ✅ Multi-level | ✅ | 30+ | ✅ | ✅ Aritméticas |
| **WebStencils** (Embarcadero) | `{% %}` / `{{ }}` | ✅ | ❌ | Básicos | ✅ | Limitadas |
| **Dext.Templating** (atual) | `@var` | ❌ | ❌ | 5 (scaffolding) | ❌ | ❌ |
| **ASP.NET Razor** (référence) | `@expr` | ✅ `@section` | `@RenderPartial` | N/A | N/A | ✅ C# |

### 1.2 Features Desejadas

- Herança de templates (layouts + blocos)
- Partials (includes reutilizáveis)
- Feature parity com .NET Razor

### 1.3 Estado Atual do Motor

Atualmente localizado em `Sources\Core\Base\Dext.Templating.pas`:

- [x] Parser AST com `@if`, `@foreach`, `@@` escape.
- [x] Child scope / `ITemplateContext` com parent lookup e suporte a objetos/listas.
- [x] Render de condicional com `@else`.
- [x] Render de loop com `@else` e pseudo-variaveis `@@index`, `@@first`, `@@last`, `@@odd`, `@@even`.
- [x] Resolução de expressões em `TExpressionNode.Render` com filtros encadeados.
- [x] Filtros de produção (string, numero/data, comparação), com parametros.
- [x] Layouts, herança e blocos: `@layout`, `@extends`, `@section`, `@block`, `@renderSection`, `@renderBody`, `@inherited`.
- [x] Partials e includes com contexto local: `@partial`, `@include`.
- [x] Partials inline/macros: `@define` e chamada `@>`.
- [x] Comentarios de template `@* *@`.
- [x] Bloco de saída literal `@raw ... @endraw`.
- [x] Expressoes aritmeticas `@(expr)` (operadores +, -, *, /, comparacoes e funcoes inline essenciais da Fase 4).
- [x] `@set`, `@continue`, `@break`, `@switch/@case` (Fase 4).
- [x] Whitespace control base com `~` em diretivas (Fase 5).
- [x] Cache de AST por conteúdo de template (Fase 5).
- [x] Loop em `TDataSet` (Fase 6).

## 2. Objetivo

Tornar o `Dext.Templating` o **melhor motor de templates para Delphi**:

1. **Completude de features** — paridade com Razor/.NET.
2. **Performance** — AST compilado, cache de parsed templates e Zero-allocation.
3. **Integração nativa** — RTTI (S07), Dext ORM Streaming, Smart Properties.
4. **Developer Experience** — mensagens de erro com linha/coluna, sintaxe Razor familiar.

---

## 3. Regras de Implementação & Performance

### 3.1 Reflection e Cache Inteligente

Para garantir a performance "Dext-level", a implementação deve seguir estas regras:

- **Metadata Registry**: Jamais use `TRttiContext.GetType` ou `TRttiType.GetProperty` diretamente no loop de renderização.
- **Handlers**: Utilize `TReflection.GetMetadata(Instance.ClassInfo).GetHandler(PropName)` para obter um `IPropertyHandler`. Este handler é cacheado internamente e muito mais rápido que chamadas RTTI puras.
- **TValue Unwrapping**: Use `TReflection.TryUnwrapProp` para lidar com `Prop<T>` e `Nullable<T>` de forma transparente.

### 3.2 Regra Zero-Allocation

O motor de templates deve ser amigável ao Garbage Collector (GC-free mindset):

- **StringBuilder Pooling**: Implementar pooling de `TStringBuilder` para evitar alocações constantes de objetos de string intermediários.
- **Reference Overheads**: Os nós do AST (`TTextNode`) devem, sempre que possível, armazenar referências ao template original ou buffers pré-alocados em vez de cópias de strings.
- **No Boxing**: Ao resolver valores primitivos (Integer, Double), tentar formatá-los diretamente para o buffer de saída sem passar por `string` intermediária se possível.

### 3.3 Reutilização de Código Existente

A implementação DEVE herdar e reutilizar os seguintes recursos do framework:

- **`Dext.Collections.Dict`**: Para o `ITemplateContext` e o registro de filtros (usar dicionários `IgnoreCase`).
- **`Dext.Core.Reflection.pas`**: Todo o acesso a dados de objetos deve passar por aqui.
- **`Dext.Core.Activator.pas`**: Usar para instanciar loaders de templates e filtros que possuam dependências.
- **`Dext.Json.pas`**: Para o filtro de output `.json()`, aproveitando o motor zero-allocation.
- **`Dext.Threading.Async.pas`**: Base para implementações futuras de `RenderAsync`.

### 3.4 Documentação de Progresso

- **Status Updates**: A cada etapa/sub-fase concluída, o executor DEVE atualizar a seção 1.3 (Estado Atual) trocando `❌` por `✅` e adicionar uma nota técnica no final do documento detalhando as decisões de design e mudanças significativas no código. Não basta dizer "Fase X concluída".

### 3.5 Garantia de Qualidade (Testes)

- **Unit Tests**: Todo novo recurso (nós AST, filtros, herança) deve vir acompanhado de testes unitários.
- **Projeto de Testes**: Os testes devem ser adicionados obrigatoriamente ao projeto existente em: `C:\dev\Dext\DextRepository\Tests\Templating\UnitTests\Dext.Templating.UnitTests.dpr`.

---

## 4. Prompt para Implementação (Agente Architect)
>
> [!IMPORTANT]
> Use o prompt abaixo ao delegar a tarefa para um sub-agente Software Architect especializado.
**Prompt Sugerido:**
"Implemente as fases 1, 2 e 3 da especificação S12 (Advanced Template Engine) localizada em `C:\dev\Dext\DextRepository\Docs\Specs\S12-Template-Engine-Advanced.md`.
**Siga rigorosamente as diretrizes em `C:\dev\Dext\DextRepository\Docs\DEVELOPMENT_GUIDELINES.md` e as regras abaixo:**

1. **Performance & Zero-Alloc**: Utilize `TReflection` com metadata handlers (S07) e pooling de `TStringBuilder`.
2. **Qualidade (Testes)**: Adicione testes unitários para cada funcionalidade no projeto `C:\dev\Dext\DextRepository\Tests\Templating\UnitTests\Dext.Templating.UnitTests.dpr`.
3. **Documentação de Progresso**: A cada sub-tarefa concluída, atualize a seção 1.3 da Spec (Estado Atual) e adicione um log técnico detalhado no final do documento sobre o que foi implementado.
4. **Clean Code**: Separe o `Parser` do `Renderer`.
5. **Error Handling**: Garanta reporte de erro com linha e coluna.
Consulte `Dext.Templating.pas` como base e preencha os stubs de `Render` existentes antes de evoluir para a Fase 3."

---

## 5. Recomendações Adicionais do Master Programmer (MP)

Para o sucesso absoluto desta implementação, as seguintes regras de ouro são obrigatórias:

1. **Streaming Support**: O método `Render` deve preferencialmente suportar um `TTextWriter` ou `TStream`. Renderizar para uma única string gigante causa picos de memória em templates muito grandes.
2. **Block Isolation**: O escopo de blocos (`@section`) deve ser isolado. Um bloco definido em um template filho não deve "sujar" o contexto global de outros renders em paralelo.
3. **Escaping Rigoroso**: O modo HTML (`IsHtmlMode`) deve ser agressivo. Todo output de expressão deve ser escapado por padrão, a menos que o filtro `.raw()` seja utilizado. Segurança contra XSS é inegociável.
4. **Loop Fallback**: O `@else` em loops é uma feature de UX crítica. Implementar de forma que a detecção de "coleção vazia" funcione para `TArray`, `IList<T>` e `TDataSet`.
5. **Lazy Loading**: O RTTI de filtros deve ser carregado sob demanda (lazy) se houverem centenas deles, mas para os 35+ básicos da spec, o registro estático no construtor do engine é aceitável desde que thread-safe.

---

## 6. Detalhamento Técnico por Fase

### Fase 1 — Completar o Core Existente (Blocker)
>
> **Prioridade: CRÍTICA** — sem isso o motor não funciona para HTML rendering.
>
#### 6.1 Implementar `TConditionalNode.Render`

O stub atual sempre retorna `''`. Deve:

- Chamar `EvaluateCondition(FCondition, AContext)`
- Renderizar `FTrueNodes` se `True`, `FFalseNodes` se `False`
- Suportar `@else` como separador das duas listas

```delphi
function TConditionalNode.Render(const AContext: ITemplateContext): string;
var
  SB: TStringBuilder;
  Node: TTemplateNode;
begin
  SB := TStringBuilder.Create;
  try
    if FEngine.EvaluateCondition(FCondition, AContext) then
    begin
      for Node in FTrueNodes do
        SB.Append(Node.Render(AContext));
    end
    else
    begin
      for Node in FFalseNodes do
        SB.Append(Node.Render(AContext));
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;
```

#### 6.2 Implementar `TLoopNode.Render`

O stub atual sempre retorna `''`. Deve:

- Resolver o `FListExpr` a partir do contexto (objetos, listas, TArray)
- Criar um `child scope` por iteração com `FItemName` → item atual
- Injetar pseudo-variáveis: `@@index` (1-based), `@@first`, `@@last`, `@@odd`, `@@even`
- Suportar `FElseNodes` para coleção vazia

```
@foreach (var item in Model.Products)
  @item.Name(@item.@@index)
@else
  Nenhum produto encontrado.
@endforeach
```

#### 6.3 Implementar `TExpressionNode.Render` via contexto

O stub atual só retorna `FExpression` — o valor literal da expressão, sem resolvê-la.
O Engine deve ser injetado no nó para que possa chamar `ResolveExpression`.
**Solução:** Tornar os nós AST cientes do engine via referência fraca ou mover a rendering logic para o engine
---

### Fase 2 — Filtros de Produção

Expandir o registry de filtros para cobrir casos de uso web e email.

#### 6.1 Filtros de String

| Filtro | Comportamento | Exemplo |
|---|---|---|
| `uppercase` | Tudo maiúsculo | `@Name.uppercase()` |
| `lowercase` | Tudo minúsculo | `@Name.lowercase()` |
| `capitalize` | Primeira letra maiúscula | `@Name.capitalize()` |
| `trim` | Remove espaços das bordas | `@Name.trim()` |
| `truncate(n)` | Limita a N caracteres + `...` | `@Bio.truncate(100)` |
| `truncate(n, suffix)` | Idem com sufixo customizado | `@Bio.truncate(50, '…')` |
| `lpad(n, char)` | Padding esquerdo | `@Id.lpad(5, '0')` |
| `rpad(n, char)` | Padding direito | `@Code.rpad(10)` |
| `replace(from, to)` | Substituição | `@Text.replace(' ', '_')` |
| `default(val)` | Valor fallback se vazio | `@Name.default('N/A')` |
| `htmlencode` | Escape HTML (& < > " ') | `@UserInput.htmlencode()` |
| `urlencode` | URL encoding | `@Query.urlencode()` |
| `json` | Serializa para JSON | `@Object.json()` |
| `raw` | Output sem encoding | `@HtmlContent.raw()` |

#### 6.2 Filtros de Data/Número

| Filtro | Comportamento | Exemplo |
|---|---|---|
| `datetostr(fmt)` | Formata TDateTime | `@CreatedAt.datetostr('dd/mm/yyyy')` |
| `datetimetostr(fmt)` | Idem com hora | `@UpdatedAt.datetimetostr()` |
| `formatfloat(fmt)` | Formata Double | `@Price.formatfloat('0.00')` |
| `formatint` | Formata Integer | `@Count.formatint` |
| `round(n)` | Arredonda | `@Value.round(2)` |

#### 6.3 Filtros de Comparação (para uso em `@if`)

| Filtro | Comportamento |
|---|---|
| `eq(val)` | Igualdade |
| `ne(val)` | Desigualdade |
| `gt(val)` | Maior que |
| `ge(val)` | Maior ou igual |
| `lt(val)` | Menor que |
| `le(val)` | Menor ou igual |
| `contains(s)` | Contém substring |
| `startswith(s)` | Começa com |
| `endswith(s)` | Termina com |

```
@if (Status.eq('active'))
  <span class="badge green">Ativo</span>
@else
  <span class="badge red">Inativo</span>
@endif
```

#### 6.4 Filtros Encadeados

A sintaxe de filtros deve permitir encadeamento com `.`:

```
@Product.Name.trim().truncate(50).htmlencode()
```

Internamente representado como: `resolve(expr) → filter1 → filter2 → filter3`.

#### 6.5 Filtros com Parâmetros

Suporte a parâmetros nas chamadas de filtro:

```
@Price.formatfloat('R$ #,##0.00')
@Date.datetostr('yyyy-mm-dd')
@Text.truncate(100, '…')
```

---

### Fase 3 — Herança de Templates e Partials

Este é o requisito central do usuário e o principal diferencial vs WebStencils.

#### 6.1 `@layout` — Definir Layout Base

Um template filho declara o layout que deve envolvê-lo:
**`views/products/index.html`:**

```html
@layout('_Layout')
@section('title')
  Produtos
@endsection
@section('content')
<h1>Lista de Produtos</h1>
@foreach (var item in Products)
  <div>@item.Name — @item.Price.formatfloat('0.00')</div>
@endforeach
@endsection
```

**`views/shared/_Layout.html`:**

```html
<!DOCTYPE html>
<html>
<head>
  <title>@renderSection('title') — Meu App</title>
</head>
<body>
  @renderSection('content')
</body>
</html>
```

#### 6.2 `@section` / `@renderSection` — Blocos Nomeados

- `@section('name') ... @endsection` — Define um bloco no filho
- `@renderSection('name')` — Renderiza o bloco no layout
- `@renderSection('name', required: false)` — Bloco opcional
- `@renderBody` — Renderiza todo o conteúdo do filho (layout) — equivalente ao Razor

#### 6.3 `@extends` — Herança Multi-Nível

Suporte a herança profunda (layout filho que herda de layout pai):

```html
@extends('_AdminLayout')
@block('sidebar')
  <!-- admin sidebar específico -->
@endblock
```

Com `@inherited` para incluir o conteúdo do bloco pai:

```html
@block('scripts')
  @inherited
  <script src="admin.js"></script>
@endblock
```

#### 6.4 `@partial` / `@include` — Partials Reutilizáveis

Inclui outro template como fragmento, com passagem de contexto local:

```html
@partial('components/_ProductCard', product: item)
```

**`views/components/_ProductCard.html`:**

```html
<div class="card">
  <h3>@product.Name</h3>
  <p>@product.Price.formatfloat('R$ 0.00')</p>
</div>
```

Suporte a inline partials (definição e uso no mesmo arquivo):

```html
@define('badge', status)
  <span class="badge @status">@status</span>
@enddefine
@> badge('active')
@> badge('inactive')
```

#### 6.5 Resolução de Nomes de Arquivo

O `ITemplateLoader` resolve templates por nome usando:

1. Caminhos relativos ao template atual
2. Caminhos relativos ao `TemplateRoot` configurado
3. Prefixos de busca (`shared/`, `components/`, `layouts/`)

---

### Fase 4 — Controle de Fluxo Avançado

#### 6.1 `@set` — Variáveis Locais

```
@set total = 0
@foreach (var item in Items)
  @set total = @total + @item.Price
@endforeach
Total: @total.formatfloat('0.00')
```

#### 6.2 `@continue` e `@break` em Loops

```
@foreach (var item in Items)
  @if (item.Hidden)
    @continue
  @endif
  <p>@item.Name</p>
@endforeach
```

#### 6.3 `@switch` / `@case`

```
@switch (Status)
  @case ('active')
    <span class="green">Ativo</span>
  @case ('suspended')
    <span class="red">Suspenso</span>
  @default
    <span>Desconhecido</span>
@endswitch
```

#### 6.4 Expressões Aritméticas `@(expr)`

Suporte a expressões matemáticas e de string inline:

```
@(Price * Quantity)
@(FirstName + ' ' + LastName)
@(Items.Count > 0)
```

Funções built-in: `length()`, `upper()`, `lower()`, `trim()`, `sqrt()`, `abs()`, `round()`, `min()`, `max()`, `left()`, `right()`.

#### 6.5 `@comment` — Comentários

Comentários que não aparecem no output:

```
@* Este trecho é um comentário e não será renderizado *@
```

---

### Fase 5 — Features de Produção

#### 6.1 Whitespace Control

Operadores `~` para remover whitespace antes/após tags:

```
@~if (IsFirst)
  , 
@endif~
```

Equivalente ao TemplatePro `{{-` / `-}}`.

#### 6.2 String Literals em Templates

Suporte a literais de string dentro de expressões:

```
@('Olá, ' + UserName + '!')
```

#### 6.3 `@raw` — Bloco de Saída Literal

```
@raw
  Este conteúdo tem @símbolos@ que não devem ser processados.
@endraw
```

#### 6.4 Templates Compilados / Cache

Compilar o AST uma vez e cachear por template name + hash do conteúdo:

```pascal
var Template := Engine.Compile(Content);  // retorna ICompiledTemplate
var Output := Template.Render(Context);   // reutilizável
```

Arquitetura:

- `ICompiledTemplate` — AST serializado/cached
- `ITemplateCompiler` — separa parse de render
- Cache LRU por `TemplateRoot` configurado

#### 6.5 Mensagens de Erro com Contexto

Em vez de exception genérica, erros devem incluir:

- Nome do arquivo
- Número de linha e coluna
- Trecho do template com o problema destacado

```
[Dext.Template] Parse error in 'views/products/index.html' at line 12, col 5:
  @if (Status.eq('active')
               ^
  Unterminated function call: missing closing parenthesis
```

#### 6.6 Modo HTML vs Modo Raw

- **HTML Mode** (default para views): auto-escapa output de `@expr` com `htmlencode`
- **Raw Mode** (default para scaffolding): output literal sem encoding
- Controle explícito: `@raw(expr)` em modo HTML, `@encoded(expr)` em modo raw

---

### Fase 6 — Integrações Nativas Dext

#### 6.1 TDataSet como Fonte de Loop

```
@foreach (var row in Customers)
  <tr>
    <td>@row.Id</td>
    <td>@row.Name</td>
    <td>@row.Email</td>
  </tr>
@endforeach
```

O `TLoopNode.Render` detecta se a fonte é um `TDataSet` e itera com `First`/`Next`/`Eof` em vez de índice de array.

#### 6.2 Streaming ORM (Flyweight Iterator)

Continuar o suporte existente de `TStreamingViewIterator<T>`:

- Integração com `IDbQuery<T>` sem materialização em TArray
- O loop itera "on demand" consumindo O(1) memória

#### 6.3 Smart Properties `Prop<T>`

Manter o wrapper `@(Prop(item.Name))` e adicionar suporte automático no RTTI: se a propriedade for `Prop<T>`, extrair o `.Value` automaticamente sem wrapper explícito.

#### 6.4 HTMX Auto-Detection

Detectar header `HX-Request` e suprimir o layout automaticamente:

```pascal
// No Results.View:
if Request.Headers.ContainsKey('HX-Request') then
  ViewOptions.Layout := '';  // retorna partial apenas
```

---

## 7. Comparativo Final: Dext vs Concorrentes (Pós-S12)

| Feature | TemplatePro | WebStencils | **Dext (S12)** |
|---|---|---|---|
| Sintaxe | `{{:var}}` (Jinja) | `{% %}` | `@var` (Razor) |
| Herança multi-nível | ✅ | ✅ | ✅ |
| Partials com contexto local | ❌ | ❌ | ✅ |
| Macros | ✅ | ❌ | ✅ (`@define`) |
| Filtros encadeados com params | ✅ 30+ | Básicos | ✅ 35+ |
| Expressões aritméticas | ✅ | ❌ | ✅ |
| `@set` / variáveis locais | ✅ | ❌ | ✅ |
| `@switch` / `@case` | ❌ | ❌ | ✅ |
| `@continue` / `@break` | ✅ | ❌ | ✅ |
| Whitespace control | ✅ | ❌ | ✅ |
| Comentários | ✅ | ❌ | ✅ |
| Templates compilados + cache | ✅ | ✅ (parcial) | ✅ |
| TDataSet support | ✅ | ✅ | ✅ |
| ORM Streaming O(1) | ❌ | ❌ | ✅ (exclusivo) |
| Pseudo-vars de loop | ✅ | Limitado | ✅ |
| Erros com linha/coluna | ❌ | ❌ | ✅ |
| HTMX auto-detection | ❌ | ❌ | ✅ (exclusivo) |
| Zero dependência externa | ❌ (JsonDataObjects) | ❌ (RAD Studio) | ✅ |
| Integração DI nativa | ❌ | ❌ | ✅ |

---

## 8. Plano de Implementação (Fases Sugeridas)

| Fase | Esforço | Prioridade | Bloqueio |
|---|---|---|---|
| **F1: Core (Render stubs)** | 1 dia | 🔴 Crítico | Nada funciona sem isso |
| **F2: Filtros de Produção** | 2 dias | 🔴 Alta | Necessário para HTML |
| **F3: Herança & Partials** | 3-4 dias | 🔴 Alta | User request direto |
| **F4: Fluxo Avançado** | 2 dias | 🟡 Média | Features avançadas |
| **F5: Features Produção** | 3 dias | 🟡 Média | Cache + error reporting |
| **F6: Integrações Dext** | 1-2 dias | 🟢 Baixa | Já existe parcialmente |
**Total estimado:** ~2 semanas de implementação focada.

---

## 9. Decisões Arquiteturais

### 9.1 Manter Sintaxe `@` (Razor)

O Dext já usa `@` no scaffolding e na documentação. Mudar para `{{}}` quebraria código existente e confundiria usuários. A decisão é **manter `@` como delimitador primário**, adicionando `@(expr)` para expressões complexas.

### 9.2 Separar Compiler de Engine

Introduzir a interface `ITemplateCompiler`:

```pascal
ITemplateCompiler = interface
  function Compile(const ATemplate: string): ICompiledTemplate;
  function CompileFile(const ATemplateName: string): ICompiledTemplate;
end;
ICompiledTemplate = interface
  function Render(const AContext: ITemplateContext): string;
end;
```

O `TDextTemplateEngine` atual se torna o compiler. Um `TCompiledTemplate` cacheia o AST.

### 9.3 Loader Strategy Pattern

```pascal
ITemplateLoader = interface
  function Load(const AName: string): string;
  function Exists(const AName: string): Boolean;
end;
```

Implementações: `TFileSystemLoader`, `TInMemoryLoader`, `TCompositeLoader` para resolver caminhos de templates.

### 9.4 Resolver via RTTI com Cache

Uso mandatório do `TTypeMetadata` (S07) para cachear handlers de propriedades.
As lookups de propriedades RTTI custam caro. Usar o `TTypeMetadata` do S07 para cachear handlers:

```pascal
// Usar TReflection.GetHandler em vez de TypeRtti.GetProperty a cada render
Handler := TReflection.GetMetadata(Obj.ClassInfo).GetHandler(PropName);
Result := Handler.GetStringValue(Obj);
```

---

## 10. Exemplos de Templates Completos

### 10.1 Página HTML com Layout e Partials

**`_Layout.html`:**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>@renderSection('title') | Dext App</title>
  @renderSection('styles', required: false)
</head>
<body>
  <nav>@partial('shared/_Navbar')</nav>
  <main>
    @renderBody
  </main>
  <footer>@partial('shared/_Footer')</footer>
  @renderSection('scripts', required: false)
</body>
</html>
```

**`pages/customers.html`:**

```html
@layout('shared/_Layout')
@section('title')Clientes@endsection
@section('content')
<div class="container">
  <h1>Clientes (@Customers.Count.formatint)</h1>
  
  @if (Customers.Count.eq(0))
    <p class="empty">Nenhum cliente cadastrado.</p>
  @else
    <table class="table">
      @foreach (var customer in Customers)
        <tr class="@if (customer.@@odd)odd@else even@endif">
          <td>@customer.@@index</td>
          <td>@customer.Name.htmlencode()</td>
          <td>@customer.Email.default('—')</td>
          <td>@customer.CreatedAt.datetostr('dd/mm/yyyy')</td>
        </tr>
      @endforeach
    </table>
  @endif
</div>
@endsection
```

### 10.2 Template Email

```html
@* Template de email de boas-vindas *@
<!DOCTYPE html>
<html>
<body>
  <h1>Olá, @UserName.capitalize()!</h1>
  <p>Bem-vindo ao @AppName.</p>
  
  @if (HasTrialPeriod)
    <p>Seu período de trial termina em <strong>@TrialExpiry.datetostr('dd/mm/yyyy')</strong>.</p>
  @endif
  
  <ul>
  @foreach (var feature in Features)
    <li>@feature.Name — @feature.Description.truncate(80, '…')</li>
  @endforeach
  </ul>
</body>
</html>
```

## 11. Technical Log - April 17, 2026

### 11.1 Engine Runtime

- O unit `Sources\Core\Base\Dext.Templating.pas` foi expandido para cobrir as Fases 1, 2 e 3 da S12 sem quebrar a API base de `ITemplateEngine.Render`.
- `ITemplateEngine` agora expoe `RenderTemplate` e `TemplateLoader`, permitindo renderização por nome com layouts, partials e herança.
- Foram adicionados loaders nativos para filesystem (`TFileSystemTemplateLoader`) e memoria (`TInMemoryTemplateLoader`).

### 11.2 AST e Renderizacao

- Os stubs de `TConditionalNode.Render`, `TLoopNode.Render` e `TExpressionNode.Render` foram preenchidos.
- O parser AST agora reconhece `@else`, `@partial`, `@include`, `@renderSection`, `@renderBody`, `@raw(expr)`, `@* *@` e macros `@>`.
- Loops agora criam child scope por item e injetam `@@index`, `@@first`, `@@last`, `@@odd` e `@@even`.

### 11.3 Filtros

- O registro antigo de filtros string-only foi mantido por compatibilidade.
- Foi adicionada uma camada de filtros baseada em `TValue`, com suporte a parametros e retorno boolean/string/number.
- Entraram filtros de string, numero/data e comparação (`uppercase`, `trim`, `truncate`, `default`, `htmlencode`, `urlencode`, `json`, `datetostr`, `formatfloat`, `eq`, `contains`, `startswith`, `endswith`, etc.).

### 11.4 Layouts, Sections e Partials

- O motor agora extrai diretivas de documento (`@layout`, `@extends`, `@section`, `@block`, `@define`) antes da renderização AST.
- `@extends` e `@block` foram tratados como aliases de herança/blocos para cadeia multi-nivel.
- `@inherited` faz merge textual do bloco filho com o conteudo herdado antes da renderização final.
- `@partial` / `@include` suportam passagem de contexto nomeado, e `@define` / `@>` cobrem partials inline/macros.

### 11.5 Testes

- A suite `Tests\Templating\UnitTests\Dext.Templating.Tests.pas` foi expandida para cobrir:
  - `if/else`
  - `foreach` com fallback e pseudo-variaveis
  - filtros parametrizados
  - filtros de comparação em condições
  - renderização com layout + sections + partial
  - macros inline com `@define` e `@>`
- A compilacao/executar testes completos fica para a proxima sessao dedicada, conforme solicitado.

### 11.6 Fase 4 - Fluxo avancado

- Implementado `@set` para variaveis locais por escopo, com avaliacao de expressao no lado direito.
- Implementado controle de loop com `@continue` e `@break`.
- Implementado `@switch`, `@case`, `@default`, `@endswitch`.
- Adicionado avaliador de expressoes inline para `@(expr)` com operadores aritmeticos/comparativos e funcoes utilitarias (`length`, `upper`, `lower`, `trim`, `sqrt`, `abs`, `round`, `min`, `max`, `left`, `right`).
- Suite de testes ampliada para cobrir `@set`, expressoes inline, `@continue/@break` e `@switch/@case`.

### 11.7 Fase 5 - Producao (parcial)

- Implementado bloco literal `@raw ... @endraw` (conteudo interno nao e processado).
- Implementado controle de whitespace com `~` em diretivas (`@~if`, `@endif~`, etc.), incluindo trim de espacos e quebra de linha.
- Implementado cache de AST em memoria por conteúdo de template para evitar parse repetido em renders subsequentes.
- Suite de testes ampliada para cobrir `@raw` em bloco e whitespace control com `~`.

---
*Last update: April 17, 2026*
