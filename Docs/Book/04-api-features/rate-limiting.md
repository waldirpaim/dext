# Rate Limiting

Protect your API from abuse, DDoS attacks, and scraping by limiting the number of requests per client.

## Basic Usage

### 1. Default (100 req/min)

```pascal
App.UseRateLimiting;
```

### 2. Custom Configuration

```pascal
App.UseRateLimiting(procedure(Options: TRateLimitBuilder)
  begin
    Options
      .WithPermitLimit(10)      // Maximum 10 requests 
      .WithWindow(60)           // Per 60 seconds (1 minute)
      .WithRejectionStatusCode(429);
  end);
```

## How it works

Dext identifies clients by their IP address (automatically supporting `X-Forwarded-For` if behind a proxy).

### HTTP Headers

The middleware adds standard headers to every response to inform the client:

- `X-RateLimit-Limit`: The total permitted requests in the window.
- `X-RateLimit-Remaining`: How many requests are left in the current window.
- `Retry-After`: (Sent only on 429) Seconds until the client can try again.

## Features

- **Thread-Safe**: Uses high-performance locking to handle concurrent requests.
- **Auto-Cleanup**: Automatically purges expired client data to save memory.
- **Zero-Config**: Reasonable defaults for quick startup.

## Best Practices

1. **Authentication**: Place `UseRateLimiting` **before** `UseAuthentication` to prevent unauthorized users from consuming too many server resources (e.g., CPU for hashing passwords).
2. **Specific Limits**: Consider different limits for different parts of your API.
   - Public reading: 200 req/min
   - Writing/Creating: 50 req/min
   - Authentication/Login: 5 req/min

## Example: Friendly Rejection

```pascal
Options.WithRejectionMessage(
  '{"error": "Too many requests", "message": "Please try again in 1 minute"}'
);
```

---

[← Action Filters](filters.md) | [Next: CORS →](cors.md)
