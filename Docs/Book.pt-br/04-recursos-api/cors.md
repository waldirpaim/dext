# CORS (Cross-Origin Resource Sharing)

Gerencie requisições de origens cruzadas de forma segura usando um configurador fluente.

## O que é CORS?

CORS é um mecanismo de segurança que permite que um servidor indique quais origens (domínios) têm permissão para acessar seus recursos. Por padrão, os navegadores bloqueiam requisições cross-origin por segurança.

## Uso Básico

### 1. Permissivo (Desenvolvimento)

Para permitir qualquer origem durante o desenvolvimento:

```pascal
App.UseCors(procedure(Builder: TCorsBuilder)
  begin
    Builder
      .AllowAnyOrigin
      .AllowAnyMethod
      .AllowAnyHeader;
  end);
```

### 2. Restritivo (Produção)

Para produção, sempre especifique seus domínios:

```pascal
App.UseCors(procedure(Builder: TCorsBuilder)
  begin
    Builder
      .WithOrigins(['https://meuapp.com', 'https://www.meuapp.com'])
      .WithMethods(['GET', 'POST', 'PUT', 'DELETE'])
      .WithHeaders(['Content-Type', 'Authorization'])
      .AllowCredentials
      .WithMaxAge(3600); // Cache da resposta preflight por 1 hora
  end);
```

## Opções de Configuração

| Método | Descrição |
|--------|-----------|
| `WithOrigins(['...'])` | Define domínios permitidos. |
| `AllowAnyOrigin` | Permite qualquer origem (*). |
| `WithMethods(['...'])` | Define verbos HTTP permitidos. |
| `AllowAnyMethod` | Permite qualquer verbo HTTP. |
| `WithHeaders(['...'])` | Define headers de requisição permitidos. |
| `AllowAnyHeader` | Permite qualquer header de requisição. |
| `WithExposedHeaders(['...'])` | Headers que o cliente tem permissão para ler. |
| `AllowCredentials` | Habilita compartilhamento de cookies/auth. |
| `WithMaxAge(segundos)` | Define quanto tempo resultados preflight são cacheados. |

## Notas Importantes de Segurança

1. **`AllowAnyOrigin` vs `AllowCredentials`**: A maioria dos navegadores rejeitará uma resposta se ela permitir *qualquer origem* e ao mesmo tempo permitir *credentials*. Você deve especificar origens explícitas se precisar de cookies/auth.
2. **Ordem Importa**: O middleware CORS deve ser um dos primeiros componentes no pipeline para capturar requisições `OPTIONS` (preflight) corretamente.

---

[← Rate Limiting](rate-limiting.md) | [Próximo: Cache de Resposta →](cache.md)
