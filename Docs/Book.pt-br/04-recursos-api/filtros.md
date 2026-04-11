# Filtros de Action (Action Filters)

Filtros de Action no Dext permitem executar código antes e depois da execução de uma action de controller, de forma declarativa usando atributos.

## Conceito

Action Filters são interceptadores que executam lógica em pontos específicos do pipeline de execução de uma action:

1. **OnActionExecuting**: Executa antes da action ser chamada.
2. **OnActionExecuted**: Executa depois da action (mesmo se houver uma exceção).

```pascal
[LogAction]  // ← Filtro executado automaticamente
[DextGet('/users')]
function GetUsers: IResult;
```

## Filtros Natas (Built-in)

O Dext já vem com vários filtros prontos para uso:

### 1. `[LogAction]`
Loga automaticamente o tempo de execução e o resultado da action no console/log.

### 2. `[RequireHeader]`
Valida se um header específico está presente na requisição.

```pascal
[RequireHeader('X-API-Key', 'API Key é obrigatória')]
[DextPost('/api/data')]
function PostData: IResult;
```

### 3. `[ResponseCache]`
Adiciona cabeçalhos de cache HTTP (Cache-Control) à resposta.

```pascal
[ResponseCache(60, 'public')]  // Cache por 60 segundos
```

## Criando Filtros Customizados

Para criar um filtro customizado, herde de `ActionFilterAttribute` e sobrescreva os métodos desejados.

```pascal
type
  RequireAdminAttribute = class(ActionFilterAttribute)
  public
    procedure OnActionExecuting(AContext: IActionExecutingContext); override;
  end;

procedure RequireAdminAttribute.OnActionExecuting(AContext: IActionExecutingContext);
begin
  if (AContext.HttpContext.User = nil) or 
     (not AContext.HttpContext.User.IsInRole('Admin')) then
  begin
    // Curto-circuito: definir AContext.Result impede a execução da action
    AContext.Result := Results.StatusCode(403, '{"error":"Acesso administrativo requerido"}');
  end;
end;
```

## Ordem de Execução

Quando múltiplos filtros são aplicados, eles executam na ordem em que foram declarados:

1. `FilterA.OnActionExecuting`
2. `FilterB.OnActionExecuting`
3. **Action executa**
4. `FilterB.OnActionExecuted` (ordem reversa)
5. `FilterA.OnActionExecuted`

### Filtros de Controller vs. Método

Filtros aplicados na classe do **Controller** executam antes dos filtros aplicados no **Método**.

```pascal
[LogAction] // 1º
TUserController = class
public
  [ResponseCache(60)] // 2º
  function GetUsers: IResult;
end;
```

## Curto-Circuito (Short-Circuit)

Você pode impedir que uma action execute definindo a propriedade `Result` em `OnActionExecuting`.

```pascal
procedure TMeuFiltro.OnActionExecuting(AContext: IActionExecutingContext);
begin
  if AlgumaFalha then
    AContext.Result := Results.BadRequest('Falhou');
end;
```

---

[← Middleware](middleware.md) | [Próximo: Rate Limiting →](rate-limiting.md)
