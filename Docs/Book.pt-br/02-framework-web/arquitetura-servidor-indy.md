# Arquitetura do Servidor Dext & Análise Profunda do Indy

## 1. Resumo Executivo
Este documento descreve a arquitetura do Servidor HTTP Dext, implementado sobre a biblioteca **Indy (Internet Direct)**. Ele documenta as melhorias críticas de estabilidade realizadas para suportar a aplicação **Sidecar** (VCL/GUI), detalhando as causas raízes de travamentos anteriores (Access Violations) e os padrões arquiteturais estabelecidos para preveni-los.

## 2. Arquitetura do Servidor

### 2.1. O Padrão "Adapter" (Adaptador)
O Dext evita reinventar a roda adaptando o componente maduro `TIdHTTPServer` para a abstração `IWebHost`.

### 2.2. Modelo de Threads do Indy
Entender o Indy é crucial para a estabilidade:
1.  **Modelo Síncrono/Bloqueante**: Reserva uma thread do SO para cada conexão ativa.
2.  **Thread Ouvinte (Listener)**: Thread em segundo plano apenas para ouvir requisições.
3.  **Threads de Contexto**: Threads de trabalho dedicadas para cada cliente.

---

## 3. Análise de Causa Raiz: Problemas de Estabilidade do "Sidecar"

### 3.1. O Anti-Padrão "Thread Encapsulada"
**Problema**: O Sidecar estava envolvendo a chamada `IWebHost.Run` dentro de uma `TThread.CreateAnonymousThread`, gerando conflito de posse (ownership) e Access Violations no encerramento.

### 3.2. Inanição (Starvation) da Thread Principal VCL
**Problema**: Usar `Run` (loop bloqueante) na Thread Principal congela a interface gráfica (GUI).
**Correção**: Introduzimos o `Start` (Não-Bloqueante), que permite que o loop `Application.Run` da VCL processe mensagens livremente.

---

## 4. A Solução: Gerenciamento Robusto de Ciclo de Vida

### 4.1. Separação de Responsabilidades: `Start` vs `Run`

| Método | Comportamento | Ambiente Alvo |
| :--- | :--- | :--- |
| **`Start`** | Ativa o servidor e retorna imediatamente. NÃO bloqueia. | **VCL/FMX Forms** (Sidecar) |
| **`Run`** | Chama `Start`, depois entra em loop esperando sinal de término. | **Console Services** (CLI) |

### 4.2. Limpeza Agressiva de Sockets (`Stop`)
O método `Stop` agora itera pelas conexões ativas e chama `CloseSocket` forçadamente para garantir que threads bloqueadas em I/O sejam liberadas imediatamente.

---

[← Ciclo de Vida](ciclo-de-vida.md) | [Próximo: Middleware →](middleware.md)
