# S01 — Scaffolding Avançado: Análise e Plano de Implementação

## 1. Estado Atual: Tooling Existente

### 1.1 Ferramentas CLI Existentes (`Tools/`)

O Dext já possui um ecossistema de ferramentas no diretório `Tools/`:

| Ferramenta | Projeto | Executável | Responsabilidade |
|---|---|---|---|
| **Scaffolding CLI** | `Tools/Dext.Tool.Scaffolding/dext_gen.dpr` | `dext_gen.exe` | Escaneia `.pas` e gera `TEntityType` metadata |
| **Facade Generator** | `Tools/DextFacadeGenerator/DextFacadeGenerator.dpr` | `DextFacadeGenerator.exe` | Gera units "coringa" (Dext.pas, Dext.Entity.pas, Dext.Web.pas) |
| **API Doc Generator** | `Tools/DextDoc/` | Node.js | Parser de XMLDoc Delphi → HTML/Markdown |
| **Group Project** | `Tools/DextTools.groupproj` | — | Agrupa os projetos de tooling |

#### 1.1.1 CLI Atual: `dext_gen.exe`

**Arquivo**: `Tools/Dext.Tool.Scaffolding/Dext.Tool.Scaffolding.CLI.pas` (~313 linhas)

Arquitetura já bem definida:

- `IConsoleCommand` — Interface para comandos plugáveis
- `TDextScaffoldCLI` — Router com `TDictionary<string, IConsoleCommand>`, parsing de args, help automático
- `TScaffoldCommand` — Único comando implementado (`scaffold`)

**Comando disponível:**

```
dext-gen scaffold --source <path> [--out <path>]
```

Funcionalidade:

- Escaneia arquivos `.pas` procurando `T* = class`
- Gera units `.Meta.pas` com `TEntityType<T>` skeleton
- Parser simplificado (line-by-line, sem AST completo)
- Gera `class constructor` com TODOs para propriedades

**Limitações atuais:**

- Parser ingênuo (não lê atributos `[Table]`, `[PK]`, propriedades reais)
- Gera apenas skeleton — não preenche `TProp<T>` com metadados
- Não integra com `TFireDACSchemaProvider` / `TDelphiEntityGenerator` do framework
- Sem comandos `new` ou `add`

### 1.2 Gerador ORM Completo (`Sources/Data/`)

**Arquivo**: `Sources/Data/Dext.Entity.Scaffolding.pas` (~800 linhas)

Este é o gerador **robusto e completo** que reside no framework core:

| Componente | Responsabilidade |
|---|---|
| `ISchemaProvider` | Interface para extração de metadados do banco |
| `TFireDACSchemaProvider` | Implementação FireDAC (SQLite, PostgreSQL, SQL Server, etc.) |
| `IEntityGenerator` | Interface para geração de código Delphi |
| `TDelphiEntityGenerator` | Gera units completas com entidades, atributos e metadados |
| `TMetaColumn` / `TMetaTable` / `TMetaForeignKey` | Records de metadados do schema |

Capacidades (detalhadas):

- Classes de entidade com prefixo `T` + PascalCase
- Atributos ORM (`[PK]`, `[AutoInc]`, `[Required]`, `[MaxLength]`, `[Column]`, `[Precision]`, `[Table]`)
- Forward declarations para referências cruzadas
- Navigation properties com `ILazy<T>` para ForeignKeys
- Classes de metadados `TPropExpression` (para query expressions tipadas)
- **Dois estilos de mapeamento**: `msAttributes` e `msFluent`
- SQL → Delphi type mapping (INT, BIGINT, CHAR, TEXT, FLOAT, DECIMAL, UUID, etc.)
- Tratamento de nullables (`Nullable<T>` para campos nullable não-string)

### 1.3 O que Falta (Gap Analysis)

| Funcionalidade | `dext_gen` | `Dext.Entity.Scaffolding` | Status |
|---|---|---|---|
| Scaffolding Database-First | ❌ | ✅ Completo | **Não integrado na CLI** |
| Scaffolding Code-First (parse .pas) | ✅ Básico | ❌ | Funcional mas ingênuo |
| Comandos `dext new` | ❌ | N/A | **Não existe** |
| Comandos `dext add` | ❌ | N/A | **Não existe** |
| Templates de projeto | ❌ | N/A | **Não existe** |
| Geração de DbContext | ❌ | ❌ | **Não existe** |
| Geração de Controllers | ❌ | ❌ | **Não existe** |
| Geração de DataApi | ❌ | ❌ | **Não existe** |
| Geração de Testes | ❌ | ❌ | **Não existe** |
| Templates customizáveis | ❌ | ❌ | Hard-coded em ambos |

### 1.4 Módulos que se Beneficiariam

| Módulo | Template Desejado | Exemplo de Comando |
|---|---|---|
| **Web App** | Projeto Dext Web com pipeline completo | `dext new web MyApp` |
| **Console App** | App com DI e Hosted Services | `dext new console MyApp` |
| **Desktop App** | VCL/FMX com DI, ORM e Validation | `dext new desktop MyApp` |
| **Entity** | Classe de entidade com atributos | `dext add entity Customer` |
| **Controller** | Controller MVC com CRUD | `dext add controller Customers` |
| **DataApi** | DataApi handler para entidade | `dext add dataapi Customer` |
| **DbContext** | Contexto com DbSets registrados | `dext add context AppDb` |
| **Migration** | Migration vazia para customização | `dext add migration InitialCreate` |
| **Test Suite** | Projeto de testes com setup | `dext new tests MyApp.Tests` |

---

## 2. Proposta: Evolução da CLI `dext` com Motor de Templates

```
No doc C:\dev\Dext\DextRepository\Docs\Specs\S01-Advanced-Scaffolding.md
temos:
""""
### 2.2 Análise Técnica do Motor de Templates (`Dext.Templating.pas`)

O motor atual é uma implementação inspirada em Handlebars/Mustache, mas focada em relatórios. Para scaffolding, identificamos os seguintes pontos:
"""

O motor de templates deve ser inspirado no modelo do motor de templates padrão do .Net, esta foi especificamente minhas instruções.

Precisamos nos certificar que temos um plano definido de como será implementado o motor de templates, pois teremos níveis diferentes de necessidades de templates, antes de nos dedicar completamente a isso, temos de garantir um modelo e especificação a ser seguida.

Atue como project manager do dext, me ajude a planejar isso corretamente para não desviamos no caminho, para cobrir buraco em uma atividade intermediária que necessite de recursos de templates.
```

### 2.1 Estratégia: Evoluir, Não Recriar

A base já existe em `dext_gen.exe`. O plano é:

1. **Renomear** de `dext_gen` para `dext` (CLI unificada)
2. **Integrar** o `TFireDACSchemaProvider` + `TDelphiEntityGenerator` como novo comando `scaffold db`
3. **Adicionar** motor de templates externo para `new` e `add`
4. **Manter** a arquitetura `IConsoleCommand` plugável que já existe

### 2.2 Motor de Templates T4/Razor (`Dext.Templating.pas`)

Conforme a infraestrutura moderna detalhada oficialmente em **`S09-Template-Engine.md`**, o Dext abandona a abstração focada em relatórios (logic-less como Mustache) para adotar um Parser AST com sintaxe estruturada baseada no Razor (`@`), elevando a Developer Experience (DX).

Isso endereça especificamente os gaps:
1. **Controle Implícito**: Loops e condições que agora são processados nativamente pelo scaffolding sem sujar variáveis Delphi.
2. **Escaping**: O modo para scaffolding atua puramente como *Raw Output*.
3. **Sinergia S07**: Integração com Meta-Registry para evitar overhead the RTTI Tradicional nos `.GetProperty`.

### 2.3 Arquitetura (Evolução)

```
┌───────────────────────────────────────────────┐
│                  dext.exe                     │
│  (Console Application)                        │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │         TCommandRouter                  │  │
│  │  new <template> <name>                  │  │
│  │  add <component> <name> [--options]     │  │
│  │  scaffold <connection-string>           │  │
│  │  list templates                         │  │
│  └─────────────────────────────────────────┘  │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │        TTemplateEngine                  │  │
│  │  Lê templates .dext-template            │  │
│  │  Substitui variáveis {{EntityName}}     │  │
│  │  Gera arquivos .pas, .dpr, .dproj       │  │
│  └─────────────────────────────────────────┘  │
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │    ISchemaProvider (existente)          │  │
│  │    IEntityGenerator (existente)         │  │
│  │    + TContextGenerator (novo)           │  │
│  │    + TControllerGenerator (novo)        │  │
│  └─────────────────────────────────────────┘  │
└───────────────────────────────────────────────┘

Templates Directory:
  Templates/
  ├── projects/
  │   ├── web/          (Web App template)
  │   ├── console/      (Console App template)
  │   └── desktop/      (Desktop App template)
  ├── components/
  │   ├── entity.pas.template
  │   ├── controller.pas.template
  │   ├── dataapi.pas.template
  │   ├── context.pas.template
  │   └── test.pas.template
  └── shared/
      ├── dproj.template
      └── startup.pas.template
```

---

## 3. Plano de Implementação

### Fase 0: Templating Boost (Pré-requisito)

Antes de iniciar a CLI, o motor `Dext.Templating.pas` deve ser atualizado:

1. **Suporte a Partials:** Implementar a sintaxe `{{> NomeTemplate }}` permitindo que o `ITemplateLoader` resolva sub-templates.
2. **Case Filters Built-in:** Adicionar filtros nativos (`pascal`, `camel`, `snake`, `plural`, `singular`).
3. **Raw Mode por Default:** Criar uma flag no `ITemplateEngine` para desativar HTML encoding em templates de código.
4. **Otimização de Performance (Sinergia S07):** Migrar a resolução de propriedades (`ResolveObjectProperty`) para utilizar o `TTypeHandlerRegistry` (S07), eliminando o overhead de RTTI e `GetProperty` strings durante loops de geração maciça de código.

### Fase 1: Motor de Scaffolding (Fundação)

- `TTemplateEngine`: Atualizar com as melhorias da Fase 0.
- `TScaffoldingContext`: Um contexto especializado que pré-injeta variáveis globais (`{{Timestamp}}`, `{{DextVersion}}`).
- Variáveis padrão: `{{EntityName}}`, `{{TableName}}`, `{{ProjectName}}`, `{{UnitName}}`, `{{Timestamp}}`

**Fase 2: Evolução da CLI (`dext_gen` → `dext`)**

- Projeto console Delphi em `Tools/CLI/`
- Parsing de argumentos: `dext <command> <subcommand> [options]`
- Comandos: `new`, `add`, `scaffold`, `list`
- Integração com `TDelphiEntityGenerator` existente (comando `scaffold`)

**Fase 3: Templates de Projeto**

- Template Web App (`.dpr` + `Startup` + pipeline completo)
- Template Console App com DI
- Template Desktop App (VCL) com DI e ORM
- Cada template inclui `.dproj` com search paths corretos

**Fase 4: Templates de Componente**

- Entity template (com atributos ORM)
- Controller template (com rotas e DI)
- DbContext template (com DbSets)
- Test template (com TDextTest base)

### 2.3 Variáveis de Template

| Variável | Exemplo | Descrição |
|---|---|---|
| `{{ProjectName}}` | `MyWebApp` | Nome do projeto |
| `{{EntityName}}` | `Customer` | Nome da entidade (sem T) |
| `{{EntityClass}}` | `TCustomer` | Nome da classe (com T) |
| `{{TableName}}` | `customers` | Nome da tabela (snake_case) |
| `{{PluralName}}` | `Customers` | Nome pluralizado |
| `{{UnitName}}` | `MyWebApp.Entities.Customer` | Nome qualificado da unit |
| `{{Timestamp}}` | `2026-04-12` | Data de criação |
| `{{Year}}` | `2026` | Ano atual |
| `{{Author}}` | `Cesar Romero` | Autor (de config) |

---

## 3. Prompt para Agente Arquiteto — Fase 1 e 2

```
Tarefa: Implementar Scaffolding Avançado (S01) — Fase 1 e 2

Contexto:
O Dext Framework já possui uma CLI básica em Tools/Dext.Tool.Scaffolding/dext_gen.dpr
com arquitetura plugável via IConsoleCommand. Atualmente ela tem apenas o comando `scaffold`
que faz parsing ingênuo de .pas. O framework também possui um gerador completo
(TFireDACSchemaProvider + TDelphiEntityGenerator) em Sources/Data/Dext.Entity.Scaffolding.pas
que ainda não está integrado na CLI.

O documento de referência está em: Docs/Specs/S01-Advanced-Scaffolding.md

Fase 1: Motor de Templates
1. Verifique se Sources/Core/Base/Dext.Templating.pas existe e pode ser reutilizado
2. Crie a classe TTemplateEngine com:
   - LoadTemplate(FilePath): carrega arquivo .template
   - SetVariable(Name, Value): define variável de substituição
   - Process: retorna string com variáveis substituídas
   - SaveTo(OutputPath): salva resultado em arquivo
3. Suporte a variáveis no formato {{NomeVariavel}}
4. Suporte a blocos condicionais: {{#if HasPK}}...{{/if}}
5. Suporte a loops: {{#each Columns}}...{{/each}}
6. Testes unitários básicos para o motor

Fase 2: Evolução da CLI (dext_gen → dext)
1. EVOLUA o projeto existente em Tools/Dext.Tool.Scaffolding/
   - Renomeie dext_gen.dpr para dext.dpr
   - Mantenha a arquitetura IConsoleCommand existente em Dext.Tool.Scaffolding.CLI.pas
   - Renomeie TDextScaffoldCLI para TDextCLI (CLI unificada)
2. Adicione novos comandos como implementações de IConsoleCommand:
   - TScaffoldDbCommand: `dext scaffold db --connection "sqlite:///db.sqlite" --output ./Entities --style attributes`
     (Integra com TFireDACSchemaProvider + TDelphiEntityGenerator existentes)
   - TAddEntityCommand: `dext add entity <Name> [--table <TableName>]`
     (Gera entity a partir de template usando TTemplateEngine)
   - TListCommand: `dext list templates`
3. Mantenha o TScaffoldCommand existente como `dext scaffold code` (scaffolding code-first)
4. Crie templates iniciais em Templates/components/:
   - entity.pas.template (entidade com [PK], [AutoInc], [Table])
   - context.pas.template (DbContext com DbSet registration)

Regras:
- NÃO use prefixo L em variáveis locais
- Mensagens de commit em inglês, sem paths locais
- A CLI deve funcionar standalone (sem IDE)
- Use o logging existente do Dext (Dext.Logging)
```

---

## 4. Prompt para Agente Arquiteto — Fase 3 e 4

```
Tarefa: Implementar Scaffolding Avançado (S01) — Fase 3 e 4

Contexto:
As Fases 1 e 2 do S01 já foram implementadas (motor de templates e CLI básica com
comando scaffold e add entity). Esta tarefa adiciona templates de projeto completos
e templates de componentes avançados.

O documento de referência está em: Docs/Specs/S01-Advanced-Scaffolding.md

Fase 3: Templates de Projeto
1. Crie o comando: dext new web <ProjectName>
   Template deve gerar:
   - <ProjectName>.dpr com uses corretas (Dext.MM, Dext, Dext.Entity, Dext.Web, etc.)
   - <ProjectName>.dproj com search paths para DCUs do framework
   - Startup.Configure com pipeline padrão (UseLogging, UseSwagger, UseStaticFiles)
   - Um controller exemplo HelloController
   - Arquivo .gitignore padrão
2. Crie o comando: dext new console <ProjectName>
   Template deve gerar:
   - Projeto console com DI Container e Hosted Services
3. Use os exemplos existentes em Examples/ como referência para código gerado
4. Templates ficam em Templates/projects/web/, Templates/projects/console/

Fase 4: Templates de Componente Avançados
1. dext add controller <Name> [--entity <EntityName>]
   Gera controller MVC com ações CRUD ligadas à entidade
2. dext add dataapi <EntityName>
   Gera registro de DataApi para a entidade (usa MapDataApis)
3. dext add test <TestName> [--for <UnitName>]
   Gera suite de testes com TDextTest base

Validação:
- Execute: dext new web TestApp em um diretório temporário no workspace
- Verifique se o projeto gerado compila com /compile-delphi
- Execute: dext add entity Product --table products e verifique o .pas gerado
- Compile o CLI com /compile-delphi

Regras:
- NÃO use prefixo L em variáveis locais
- Mensagens de commit em inglês, sem paths locais
- Mantenha todos os comentários e docstrings existentes
```
