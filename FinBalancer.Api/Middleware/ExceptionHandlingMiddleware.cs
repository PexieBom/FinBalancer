using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Hosting;

namespace FinBalancer.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception: {Message}", ex.Message);
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json";

            var isDev = context.RequestServices.GetService<IWebHostEnvironment>()?.IsDevelopment() == true;
            var body = new Dictionary<string, string>
            {
                ["error"] = "Internal server error",
                ["message"] = isDev ? ex.Message : "An error occurred. Please try again."
            };
            if (isDev && ex.StackTrace != null)
                body["stackTrace"] = ex.StackTrace;

            await context.Response.WriteAsync(JsonSerializer.Serialize(body));
        }
    }
}
