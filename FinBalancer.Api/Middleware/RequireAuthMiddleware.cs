using System.Text.Json;
using FinBalancer.Api.Models;

namespace FinBalancer.Api.Middleware;

/// <summary>Za zaštićene rute vraća 401 s konzistentnim JSON body ako korisnik nije autentificiran.</summary>
public class RequireAuthMiddleware
{
    private readonly RequestDelegate _next;

    private static readonly string[] AuthExemptPaths = ["/api/auth", "/health", "/"];
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public RequireAuthMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value ?? "";

        if (IsAuthExempt(path))
        {
            await _next(context);
            return;
        }

        if (!path.StartsWith("/api/", StringComparison.OrdinalIgnoreCase))
        {
            await _next(context);
            return;
        }

        var userId = context.Items["UserId"];
        if (userId != null)
        {
            await _next(context);
            return;
        }

        context.Response.StatusCode = 401;
        context.Response.ContentType = "application/json";

        var response = new ApiErrorResponse(
            Error: "Unauthorized",
            Message: "Authentication required. Please provide a valid token.",
            ErrorCode: "Unauthorized",
            TraceId: context.TraceIdentifier
        );

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, JsonOptions));
    }

    private static bool IsAuthExempt(string path)
    {
        if (string.IsNullOrEmpty(path)) return true;
        foreach (var exempt in AuthExemptPaths)
        {
            if (exempt == "/" && (path == "/" || path == "")) return true;
            if (exempt != "/" && path.StartsWith(exempt, StringComparison.OrdinalIgnoreCase)) return true;
        }
        return false;
    }
}
