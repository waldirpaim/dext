# OpenAPI / Swagger

OpenAPI (anteriormente Swagger) é o padrão da indústria para documentação de APIs REST. O Dext oferece suporte nativo para gerar especificações OpenAPI 3.0 e servir uma interface interativa (Swagger UI).

## Configuração Básica

Para habilitar o Swagger UI, chame `UseSwagger` no configurador da sua aplicação.

```pascal
var
  Options: TOpenAPIOptions;
begin
  Options := TOpenAPIOptions.Default;
  Options.Title := 'Minha API Dext';
  Options.Version := '1.0.0';

  App.UseSwagger(Options);
end;
```

Uma vez em execução, você pode acessar:
- **Swagger UI**: `http://localhost:8080/swagger`
- **OpenAPI JSON**: `http://localhost:8080/swagger.json`

## Documentando Endpoints

### 1. Minimal APIs (DSL Fluente)

Use `SwaggerEndpoint.From` para adicionar metadados às suas rotas:

```pascal
uses
  Dext.OpenAPI.Fluent;

SwaggerEndpoint.From(App.MapGet('/api/users', GetUsers))
  .Summary('Listar todos os usuários')
  .Description('Retorna uma lista completa de usuários do banco de dados')
  .Tag('Identidade')
  .Response(200, TypeInfo(TUserArray), 'Sucesso');
```

### 2. Controllers (Atributos)

Atributos permitem documentar sua API diretamente na classe do controller:

```pascal
[DextController('/api/products')]
[SwaggerTag('Catálogo')]
TProductsController = class
public
  [DextGet('{id}')]
  [SwaggerOperation('Obter Produto', 'Retorna detalhes de um único produto')]
  [SwaggerResponse(200, 'Produto encontrado')]
  [SwaggerResponse(404, 'Produto não encontrado')]
  function GetById(Id: Integer): IResult;
end;
```

## Documentação de Segurança

Documente seus requisitos de autenticação para que apareçam no Swagger com o botão "Authorize":

```pascal
Options.WithBearerAuth; // Adiciona suporte a JWT Bearer na especificação

// Em um endpoint específico:
SwaggerEndpoint.From(App.MapPost('/api/admin', ...))
  .RequireAuthorization;
```

## Recursos Avançados

- **Geração de Schema**: O Dext usa RTTI para gerar automaticamente esquemas JSON para seus tipos de Requisição e Resposta.
- **Caminhos Customizados**: Você pode alterar o caminho padrão `/swagger` nas opções.
- **Múltiplas Tags**: Agrupe endpoints para manter sua documentação organizada.

---

[← Middleware](middleware.md) | [Próximo: Rate Limiting →](rate-limiting.md)
