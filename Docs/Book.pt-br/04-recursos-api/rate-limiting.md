# Rate Limiting

Proteja sua API contra abuso, ataques DDoS e scraping limitando o número de requisições por cliente.

## Uso Básico

### 1. Padrão (100 req/min)

```pascal
App.UseRateLimiting;
```

### 2. Configuração Personalizada

```pascal
App.UseRateLimiting(procedure(Options: TRateLimitBuilder)
  begin
    Options
      .WithPermitLimit(10)      // Máximo de 10 requisições
      .WithWindow(60)           // Por 60 segundos (1 minuto)
      .WithRejectionStatusCode(429);
  end);
```

## Como funciona

O Dext identifica os clientes pelo endereço de IP (suportando automaticamente `X-Forwarded-For` se estiver atrás de um proxy).

### Headers HTTP

O middleware adiciona headers padrão a todas as respostas para informar o cliente:

- `X-RateLimit-Limit`: O total de requisições permitidas na janela.
- `X-RateLimit-Remaining`: Quantas requisições ainda restam na janela atual.
- `Retry-After`: (Enviado apenas no erro 429) Segundos até que o cliente possa tentar novamente.

## Recursos

- **Thread-Safe**: Usa travas de alta performance para lidar com requisições concorrentes.
- **Auto-Cleanup**: Remove automaticamente dados expirados de clientes para economizar memória.
- **Zero-Config**: Padrões sensatos para início rápido.

## Melhores Práticas

1. **Autenticação**: Coloque o `UseRateLimiting` **antes** do `UseAuthentication` para evitar que usuários não autorizados consumam muitos recursos do servidor (ex: CPU para processar senhas).
2. **Limites Específicos**: Considere limites diferentes para partes diferentes da sua API.
   - Leitura pública: 200 req/min
   - Escrita/Criação: 50 req/min
   - Autenticação/Login: 5 req/min

## Exemplo: Rejeição Amigável

```pascal
Options.WithRejectionMessage(
  '{"error": "Muitas requisições", "message": "Por favor, tente novamente em 1 minuto"}'
);
```

---

[← Filtros de Action](filtros.md) | [Próximo: CORS →](cors.md)
