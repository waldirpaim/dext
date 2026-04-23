Viewed Webinar_Embarcadero_Script.md:440-476

Boa pergunta. Vou ser direto:

## 🎯 Conselhos Adicionais

### 1. Não liste features — conte uma história
A tentação em webinars técnicos é mostrar tudo. Resista. O Ian Barker e a audiência da Embarcadero vêem demos de componentes toda semana. O que eles **nunca viram** é alguém mostrando como um framework Delphi resolve problemas **de ponta a ponta**. A narrativa é mais poderosa que a lista.

### 2. Código ao vivo > Slides
Cada segundo gasto em um slide é um segundo que poderia ser um `F9` + browser aberto. A audiência Delphi é de praticantes — eles confiam em código que roda, não em promessas em PowerPoint.

### 3. Abra com o que dói, não com o que brilha
Comece pelo problema ("5 libs coladas com fita"), não pela solução. A audiência precisa sentir a dor antes de querer o remédio.

### 4. O momento "wow" precisa vir nos primeiros 5 minutos
Se a audiência não se impressionar cedo, você perde a atenção. O `[DataApi]` + Swagger instantâneo é perfeito para isso.

---

## ⏱️ Se Eu Tivesse 15 Minutos Para "Vender" o Dext

Eu faria **um único demo live-coding** que conta toda a história em sequência, sem slides:

```
Minuto 0-2: O Problema (falando, sem código)
"Levantem a mão quem já precisou colar Spring4D + mORMot + Horse + DUnitX
 e passou semanas bridging APIs que não foram feitas para trabalhar juntas."

Minuto 2-5: Do Zero ao CRUD REST (live coding)
  → Criar um program.dpr mínimo
  → Definir TProduct com [Table], [PK]
  → Adicionar [DataApi]
  → App.MapDataApis + App.Run
  → F9 → Abrir browser → Swagger UI → POST um produto → GET com filtro
  💥 "1 linha de código. 10 subsistemas. API completa."

Minuto 5-8: "Mas isso qualquer gerador faz..." (o plot twist)
  → Trocar de aba para código
  → Mostrar que o filtro ?price_gt=50 usa o MESMO IExpression 
    que eu uso quando escrevo queries no ORM
  → Abrir o DbContext: Db.Products.Where(P.Price > 50).ToList
  → "Vejam: IntelliSense. Type-safe. Sem strings mágicas."
  → "O engine de Specifications que faz isso funcionar no ORM 
     é o MESMO que faz o DataApi funcionar. Não escrevi uma linha 
     extra de filtragem."
  💥 "Isso é o que integração real significa."

Minuto 8-11: A Performance Que Ninguém Vê (telemetria)
  → Ligar CaptureTelemetry: true no appsettings.json
  → Fazer um request via Swagger
  → Mostrar no console: [SQL] SELECT ... (2ms) / [HTTP] GET /api/products (4ms)
  → "Zero allocation. Do socket ao banco e de volta, sem intermediários."
  → (Opcional: mostrar TByteSpan no código se o tempo permitir)

Minuto 11-13: "E se eu quiser testes?"
  → Abrir um test file com TAutoMocker<TProductService>
  → "Todas as dependências mockadas automaticamente."
  → Rodar dext test --coverage no terminal
  → Mostrar relatório HTML de cobertura
  💥 "DI + ORM + Testes. Um framework. Um ecossistema."

Minuto 13-15: O Fechamento (falando, sem código)
  → "Java tem Spring. .NET tem ASP.NET Core. Python tem Django.
     O Delphi agora tem o Dext."
  → "Apache 2.0. Open source. Pronto para contribuições."
  → Mostrar o GitHub no browser
```

### Por que esse formato funciona:

| Princípio | Por quê |
|---|---|
| **Uma narrativa contínua** | A audiência segue uma história, não uma lista |
| **3 atos dramáticos** | Ato 1: impressiona (DataApi). Ato 2: surpreende (Specifications reuse). Ato 3: completa (Testing) |
| **O "plot twist" é a integração** | O momento em que você mostra que DataApi e ORM compartilham o mesmo engine é quando a ficha cai |
| **Zero slides** | Tudo é código rodando. Credibilidade instantânea |
| **Telemetria como prova** | Mostrar o SQL + timing no console prova performance sem benchmark slides |
| **Fechamento emocional** | A comparação com Java/Spring/.NET/Python posiciona o Dext como inevitável, não opcional |

### O que eu **não** faria:
- ❌ Não mostraria Navigator/Desktop (mesmo sendo incrível — é muita coisa para 15 min)
- ❌ Não abriria mais de 3 arquivos de código (overload cognitivo)
- ❌ Não falaria sobre o roadmap (Redis, gRPC) — foque no que **já funciona**
- ❌ Não mencionaria mORMot ou Horse pelo nome (deixe a audiência perguntar no Q&A)

### A frase que eu decoraria:
> *"Dext não é mais uma biblioteca. É a resposta para a pergunta que todo dev Delphi faz: por que eu preciso colar 5 projetos quando o C# me dá tudo em um?"*

---

Quer que eu crie um **mini-script de 15 minutos** formatado como documento separado, mais enxuto e focado nesse formato de demo live?

---

Created Infra.Context.pas
Created Infra.Services.pas
Created Presentation.Startup.pas
Created WebinarDemo.dpr
Created appsettings.json
Created Tests.ProductService.pas
Created WebinarDemo.Tests.dpr

Tudo pronto! Criei o projeto `WebinarDemo` completo, estruturado exatamente como você pediu (Clean Architecture + DDD) para o demo de amanhã. 

A estrutura ficou assim em `C:\dev\Dext\DextRepository\Docs\Talks\WebinarDemo`:

```text
WebinarDemo/
├── WebinarDemo.dpr                     # Entry point (com seed automático)
├── appsettings.json                    # Config para ligar/desligar Telemetria (Ato 3)
│
├── Domain/                             
│   ├── Domain.Entities.pas             # TProduct com [DataApi], Smart Props e [SoftDelete]
│   └── Domain.Interfaces.pas           # IProductService
│
├── Infrastructure/                     
│   ├── Infra.Context.pas               # SQLite DbContext
│   └── Infra.Services.pas              # Serviço usando P.IsActive == True (Smart Props)
│
├── Presentation/                       
│   └── Presentation.Startup.pas        # DI, Logging, Swagger e a mágica do .MapDataApis
│
└── Tests/                              
    ├── WebinarDemo.Tests.dpr           # Test Runner
    └── Tests.ProductService.pas        # Demo do TAutoMocker injetando o DbContext
```

### O que deixei preparado para a sua gravação amanhã:

1. **Ato 1 (DataApi & Swagger)**: O `Presentation.Startup.pas` já tem o `.MapDataApis` e a configuração do Swagger. O `WebinarDemo.dpr` faz um "seed" no banco SQLite com 2 produtos (Delphi 12 e Dext License) para que o Swagger não abra vazio.
2. **Ato 2 (A Revelação do Specification)**: O `Infra.Services.pas` tem um método `GetActiveProducts` que usa a Smart Property `P.IsActive = True`. Isso é perfeito para você colocar lado a lado com a aba do Swagger e falar: *"Estão vendo isso? É o mesmo motor!"*
3. **Ato 3 (A Telemetria e Zero-Alloc)**: O `appsettings.json` já tem `CaptureSql: true` e `CaptureHttp: true`. Basta você mostrar o console enquanto clica no Swagger.
4. **Ato 4 (A Confiança do Teste)**: O `Tests.ProductService.pas` demonstra o `TAutoMocker<TProductService>` resolvendo dependências num teste real.

O projeto está limpo, sem firulas, pronto para você compilar e treinar. Boa sorte na gravação amanhã! Vai ser um sucesso absurdo.