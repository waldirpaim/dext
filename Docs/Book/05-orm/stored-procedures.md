# Stored Procedures

Map and execute database stored procedures and functions using decorative DTOs.

## Mappings

Dext allows mapping Stored Procedures using the `[Procedure]` attribute and defining parameters with `[DbParam]`.

```pascal
[Procedure('SP_CALCULATE_BONUS')]
TBonusDto = class
private
  FEmpId: Integer;
  FBaseAmount: Currency;
  FBonusValue: Currency; // Output Parameter
  FResult: Integer;      // Return/Result Parameter
public
  [DbParam(ptInput)]
  property EmpId: Integer read FEmpId write FEmpId;
  
  [DbParam(ptInput)]
  property BaseAmount: Currency read FBaseAmount write FBaseAmount;
  
  [DbParam(ptOutput)]
  property BonusValue: Currency read FBonusValue write FBonusValue;
  
  [DbParam(ptResult)]
  property Result: Integer read FResult write FResult;
end;
```

## Execution

Stored procedures are executed via the `DbContext`. Dext automatically handles the SQL syntax specific to each database (e.g., `EXEC` for SQL Server, `CALL` for MySQL/PostgreSQL, or anonymous blocks for Oracle).

```pascal
var Bonus := TBonusDto.Create;
try
  Bonus.EmpId := 10;
  Bonus.BaseAmount := 5000;
  
  // Executes and maps results back to the DTO properties
  Db.ExecuteProcedure(Bonus);
  
  WriteLn('Calculated Bonus: ', Bonus.BonusValue);
finally
  Bonus.Free;
end;
```

## Supported Parameter Types

| Type | Description |
|------|-------------|
| `ptInput` | Input value to the procedure. |
| `ptOutput` | Output value populated by the procedure. |
| `ptInputOutput` | Value passed in and updated by the procedure. |
| `ptResult` | The return value of a function or procedure. |

## Why use Stored Procedures with Dext?

1. **Type Safety**: No more manual parameter binding by index or name.
2. **Auto-Mapping**: Results from `ptOutput` and `ptResult` are automatically copied back to your DTO.
3. **Abstraction**: Your Pascal code doesn't need to know the specific SQL syntax required to call the procedure on different database engines.

---

[← Soft Delete](soft-delete.md) | [Next: Concurrency & Locking →](locking.md)
