using FinBalancer.Api.Services;

namespace FinBalancer.Api.Middleware;

public class CurrentUserMiddleware
{
    private readonly RequestDelegate _next;
    private const string AuthorizationHeader = "Authorization";
    private const string BearerPrefix = "Bearer ";

    public CurrentUserMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IAuthService authService)
    {
        if (context.Request.Path.StartsWithSegments("/api/auth", StringComparison.OrdinalIgnoreCase))
        {
            await _next(context);
            return;
        }

        var authHeader = context.Request.Headers[AuthorizationHeader].FirstOrDefault();
        if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith(BearerPrefix, StringComparison.OrdinalIgnoreCase))
        {
            var token = authHeader[BearerPrefix.Length..].Trim();
            var user = await authService.GetUserByTokenAsync(token);
            if (user != null)
            {
                context.Items["UserId"] = user.Id;
            }
        }

        await _next(context);
    }
}
