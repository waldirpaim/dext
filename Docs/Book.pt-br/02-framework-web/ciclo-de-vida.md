# Ciclo de Vida da Aplicação e Integridade de Dados

O Dext fornece um sistema robusto para gerenciar o ciclo de vida da aplicação, garantindo que tarefas de segundo plano, migrações de banco de dados e requisições web sejam tratadas de forma coordenada e segura.

## Visão Geral

O gerenciamento do ciclo de vida é construído em torno de dois conceitos:
1. **Application Lifetime**: Sinalização de eventos de início e interrupção.
2. **Application State**: Coordenação de processos internos (como migrações) e controle de acesso externo (via trava de inicialização).

---

## Application Lifetime (`IHostApplicationLifetime`)

A interface `IHostApplicationLifetime` permite que componentes sejam notificados quando a aplicação iniciou ou está prestes a parar. Isso é crucial para iniciar workers de fundo ou limpar recursos.

### Eventos Disponíveis

* `ApplicationStarted`: Disparado quando o host iniciou totalmente e está pronto para processar requisições.
* `ApplicationStopping`: Disparado quando o host está realizando um desligamento gracioso. Requisições ainda podem estar em andamento.
* `ApplicationStopped`: Disparado quando o host completou o desligamento gracioso e está prestes a encerrar.

---

## Estado da Aplicação (`IAppStateObserver`)

Dext monitora o estado de alto nível da aplicação para evitar problemas como usuários acessando um banco que está sendo migrado.

### Estados Definidos
* `asStarting`: A aplicação está inicializando.
* `asMigrating`: Migrações de banco de dados estão sendo aplicadas.
* `asSeeding`: Dados iniciais estão sendo inseridos.
* `asRunning`: A aplicação está pronta para receber requisições.
* `asStopping`: A aplicação está desligando graciosamente.
* `asStopped`: A aplicação terminou de desligar.

---

[← Middleware](middleware.md) | [Próximo: Controllers →](controllers.md)
