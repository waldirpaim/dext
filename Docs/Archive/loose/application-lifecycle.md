# 🔄 Application Lifecycle & Data Integrity

Dext provides a robust system for managing the application lifecycle, ensuring that background tasks, database migrations, and web requests are handled in a coordinated and safe manner.

## 🏁 Overview

The application lifecycle management is built around two core concepts:
1.  **Application Lifetime**: Signaling startup and shutdown events.
2.  **Application State**: Coordinating internal processes (like migrations) and controlling external access (via a startup lock).

---

## 🛰️ Application Lifetime (`IHostApplicationLifetime`)

The `IHostApplicationLifetime` interface allows components to be notified when the application has started or is about to stop. This is crucial for starting background workers or cleaning up resources.

### Available Events
All events expose an `ICancellationToken` that allows you to register callbacks or poll for status.

*   `ApplicationStarted`: Triggered when the host has fully started and is ready to process requests.
*   `ApplicationStopping`: Triggered when the host is performing a graceful shutdown. Requests may still be in flight.
*   `ApplicationStopped`: Triggered when the host has completed a graceful shutdown and is about to terminate.

### Usage Example
```pascal
type
  TMyService = class
  public
    constructor Create(Lifetime: IHostApplicationLifetime);
  end;

constructor TMyService.Create(Lifetime: IHostApplicationLifetime);
begin
  Lifetime.ApplicationStarted.Register(
    procedure
    begin
      Writeln('My Service knows the app has started!');
    end);
end;
```

---

## 🚦 Application State (`IAppStateObserver`)

Dext tracks the high-level state of the application to prevent issues like users accessing a database that is currently being migrated.

### Defined States
*   `asStarting`: The application is initializing.
*   `asMigrating`: Database migrations are being applied.
*   `asSeeding`: Initial data is being inserted.
*   `asRunning`: The application is ready to serve requests.
*   `asStopping`: The application is shutting down gracefully.
*   `asStopped`: The application has finished stopping.

---

## 🔒 Startup Lock Middleware

To maintain data integrity, Dext includes a "Startup Lock" middleware. When active, it blocks incoming HTTP requests with a **503 Service Unavailable** status if the application is not in the `asRunning` state.

### How it works
1.  If the app is `asMigrating` or `asSeeding`, the middleware rejects the request.
2.  It automatically adds a `Retry-After: 5` header, telling clients (like browsers or load balancers) to try again shortly.
3.  The response includes a clear message indicating the current state (e.g., "Service Unavailable: Application is Migrating Database").

### Configuration
Enable it in your `Startup` or `WebApplication` setup:

```pascal
var App := TWebHostBuilder.CreateDefault(Args).Build;

App.UseStartupLock; // ⬅️ Add this before Routing/Controllers
App.UseRouting;
App.MapControllers;

App.Run;
```

---

## 🔄 Automatic Migrations

Dext can automatically run database migrations during startup. When enabled, the application state transitions to `asMigrating`, triggering the Startup Lock until the process is complete.

### Enabling Auto-Migrations
Add the following to your `appsettings.json`:

```json
{
  "Database": {
    "AutoMigrate": true
  }
}
```

The host will automatically resolve your `IDbContext` and run `TMigrator.Migrate` before signaling `ApplicationStarted`.

---

## 🛑 Graceful Shutdown

Dext ensures that when the application receives a termination signal (like `Ctrl+C` or a system stop), it doesn't just "die". Instead:

1.  The Web Server stops accepting new connections.
2.  `ApplicationStopping` is signaled.
3.  All `IHostedService` (Background Services) are stopped via `StopAsync`.
4.  Pending requests are allowed a short period to complete.
5.  `ApplicationStopped` is signaled.
6.  The process terminates cleanly.

### Manual Shutdown
You can also trigger a shutdown programmatically:

```pascal
// Inject IHostApplicationLifetime
Lifetime.StopApplication;
```
