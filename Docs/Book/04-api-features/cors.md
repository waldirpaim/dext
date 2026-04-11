# CORS (Cross-Origin Resource Sharing)

Manage cross-origin requests securely using a fluent configuration builder.

## What is CORS?

CORS is a security mechanism that allows a server to indicate which origins (domains) are permitted to access its resources. By default, browsers block cross-origin requests for security reasons.

## Basic Usage

### 1. Permissive (Development)

To allow any origin during development:

```pascal
App.UseCors(procedure(Builder: TCorsBuilder)
  begin
    Builder
      .AllowAnyOrigin
      .AllowAnyMethod
      .AllowAnyHeader;
  end);
```

### 2. Restrictive (Production)

For production, always specify your domains:

```pascal
App.UseCors(procedure(Builder: TCorsBuilder)
  begin
    Builder
      .WithOrigins(['https://myapp.com', 'https://www.myapp.com'])
      .WithMethods(['GET', 'POST', 'PUT', 'DELETE'])
      .WithHeaders(['Content-Type', 'Authorization'])
      .AllowCredentials
      .WithMaxAge(3600); // Cache preflight response for 1 hour
  end);
```

## Configuration Options

| Method | Description |
|--------|-------------|
| `WithOrigins(['...'])` | Define permitted domains. |
| `AllowAnyOrigin` | Allow any origin (*). |
| `WithMethods(['...'])` | Define permitted HTTP verbs. |
| `AllowAnyMethod` | Allow any HTTP verb. |
| `WithHeaders(['...'])` | Define permitted request headers. |
| `AllowAnyHeader` | Allow any request header. |
| `WithExposedHeaders(['...'])` | Headers the client is allowed to see. |
| `AllowCredentials` | Enable cookie/auth header sharing. |
| `WithMaxAge(seconds)` | Sets how long preflight results can be cached. |

## Important Security Notes

1. **`AllowAnyOrigin` vs `AllowCredentials`**: Most browsers will reject a response if it allows *any origin* while also allowing *credentials*. You must specify explicit origins if you need credentials.
2. **Order Matters**: CORS middleware should be one of the first components in the pipeline to properly handle `OPTIONS` preflight requests.

---

[← Rate Limiting](rate-limiting.md) | [Next: Response Caching →](cache.md)
