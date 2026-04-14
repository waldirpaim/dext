# CLI: Scaffolding

O CLI automatiza a criação de entidades mapeando tabelas de um banco de dados real usando o motor de templates baseado em AST.

## Uso Básico

### Scaffolding de Todo o Banco
```bash
dext scaffold db -c "vendas.db" -d sqlite
```

### Adicionar Entidade em Particular
```bash
dext add entity Usuario -c "vendas.db" -d sqlite
```

## Resolução de Templates

O CLI utiliza uma estratégia de 3 níveis para encontrar templates:
1. **Local**: pasta `./Templates/` dentro do seu projeto.
2. **Global do Usuário**: `~/.dext/Templates/` (Diretório Home).
3. **Framework**: `$(DEXT)/Templates/` (Pasta de instalação do framework).

## Opções Detalhadas (scaffold db / add entity)

| Opção | Atalho | Descrição |
|--------|-------|-------------|
| `--connection` | `-c` | String de conexão (FireDAC) ou path do banco. |
| `--driver` | `-d` | Driver: `sqlite`, `pg`, `mssql`, `firebird`. |
| `--output` | `-o` | Diretório ou arquivo onde a Unit será salva. |
| `--template` | `-t` | Nome do template customizado (ex: `entity.pas.template`). |
| `--fluent` | | Gera mapeamento fluente (RegisterMappings) em vez de `[Atributos]`. |
| `--tables` | `-t` | Filtro de tabelas (apenas para scaffold db). Ex: `pedidos,itens`. |

## Por que usar Scaffolding?

- **Velocidade**: Evita a escrita manual de dezenas de propriedades e atributos.
- **Precisão**: Garante que os tipos Delphi (`Integer`, `string`, `TDateTime`) correspondam exatamente aos tipos do banco.
- **Consistência**: Mantém o padrão de nomenclatura e mapeamento em todo o projeto.

---

[← Migrations](migrations.md) | [Próximo: Testes →](testes.md)
