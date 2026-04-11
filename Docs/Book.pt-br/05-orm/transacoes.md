# Transações

Saiba como gerenciar a integridade dos dados usando transações implícitas e explícitas no Dext.

## Transações Implícitas

O Dext utiliza transações implícitas para cada chamada de `SaveChanges`. Isso garante que todas as alterações (Adições, Atualizações, Remoções) rastreadas no `DbContext` sejam confirmadas inteiramente ou nenhuma delas (Atomicidade).

```pascal
begin
  Db.Users.Add(User1);
  Db.Orders.Add(Order1);
  
  // Inicia implicitamente uma transação e faz o commit ao final
  Db.SaveChanges; 
end;
```

## Transações Explícitas

Para lógicas de negócio mais complexas que abrangem múltiplas operações ou efeitos colaterais externos, você pode gerenciar transações manualmente.

```pascal
try
  Db.BeginTransaction;
  
  Db.Users.Add(User);
  Db.SaveChanges; // Faz parte da transação explícita atual
  
  // Lógica de negócio aqui...
  
  Db.Commit;
except
  Db.Rollback;
  raise;
end;
```

### Verificando o Status da Transação

Você pode verificar se uma transação já está ativa:

```pascal
if not Db.InTransaction then
  Db.BeginTransaction;
```

## Boas Práticas

1. **Mantenha as Transações Curtas**: Transações longas mantêm bloqueios no banco de dados e podem causar deadlocks ou degradação de performance.
2. **Trate Exceções**: Sempre use um bloco `try..except` ao usar transações manuais para garantir que o `Rollback` seja chamado em caso de falha.
3. **Use DI com Escopo (Scoped)**: Em aplicações Web, o `DbContext` é tipicamente Scoped, o que significa que ele existe por uma única requisição HTTP. Este é o tempo de vida ideal para uma unidade de transação.

---

[← Travamento e Concorrência](travamento-concorrencia.md) | [Próximo: Soft Delete →](soft-delete.md)
