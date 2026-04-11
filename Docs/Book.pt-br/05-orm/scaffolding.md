# Scaffolding

A ferramenta de Scaffolding do Dext ORM permite gerar automaticamente classes de Entidade Delphi a partir de um esquema de banco de dados existente. Suporta tanto **Mapeamento via Atributos** quanto **Mapeamento Fluente**.

## Recursos

- **Database First**: Conecta ao seu banco de dados (via FireDAC) e extrai informações do esquema.
- **Mapeamento de Tabelas e Colunas**: Gera classes para tabelas e propriedades para colunas.
- **Mapeamento de Tipos**: Mapeia automaticamente tipos SQL para tipos Delphi (Integer, string, TDateTime, etc.).
- **Suporte a Nullable**: Utiliza `Nullable<T>` para colunas de banco que permitem nulo.
- **Relacionamentos**: Detecta Chaves Estrangeiras e gera propriedades de navegação para lazy loading.
- **Convenções de Nomenclatura**: Converte automaticamente nomes `snake_case` do banco para `PascalCase` em Delphi.

## Uso via CLI (Recomendado)

A forma mais fácil de usar o scaffolding é através da CLI do Dext:

```bash
dext scaffold --connection <string> --driver <driver> [options]
```

### Opções

| Opção | Alias | Descrição |
|--------|-------|-----------|
| `--connection` | `-c` | String de conexão FireDAC ou caminho do arquivo do banco |
| `--driver` | `-d` | Driver do banco: `sqlite`, `pg`, `mssql`, `firebird` |
| `--output` | `-o` | Caminho do arquivo de saída (padrão: `Entities.pas`) |
| `--fluent` | | Usa Mapeamento Fluente em vez de Atributos |
| `--tables` | `-t` | Nomes das tabelas (separados por vírgula) para incluir |

### Exemplos

**SQLite**:
```bash
dext scaffold -c "meuapp.db" -d sqlite -o Models/Entities.pas
```

**PostgreSQL**:
```bash
dext scaffold -c "host=localhost;database=meuapp;user=postgres;password=secret" -d pg --fluent
```

## Uso Programático

Para cenários avançados, você pode usar a API de scaffolding diretamente:

```pascal
uses
  Dext.Entity.Scaffolding,
  Dext.Entity.Drivers.FireDAC;

procedure GenerateEntities;
var
  Connection: IDbConnection;
  Provider: ISchemaProvider;
  Generator: IEntityGenerator;
  Tables: TArray<string>;
  MetaList: TArray<TMetaTable>;
  Code: string;
begin
  Connection := TFireDACConnection.Create(FDConnection1);
  Provider := TFireDACSchemaProvider.Create(Connection);
  
  // Extrai Metadados
  Tables := Provider.GetTables;
  for var i := 0 to High(Tables) do
    AddTableToMetaList(Provider.GetTableMetadata(Tables[i]));
    
  // Gera o Código
  Generator := TDelphiEntityGenerator.Create;
  Code := Generator.GenerateUnit('MinhasEntidades', MetaList);
  
  TFile.WriteAllText('MinhasEntidades.pas', Code);
end;
```

## Exemplo de Código Gerado

```pascal
[Table('users')]
TUser = class
private
  FId: Integer;
  FName: string;
public
  [PK] [AutoInc] 
  property Id: Integer read FId write FId;
  
  [Column('name')] 
  property Name: string read FName write FName;
end;
```

---

[← Migrations](migrations.md) | [Próximo: Multi-Tenancy →](multi-tenancy.md)
