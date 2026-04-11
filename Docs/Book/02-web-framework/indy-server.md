# Dext Server Architecture & Indy Deep Dive

## 1. Executive Summary

This document outlines the architecture of the Dext HTTP Server, implemented on top of the **Indy (Internet Direct)** library. It documents the critical stability improvements made to support the **Sidecar** (VCL/GUI) application, detailing the root causes of previous crashes (Access Violations) and the architectural standards established to prevent them.

## 2. Server Architecture

### 2.1. The "Adapter" Pattern
Dext avoids reinventing the wheel by adapting the mature `TIdHTTPServer` component into the `IWebHost` abstraction.

*   **TIndyWebServer (Adapter)**: Wraps `TIdHTTPServer`. It translates Indy's specific events (`OnCommandGet`) into Dext's pipeline requests (`IHttpContext`).
*   **Decoupling**: The rest of the framework (Controllers, Middleware, Routing) knows nothing about Indy. This allows swapping the underlying engine (e.g., to HTTP.sys or FastCGI) in the future without breaking application logic.

### 2.2. Indy's Threading Model
Understanding Indy is crucial for stability:
1.  **Synchronous/Blocking Model**: Unlike Node.js or Asp.Net (which use Async I/O), Indy reserves one OS thread per active connection.
2.  **Listener Thread**: `TIdHTTPServer` creates an internal background thread just to listen for incoming connection requests on the port.
3.  **Context Threads**: When a client connects, Indy spawns a dedicated worker thread (Context) that lives as long as the connection implies (or Keep-Alive duration).

---

## 3. Root Cause Analysis: The "Sidecar" Stability Issues

Prior to the recent refactoring, the Sidecar application suffered from intermittent Access Violations (AV) and "Hangs" during shutdown. Deep research revealed three converging anti-patterns:

### 3.1. The "Wrapped Thread" Anti-Pattern
**Problem**: The Sidecar was wrapping the `IWebHost.Run` call inside a `TThread.CreateAnonymousThread`.
**Analysis**:
*   `TIdHTTPServer` is **already multi-threaded**. It manages its own Listener and Worker threads.
*   By wrapping `Run` (which was blocking) in yet another thread, we created an ownership limbo.
*   **The Trap**: When the VCL Main Form closes, it destroys the interface reference. If the Anonymous Thread is still running (blocked inside `Run` loop), it tries to access the destroyed Interface/Object, causing an **Access Violation**.

### 3.2. VCL Main Thread Starvation
**Problem**: Using `Run` (blocking loop) on the Main Thread freezes the GUI.
**Fix**: We introduced `Start` (Non-Blocking).
*   `TIdHTTPServer.Active := True` is non-blocking. It spawns the Listener thread and returns immediately.
*   This allows the VCL `Application.Run` loop to handle Windows Messages freely while Indy handles Network Traffic in the background.

---

## 4. The Solution: Robust Lifecycle Management

### 4.1. Separation of Concerns: `Start` vs `Run`
We split the execution model to support both Console and GUI apps correctly:

| Method | Behavior | Target Environment |
| :--- | :--- | :--- |
| **`Start`** | Activates the server and returns immediately. Does NOT block. | **VCL/FMX Forms** (Sidecar) |
| **`Run`** | Calls `Start`, then enters a loop waiting for termination signal (Ctrl+C). | **Console Services** (CLI / Daemons) |

### 4.2. Aggressive Socket Cleaning (`Stop`)
The most critical fix for the "Hang" issue. Simply setting `Active := False` is insufficient for stuck threads.

**Algorithm implemented in `TIndyWebServer.Stop`**:
1.  **Graceful Signal**: Set global stopping flag.
2.  **Hard Interrupt**: Iterate through all active client connections (`Contexts`).
3.  **Force Close**: Call `Context.Binding.CloseSocket`.
    *   This forces the underlying OS socket to close.
    *   Indy raises an `EIdSocketError` immediately inside the worker thread.
4.  **Deactivation**: Finally, set `Active := False`.

---

[← Lifecycle](lifecycle.md) | [Next: Middleware →](middleware.md)
