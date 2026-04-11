# Procedimentos Armazenados

Mapeie e execute stored procedures e funções do banco de dados usando DTOs decorativos.

## Mapeamento

O Dext permite mapear Stored Procedures usando o atributo `[Procedure]` e definindo os parâmetros com `[DbParam]`.

```pascal
[Procedure('SP_CALCULATE_BONUS')]
TBonusDto = class
private
  FEmpId: Integer;
  FBaseAmount: Currency;
  FBonusValue: Currency; // Parâmetro de Saída
  FResult: Integer;      // Parâmetro de Retorno/Resultado
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

## Execução

Os procedimentos armazenados são executados via `DbContext`. O Dext trata automaticamente a sintaxe SQL específica de cada banco (ex: `EXEC` para SQL Server, `CALL` para MySQL/PostgreSQL ou blocos anônimos para Oracle).

```pascal
var Bonus := TBonusDto.Create;
try
  Bonus.EmpId := 10;
  Bonus.BaseAmount := 5000;
  
  // Executa e mapeia os resultados de volta para as propriedades do DTO
  Db.ExecuteProcedure(Bonus);
  
  WriteLn('Bônus Calculado: ', Bonus.BonusValue);
finally
  Bonus.Free;
end;
```

## Tipos de Parâmetros Suportados

| Tipo | Descrição |
|------|-----------|
| `ptInput` | Valor de entrada para a procedure. |
| `ptOutput` | Valor de saída populado pela procedure. |
| `ptInputOutput` | Valor passado na entrada e atualizado pela procedure. |
| `ptResult` | O valor de retorno de uma função ou procedure. |

## Por que usar Stored Procedures com Dext?

1. **Segurança de Tipos**: Acabe com o mapeamento manual de parâmetros por índice ou nome.
2. **Auto-Mapeamento**: Resultados de `ptOutput` e `ptResult` são automaticamente copiados de volta para o seu DTO.
3. **Abstração**: Seu código Pascal não precisa conhecer a sintaxe SQL específica necessária para chamar a procedure em diferentes motores de banco de dados.

---

[← Soft Delete](soft-delete.md) | [Próximo: Travamento e Concorrência →](travamento-concorrencia.md)
