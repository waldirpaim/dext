# Logging e Diagnósticos

O Dext possui um sistema de logging robusto, inspirado no ecossistema .NET, que permite registrar mensagens de forma estruturada e direcioná-las para diferentes destinos (Sinks).

## Configuração Básica

O logging é configurado no método `ConfigureServices` da sua classe `Startup` usando o builder fluente:

```pascal
procedure TStartup.ConfigureServices(const Services: TDextServices; const Configuration: IConfiguration);
begin
  Services.AddLogging(
    procedure(Builder: ILoggingBuilder)
    begin
      Builder
        .SetMinimumLevel(TLogLevel.Information)
        .AddConsole
        .AddTelemetry; // Roteia eventos de telemetria para o log
    end);
end;
```

## Níveis de Log

Os seguintes níveis estão disponíveis (em ordem de severidade):

| Nível | Descrição |
| :--- | :--- |
| `Trace` | Logs detalhados para diagnóstico profundo. |
| `Debug` | Logs úteis durante o desenvolvimento. |
| `Information` | Fluxos normais da aplicação (startup, requisições). |
| `Warning` | Eventos anômalos que não interrompem o fluxo. |
| `Error` | Falhas que impedem uma operação específica. |
| `Critical` | Falhas críticas que exigem atenção imediata. |

## Log em Arquivo

O Dext inclui um provedor nativo para gravação em arquivos. Os arquivos são gravados no formato **JSON Lines** por padrão, facilitando o consumo por ferramentas de análise.

```pascal
Builder.AddFile('logs/app.log', 10, True); // Nome, Tamanho Max (MB), Rotação Diária
```

### Rotação de Arquivos (Rolling Files)

O provedor de arquivo do Dext suporta dois mecanismos de rotação automática para evitar que os arquivos de log cresçam indefinidamente:

1.  **Rotação Diária (`ARollDaily`)**: Quando ativado, ao mudar o dia, o arquivo atual (ex: `app.log`) é renomeado para incluir a data (ex: `app-2026-05-14.log`) e um novo arquivo de log é iniciado.
2.  **Rotação por Tamanho (`AMaxFileSizeMB`)**: Se o arquivo atingir o limite definido em Megabytes, ele é rotacionado com um sufixo numérico (ex: `app.001.log`, `app.002.log`) e um novo arquivo limpo é criado.

Você pode combinar ambos os mecanismos para garantir uma política de retenção robusta.

### Segurança e Concorrência (Thread-Safety)

O sistema de logging do Dext é **totalmente thread-safe**. 
- O `TFileSink` utiliza um sistema de trava (`TMonitor`) interna para garantir que múltiplas threads (como requisições HTTP simultâneas) possam logar sem corromper o arquivo ou o buffer.
- As mensagens são acumuladas em um buffer de memória (4KB) antes de serem escritas no disco, reduzindo drasticamente o número de operações de I/O.

### Alta Performance com RingBuffer (Async Logging)

Para aplicações de altíssimo desempenho, onde o tempo de resposta é crítico, o Dext oferece o modo **Async Logging**. Ele utiliza o `RingBuffer` nativo (lock-free) para que a thread da sua aplicação nunca fique bloqueada aguardando o disco ou o console.

```pascal
Services.AddLogging(
  procedure(Builder: ILoggingBuilder)
  begin
    Builder
      .AddAsync // Ativa o modo de alta performance
      .SetMinimumLevel(TLogLevel.Information)
      .AddConsole
      .AddFile('logs/app.log', 10, True);
  end);
```

> [!IMPORTANT]
> Ao ativar o `.AddAsync`, o Dext gerencia automaticamente um pool de buffers e uma thread dedicada para o despacho dos logs, garantindo que o impacto no "Hot Path" da sua aplicação seja praticamente nulo.

> [!TIP]
> O modo síncrono padrão já é extremamente eficiente devido ao buffering interno de 4KB. O modo Async é recomendado para cenários de throughput massivo ou onde latências de microsegundos são importantes.

## Utilizando o ILogger

Para registrar mensagens, você deve solicitar a interface `ILogger` via Injeção de Dependência em seus controladores ou serviços:

```pascal
type
  TMyController = class(TWebController)
  private
    FLogger: ILogger;
  public
    constructor Create(const ALogger: ILogger);
    
    function Get: IWebResponse;
  end;

function TMyController.Get: IWebResponse;
begin
  FLogger.Info('Processando requisição para {Path}', [Request.Path]);
  // ...
end;
```

### Mensagens Estruturadas

O Dext suporta mensagens estruturadas usando a sintaxe de chaves `{}`. Isso permite que provedores avançados (como o Telemetry Bridge) capturem os parâmetros de forma independente da mensagem formatada.

```pascal
FLogger.LogInformation('Pedido {Id} processado com sucesso em {Duration}ms', [LOrderId, LDuration]);
```

## Logging de Requisições HTTP

Para registrar automaticamente todas as requisições HTTP (URL, Método, Status Code, Tempo), adicione o middleware no método `Configure`:

```pascal
procedure TStartup.Configure(const App: IWebApplication);
begin
  App.Builder.UseHttpLogging;
  // ...
end;
```

---

[← Telemetria](observabilidade.md)
