# 6. Database as API

Gere APIs REST automaticamente a partir das suas entidades - sem código necessário.

> 📦 **Exemplo**: [Web.DatabaseAsApi](../../../Examples/Web.DatabaseAsApi/)

## Início Rápido

```pascal
type
  [DataApi] // Auto-registra como /api/products
  [Table('products')]
  TProduct = class
  private
    FId: Integer;
    FName: string;
    FPrice: Double;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Price: Double read FPrice write FPrice;
  end;

// No pipeline de configuração (Global):
App.MapDataApis; 
```

### Formas de Registro

O Dext oferece flexibilidade total para expor seus dados, suportando três abordagens que podem coexistir:

1.  **Automática (Atributo)**: Basta adicionar `[DataApi]` na classe e chamar `App.MapDataApis` no startup.
2.  **Manual por tipo**: `TDataApiHandler<TProduct>.Map(App, '/api/products')`.
3.  **Manual Fluente**:
    ```pascal
    App.Builder.MapDataApi<TProduct>('/api/products', DataApiOptions
      .AllowRead
      .RequireAuth
    );
    ```

## Convenções e Mapeamento Inteligente

O Data API segue convenções modernas para minimizar a configuração:

-   **Nomenclatura**: Por padrão, o prefixo `T` é removido e o nome da classe é pluralizado (ex: `TCustomer` -> `/api/customers`).
-   **Rotas Customizadas**: Use `[DataApi('/meu/caminho')]` para sobrescrever a convenção.
-   **Case Mapping**: Propriedades em PascalCase no Delphi são automaticamente mapeadas para snake_case na URL (ex: `PriceValue` -> `?price_value_gt=100`).

## Endpoints Gerados

| Método | URL | Descrição |
|--------|-----|-----------|
| GET | `/api/products` | Listar todos (com paginação) |
| GET | `/api/products/{id}` | Buscar por ID |
| POST | `/api/products` | Criar novo |
| PUT | `/api/products/{id}` | Atualizar |
| DELETE | `/api/products/{id}` | Excluir |

## Recursos

- **Paginação Automática**: `?_limit=20&_offset=40`
- **Ordenação**: `?_orderby=price desc,name asc`
- **Filtros Dinâmicos (Dynamic Specification)**: Mapeamento inteligente via QueryString:

### Operadores de Filtro

| Sufixo | Operador SQL | Exemplo | Descrição |
|--------|--------------|---------|-----------|
| `_eq`  | `=`          | `?status_eq=1`         | Igual a (padrão)    |
| `_neq` | `<>`         | `?type_neq=2`          | Diferente de        |
| `_gt`  | `>`          | `?price_gt=50`         | Maior que           |
| `_gte` | `>=`         | `?age_gte=18`          | Maior ou igual      |
| `_lt`  | `<`          | `?stock_lt=5`          | Menor que           |
| `_lte` | `<=`         | `?date_lte=2025-01-01` | Menor ou igual      |
| `_cont`| `LIKE %x%`   | `?name_cont=Dext`      | Contém              |
| `_sw`  | `LIKE x%`    | `?code_sw=ABC`         | Começa com          |
| `_ew`  | `LIKE %x`    | `?mail_ew=gmail.com`   | Termina com         |
| `_in`  | `IN (...)`   | `?cat_in=1,2,5`        | Lista de valores    |
| `_null`| `IS NULL`    | `?addr_null=true`      | Verifica valor nulo |

## Performance: Streaming Zero-Allocation

Um diferencial chave do Data API do Dext é seu **motor JSON de alta performance**. Ao contrário das abordagens tradicionais que carregam todos os dados na memória e depois os serializam para strings, o Dext utiliza uma **abordagem de streaming**:

1.  **Streaming Direto**: Utiliza o `TUtf8JsonWriter` para escrever os dados diretamente no stream da resposta.
2.  **Integração Binária**: Lê os valores diretamente do driver de banco de dados e os escreve no tráfego sem alocações intermediárias de string para grandes conjuntos de dados.
3.  **Baixo Consumo de Memória**: Esta arquitetura permite servir grandes volumes de dados com impacto mínimo na memória, crucial para ambientes de alto tráfego.

---

## Políticas de Segurança

Você pode restringir acesso por operação ou por cargo (role):

```pascal
App.Builder.MapDataApi<TProduct>('/api/products', DataApiOptions
  .RequireAuth
  .RequireRole('Admin')
  .Allow([amGet, amGetList]) // Apenas leitura
);
```

## Diagnóstico e Observabilidade

Para facilitar a depuração de APIs geradas automaticamente, o Data API integra-se ao sistema de logging do Dext.

### Ativando Logs de Depuração

Se você encontrar comportamentos inesperados (como filtros que não funcionam ou erros de banco), você pode ativar o nível de log `Debug` no seu startup:

```pascal
App.Configure(procedure(App: IApplicationBuilder)
  begin
    // Define o nível mínimo como Debug para ver detalhes do DataAPI
    TDextServices.GetService<ILoggerFactory>(App.Services)
      .SetMinimumLevel(TLogLevel.Debug);
  end);
```

**O que será logado em modo Debug:**
- Entrada das requisições com os parâmetros brutos da QueryString.
- Mapeamento de propriedades e filtros aplicados.
- Exceções detalhadas com stack trace (se configurado).

---

[← ORM](../05-orm/README.md) | [Próximo: Tempo Real →](../07-tempo-real/README.md)
