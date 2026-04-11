# Soft Delete

Marque registros como excluídos sem removê-los fisicamente do banco de dados.

## Ativando o Soft Delete

Aplique o atributo `[SoftDelete]` à classe da sua entidade. Por padrão, ele utiliza uma flag Boolean onde `True` significa excluído.

```pascal
type
  [Table('tasks')]
  [SoftDelete('IsDeleted')] // Mapeia para a propriedade abaixo
  TTask = class
  private
    FIsDeleted: Boolean;
  public
    property IsDeleted: Boolean read FIsDeleted write FIsDeleted;
  end;
```

### Valores Customizados

Você também pode usar inteiros ou enums para os estados.

```pascal
[SoftDelete('Status', 99, 0)] // Excluído = 99, Ativo = 0
TUser = class
  property Status: Integer read FStatus write FStatus;
end;
```

## Operações

### Excluindo (Soft)

O método padrão `.Remove()` agora realizará um `UPDATE` em vez de um `DELETE`.

```pascal
Db.Tasks.Remove(Task);
Db.SaveChanges; 
// UPDATE tasks SET is_deleted = 1 WHERE id = ...
```

### Exclusão Física (Hard Delete)

Para ignorar a regra de soft delete e remover permanentemente um registro:

```pascal
Db.Tasks.HardDelete(Task);
// DELETE FROM tasks WHERE id = ...
```

### Restaurando (Undelete)

Para "desfazer" uma exclusão:

```pascal
Db.Tasks.Restore(Task);
// UPDATE tasks SET is_deleted = 0 WHERE id = ...
```

## Consultas (Querying)

Por padrão, registros ocultos com soft-delete são **escondidos** de todas as consultas.

```pascal
// Retorna apenas registros ativos
var Active := Db.Tasks.ToList;
```

### Incluindo Registros Excluídos

Para ver tudo (ex: em um painel administrativo):

```pascal
var All := Db.Tasks.IgnoreQueryFilters.ToList;
```

### Lixeira (Apenas Excluídos)

Para buscar apenas registros que foram excluídos:

```pascal
var Trash := Db.Tasks.OnlyDeleted.ToList;
```

## Notas Importantes

- **Cascateamento**: O Soft Delete **não** cascateia automaticamente para relacionamentos filhos. Você deve gerenciar as exclusões de dependentes manualmente ou via triggers no banco.
- **IdentityMap**: Entidades com soft-delete são removidas do cache de memória após o `SaveChanges` para manter um estado consistente.

---

[← Transações](transacoes.md) | [Próximo: Procedimentos Armazenados →](procedimentos-armazenados.md)
