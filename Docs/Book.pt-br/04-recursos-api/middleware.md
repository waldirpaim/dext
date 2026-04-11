# Middleware

Middleware é um componente de código que lida com requisições e respostas. Ele se posiciona no "meio" (middle) do pipeline de execução.

## Conceito de Pipeline

O Dext usa um pipeline de componentes de middleware para processar requisições HTTP. Cada componente:
1. Recebe o `IHttpContext`.
2. Pode executar lógica antes de passar a requisição para o próximo componente.
3. Chama o delegate `Next` para continuar o pipeline.
4. Pode executar lógica após o restante do pipeline ter sido concluído (no retorno).

## Criando um Middleware

### 1. Middleware em Classe

Implemente a interface `IMiddleware`:

```pascal
uses
  Dext.Web.Interfaces;

type
  TMeuMiddleware = class(TInterfacedObject, IMiddleware)
  public
    procedure Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
  end;

procedure TMeuMiddleware.Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
begin
  // Lógica ANTES do restante do pipeline
  WriteLn('Iniciando requisição: ', AContext.Request.Path);

  // Chama o próximo middleware na cadeia
  ANext(AContext);

  // Lógica DEPOIS do restante do pipeline
  WriteLn('Finalizado com status: ', AContext.Response.StatusCode);
end;
```

### 2. Middleware Funcional

Você também pode usar procedimentos anônimos para lógicas simples:

```pascal
App.Use(procedure(Ctx: IHttpContext; Next: TRequestDelegate)
  begin
    Ctx.Response.AddHeader('X-Custom', 'Dext');
    Next(Ctx);
  end);
```

## Registrando Middlewares

No seu `Startup.Configure` ou diretamente no objeto `App`:

```pascal
// Baseado em classe
App.UseMiddleware(TMeuMiddleware);

// Funcional
App.Use(MeuMiddlewareFunc);
```

## Middlewares Built-in

O Dext vem com vários middlewares pré-configurados:

- `App.UseRouting`: Lida com o roteamento de endpoints.
- `App.UseStaticFiles`: Serve arquivos estáticos da pasta `wwwroot`.
- `App.UseAuthentication`: Popula a identidade do usuário (`User`).
- `App.UseCors`: Gerencia requisições de origens cruzadas.
- `App.UseSwagger`: Gera documentação OpenAPI.

## Curto-Circuito (Short-Circuiting)

Um middleware pode interromper o pipeline **NÃO** chamando `ANext(AContext)`. Isso é útil para verificações de segurança ou respostas imediatas.

```pascal
procedure TAuthMiddleware.Invoke(AContext: IHttpContext; ANext: TRequestDelegate);
begin
  if not IsAuthenticated(AContext) then
  begin
    AContext.Response.Status(401).Write('Não autorizado');
    Exit; // 🛑 O pipeline para aqui
  end;

  ANext(AContext); // ✅ Continua o pipeline
end;
```

---

[← OpenAPI / Swagger](openapi-swagger.md) | [Próximo: Filtros de Action →](filtros.md)
