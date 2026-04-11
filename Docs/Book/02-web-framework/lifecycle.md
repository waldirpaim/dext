# Application Lifecycle & Data Integrity

Dext provides a robust system for managing the application lifecycle, ensuring that background tasks, database migrations, and web requests are handled in a coordinated and safe manner.

## Overview

The application lifecycle management is built around two core concepts:
1.  **Application Lifetime**: Signaling startup and shutdown events.
2.  **Application State**: Coordinating internal processes (like migrations) and controlling external access (via a startup lock).

---

## Application Lifetime (`IHostApplicationLifetime`)

The `IHostApplicationLifetime` interface allows components to be notified when the application has started or is about to stop. This is crucial for starting background workers or cleaning up resources.

### Available Events

*   `ApplicationStarted`: Triggered when the host has fully started and is ready to process requests.
*   `ApplicationStopping`: Triggered when the host is performing a graceful shutdown. Requests may still be in flight.
*   `ApplicationStopped`: Triggered when the host has completed a graceful shutdown and is about to terminate.

---

## Application State (`IAppStateObserver`)

Dext tracks the high-level state of the application to prevent issues like users accessing a database that is currently being migrated.

### Defined States
*   `asStarting`: The application is initializing.
*   `asMigrating`: Database migrations are being applied.
*   `asSeeding`: Initial data is being inserted.
*   `asRunning`: The application is ready to serve requests.
*   `asStopping`: The application is shutting down gracefully.
*   `asStopped`: The application has finished stopping.

---

## Startup Lock Middleware

To maintain data integrity, Dext includes a "Startup Lock" middleware. When active, it blocks incoming HTTP requests with a **503 Service Unavailable** status if the application is not in the `asRunning` state.

---

[← Middleware](middleware.md) | [Next: Controllers →](controllers.md)
