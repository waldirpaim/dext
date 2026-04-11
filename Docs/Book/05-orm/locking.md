# Concurrency & Locking

Dext supports both Optimistic and Pessimistic locking strategies to ensure data integrity in multi-user environments.

## Optimistic Concurrency

Optimistic concurrency assumes that conflicts are rare. It uses a version column to detect if a record has been modified by another process since it was loaded.

### Usage

Add the `[Version]` attribute to an integer property in your entity:

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

When you call `SaveChanges`, Dext automatically checks if the `Version` in the database matches the one in memory. If it doesn't, an `EOptimisticConcurrencyException` is raised.

## Pessimistic Locking (DB-Level)

Pessimistic locking is used when conflicts are expected. It locks the record at the database level when it is read, preventing others from modifying it until your transaction is complete.

### Usage

Use the `.WithLock` method in your fluent query:

```pascal
uses
  Dext.Specifications.Interfaces; // For TLockMode

begin
  Db.BeginTransaction;
  try
    var Product := Db.Products
      .Where(u.Id = 1)
      .WithLock(lmExclusive) // SELECT ... FOR UPDATE or WITH (UPDLOCK)
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

### Lock Modes (`TLockMode`)

| Mode | SQL Equivalent | Description |
|------|----------------|-------------|
| `lmNone` | (None) | Default behavior (no lock). |
| `lmShared` | `FOR SHARE` / `HOLDLOCK` | Request a shared lock (allows others to read but not update). |
| `lmExclusive` | `FOR UPDATE` / `UPDLOCK` | Request an exclusive lock for updating. |
| `lmExclusiveNoWait` | `NOWAIT` | Exclusive lock, but fails immediately if already locked. |

## Offline Locking (Application-Level)

For long-running tasks where a database transaction cannot be kept open (e.g., a user editing an entity for several minutes), Dext provides an **Atomic Offline Locking** mechanism.

This requires specific attributes on your entity to store the lock metadata.

### Configuration

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

### Usage

The `TryLock` method performs an atomic `UPDATE` that only succeeds if the record is currently unlocked or the previous lock has expired.

```pascal
// Request a lock for 'AdminUser' for 30 minutes
if Db.Products.TryLock(Product, 'AdminUser', 30) then
begin
  // Successfully locked! 
  // The 'Product' instance is updated locally with the token and expiration.
end
else
begin
  WriteLn('Record is currently locked by another user.');
end;
```

To release the lock:

```pascal
Db.Products.Unlock(Product);
```

### Automatic Validation

The `TryLock` method uses a protected `WHERE` clause:  
`WHERE ID = :id AND (LockedBy IS NULL OR LockedUntil < :now)`

---

[← Stored Procedures](stored-procedures.md) | [Next: Transactions →](transactions.md)
