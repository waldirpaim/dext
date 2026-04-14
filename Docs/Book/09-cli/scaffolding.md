# CLI Scaffolding

Generate entity classes from existing database schema using the built-in AST-based template engine.

## Quick Start

### Scaffold Entire Database
```bash
dext scaffold db -c "mydb.db" -d sqlite
```

### Add Specific Entity
```bash
dext add entity User -c "mydb.db" -d sqlite
```

## Template Resolution

The CLI uses a 3-level resolution strategy to find templates:
1. **Local**: `./Templates/` folder in your project.
2. **User Global**: `~/.dext/Templates/` (Home directory).
3. **Framework**: `$(DEXT)/Templates/` (Installation directory).

## Options (scaffold db / add entity)

| Option | Alias | Description |
|--------|-------|-------------|
| `--connection` | `-c` | Connection string or file path |
| `--driver` | `-d` | Database driver: `sqlite`, `pg`, `mssql`, `firebird` |
| `--output` | `-o` | Output directory or file |
| `--template` | `-t` | Custom template name (e.g., `entity.pas.template`) |
| `--fluent` | | Generate fluent mapping instead of attributes |
| `--tables` | `-t` | Specific tables (comma-separated for scaffold db) |

## Examples

### SQLite

```bash
dext scaffold -c "myapp.db" -d sqlite -o Models/Entities.pas
```

### PostgreSQL

```bash
dext scaffold \
  -c "Server=localhost;Port=5432;Database=myapp;User_Name=postgres;Password=secret" \
  -d pg \
  -o Entities.pas
```

### SQL Server

```bash
dext scaffold \
  -c "Server=localhost,1433;Database=MyDB;User_Id=sa;Password=YourPassword" \
  -d mssql \
  --fluent
```

### Specific Tables

```bash
dext scaffold -c "mydb.db" -d sqlite -t "users,orders,products"
```

## Generated Code

### Attribute Mapping (Default)

```pascal
unit Entities;

interface

uses
  Dext.Entity.Attributes;

type
  [Table('users')]
  TUser = class
  private
    FId: Integer;
    FName: string;
    FEmail: string;
  public
    [PK, AutoInc]
    property Id: Integer read FId write FId;
    
    [Column('name')]
    property Name: string read FName write FName;
    
    [Column('email')]
    property Email: string read FEmail write FEmail;
  end;

implementation

end.
```

### Fluent Mapping (--fluent)

```pascal
unit Entities;

interface

type
  TUser = class
  public
    Id: Integer;
    Name: string;
    Email: string;
  end;

procedure RegisterMappings(Builder: TModelBuilder);

implementation

procedure RegisterMappings(Builder: TModelBuilder);
begin
  Builder.Entity<TUser>
    .Table('users')
    .HasKey('Id').AutoIncrement
    .Prop('Name').Column('name')
    .Prop('Email').Column('email');
end;

end.
```

## Type Mapping

| SQL Type | Delphi Type |
|----------|-------------|
| INTEGER, INT | Integer |
| BIGINT | Int64 |
| VARCHAR, TEXT | string |
| BOOLEAN, BIT | Boolean |
| FLOAT, DOUBLE | Double |
| DECIMAL | Double |
| DATE, DATETIME | TDateTime |
| UUID, GUID | TGUID |
| BLOB, BYTEA | TBytes |

Nullable columns become `Nullable<T>`.

---

[← Commands](commands.md) | [Next: Testing →](testing.md)
