# Concorrência e Travamento

O Dext suporta estratégias de travamento Otimista e Pessimista para garantir a integridade dos dados em ambientes multiusuário.

## Concorrência Otimista

A concorrência otimista assume que conflitos são raros. Ela usa uma coluna de versão para detectar se um registro foi modificado por outro processo desde que foi carregado.

### Uso

Adicione o atributo `[Version]` a uma propriedade inteira na sua entidade:

```pascal
type
  [Table('products')]
  TProduct = class
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    
    [Version]
    property Version: Integer read FVersion write FVersion;
  end;
```

Quando você chama `SaveChanges`, o Dext verifica automaticamente se a `Version` no banco de dados corresponde àquela na memória. Se não corresponder, uma exceção `EOptimisticConcurrencyException` é lançada.

## Travamento Pessimista (Nível de Banco)

O travamento pessimista é usado quando conflitos são esperados. Ele trava o registro no nível do banco de dados quando ele é lido, impedindo que outros o modifiquem até que sua transação seja concluída.

### Uso

Use o método `.WithLock` na sua consulta fluente:

```pascal
uses
  Dext.Specifications.Interfaces; // Para TLockMode

begin
  Db.BeginTransaction;
  try
    var Product := Db.Products
      .Where(u.Id = 1)
      .WithLock(lmExclusive) // SELECT ... FOR UPDATE ou WITH (UPDLOCK)
      .FirstOrDefault;

    Product.Price := Product.Price * 1.1;
    Db.SaveChanges;
    Db.Commit;
  except
    Db.Rollback;
    raise;
  end;
end;
```

### Modos de Travamento (`TLockMode`)

| Modo | Equivalente SQL | Descrição |
|------|-----------------|-----------|
| `lmNone` | (Nenhum) | Comportamento padrão (sem trava). |
| `lmShared` | `FOR SHARE` / `HOLDLOCK` | Solicita uma trava compartilhada (permite leitura por outros, mas não alteração). |
| `lmExclusive` | `FOR UPDATE` / `UPDLOCK` | Solicita uma trava exclusiva para atualização. |
| `lmExclusiveNoWait` | `NOWAIT` | Trava exclusiva, mas falha imediatamente se o registro já estiver travado. |

## Travamento Offline (Nível de Aplicação)

Para tarefas de longa duração onde uma transação de banco de dados não pode ser mantida aberta (ex: um usuário editando uma entidade por vários minutos), o Dext fornece um mecanismo de **Travamento Offline Atômico**.

Isso requer atributos específicos na sua entidade para armazenar os metadados da trava.

### Configuração

```pascal
type
  TProduct = class
  public
    [PK]
    property Id: Integer ...

    [LockToken]
    property LockedBy: string ...

    [LockExpiration]
    property LockedUntil: TDateTime ...
  end;
```

### Uso

O método `TryLock` realiza um `UPDATE` atômico que só tem sucesso se o registro estiver atualmente destravado ou se a trava anterior já tiver expirado.

```pascal
// Solicita um lock para o usuário 'AdminUser' por 30 minutos
if Db.Products.TryLock(Product, 'AdminUser', 30) then
begin
  // Travado com sucesso! 
  // A instância 'Product' é atualizada localmente com o token e expiração.
end
else
begin
  WriteLn('O registro está sendo editado por outro usuário.');
end;
```

Para liberar a trava:

```pascal
Db.Products.Unlock(Product);
```

---

[← Procedimentos Armazenados](procedimentos-armazenados.md) | [Próximo: Transações →](transacoes.md)
