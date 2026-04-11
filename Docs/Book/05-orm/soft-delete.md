# Soft Delete

Mark records as deleted without physically removing them from the database.

## Enabling Soft Delete

Apply the `[SoftDelete]` attribute to your entity class. By default, it uses a Boolean flag where `True` means deleted.

```pascal
type
  [Table('tasks')]
  [SoftDelete('IsDeleted')] // Maps to the property below
  TTask = class
  private
    FIsDeleted: Boolean;
  public
    property IsDeleted: Boolean read FIsDeleted write FIsDeleted;
  end;
```

### Custom Values

You can also use integers or enums for states.

```pascal
[SoftDelete('Status', 99, 0)] // Deleted = 99, Active = 0
TUser = class
  property Status: Integer read FStatus write FStatus;
end;
```

## Operations

### Deleting

The standard `.Remove()` method will now perform an `UPDATE` instead of a `DELETE`.

```pascal
Db.Tasks.Remove(Task);
Db.SaveChanges; 
// UPDATE tasks SET is_deleted = 1 WHERE id = ...
```

### Physical Delete (Hard Delete)

To bypass the soft delete rule and permanently remove a record:

```pascal
Db.Tasks.HardDelete(Task);
// DELETE FROM tasks WHERE id = ...
```

### Restoring

To "undelete" a record:

```pascal
Db.Tasks.Restore(Task);
// UPDATE tasks SET is_deleted = 0 WHERE id = ...
```

## Querying

By default, soft-deleted records are **hidden** from all queries.

```pascal
// Returns only active records
var Active := Db.Tasks.ToList;
```

### Including Deleted Records

To see everything (e.g., in an admin panel):

```pascal
var All := Db.Tasks.IgnoreQueryFilters.ToList;
```

### Trash Bin (Only Deleted)

To fetch only records that were deleted:

```pascal
var Trash := Db.Tasks.OnlyDeleted.ToList;
```

## Important Notes

- **Cascading**: Soft Delete does **not** automatically cascade to child relationships. You must handle child deletions manually or via database triggers.
- **IdentityMap**: Soft-deleted entities are removed from the memory cache after `SaveChanges` to maintain a consistent state.

---

[← Transactions](transactions.md) | [Next: Stored Procedures →](stored-procedures.md)
