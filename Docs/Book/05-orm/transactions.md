# Transactions

Learn how to manage data integrity using implicit and explicit transactions in Dext.

## Implicit Transactions

Dext uses implicit transactions for every `SaveChanges` call. This ensures that all changes (Adds, Updates, Removals) tracked in the `DbContext` are either committed entirely or none at all (Atomicity).

```pascal
begin
  Db.Users.Add(User1);
  Db.Orders.Add(Order1);
  
  // Implicitly starts a transaction and commits at the end
  Db.SaveChanges; 
end;
```

## Explicit Transactions

For more complex business logic spanning multiple operations or external side effects, you can manage transactions manually.

```pascal
try
  Db.BeginTransaction;
  
  Db.Users.Add(User);
  Db.SaveChanges; // Part of the current explicit transaction
  
  // Logic here...
  
  Db.Commit;
except
  Db.Rollback;
  raise;
end;
```

### Checking Transaction Status

You can check if a transaction is already active:

```pascal
if not Db.InTransaction then
  Db.BeginTransaction;
```

## SavePoints

Dext does not currently support nested transactions natively via abstraction (it depends on the driver), but most modern drivers (PostgreSQL, SQL Server) support them via raw SQL commands if needed.

## Best Practices

1. **Keep Transactions Short**: Long-running transactions hold database locks and can cause deadlocks or performance degradation.
2. **Handle Exceptions**: Always use a `try..except` block when using manual transactions to ensure `Rollback` is called on failure.
3. **Use Scoped DI**: In Web applications, the `DbContext` is typically Scoped, meaning it exists for a single HTTP request. This is the ideal lifespan for a transaction unit.

---

[← Concurrency & Locking](locking.md) | [Next: Soft Delete →](soft-delete.md)
