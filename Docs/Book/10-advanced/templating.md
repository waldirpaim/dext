# Template Engine (S09)

Dext includes a high-performance, AST-based template engine inspired by the .NET Razor and WebStencils ecosystems. It is used primarily for code scaffolding but can also be used for email templates, view rendering, and sophisticated code generation.

## Syntax

The engine uses the `@` symbol to denote expressions and control blocks.

### Expressions

Expressions resolve properties from the model provided in the context.

```razor
class @Model.DelphiClassName
```

Dot notation is supported for nested properties:
```razor
// Accessing a property of a property
@Model.Table.Name
```

### Control Blocks

#### If Conditions
Evaluates a boolean property or a string value (where "true", non-empty, and non-zero are true).

```razor
@if (IsPrimaryKey)
  [PK]
@endif
```

#### ForEach Loops
Iterates over any collection provided in the context (usually properties of the model).

```razor
@foreach (var col in Model.Columns)
  property @col.DelphiName: @col.DelphiType;
@endforeach
```

### Escaping and Literals

- **Double-At**: Use `@@` to render a literal `@` symbol.
- **Raw Output**: By default, the engine in HTML mode escapes content. Use `TExpressionNode(Node).FIsRaw := True` or specific filters for raw output. (In scaffolding mode, output is always raw).

## Filters (Mutators)

Filters are registered in the `ITemplateFilterRegistry` and applied using dot syntax.

| Filter | Description | Example |
|--------|-------------|---------|
| `ToPascalCase()` | Converts string to PascalCase | `@Name.ToPascalCase()` |
| `ToCamelCase()` | Converts string to camelCase | `@Name.ToCamelCase()` |

```razor
var @TableName.ToCamelCase()Record: T@TableName.ToPascalCase();
```

## Advanced Usage

### Context Management

Templates are rendered using an `ITemplateContext`, which can hold values, objects, and lists.

```pascal
var
  Context: ITemplateContext;
begin
  Context := TTemplating.CreateContext;
  Context.SetObject('Model', MyViewModel);
  Context.SetValue('Namespace', 'MyProject.Models');
  
  Writeln(Engine.Render(Template, Context));
end;
```

### Custom Templates

For CLI scaffolding, the engine resolves templates using a 3-level strategy. You can override any built-in template by creating a `Templates/` folder in your project root and adding a `.template` file (e.g., `entity.pas.template`).

---

[← Scaffolding](../09-cli/scaffolding.md) | [Top ↑](#)
