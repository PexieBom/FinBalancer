using System.Net;
using System.Text.Json;
using FinBalancer.Api.Exceptions;
using FinBalancer.Api.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace FinBalancer.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = false
    };

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
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception ex)
    {
        var traceId = context.TraceIdentifier;
        var isDev = context.RequestServices.GetService<IWebHostEnvironment>()?.IsDevelopment() == true;

        var (statusCode, error, message, errorCode) = ex switch
        {
            ApiException apiEx => ((int)apiEx.StatusCode, GetErrorLabel(apiEx.StatusCode), apiEx.Message, apiEx.ErrorCode),
            UnauthorizedAccessException => (401, "Unauthorized", "Access denied.", "Unauthorized"),
            KeyNotFoundException or FileNotFoundException => (404, "Not Found", ex.Message, "NotFound"),
            ArgumentException or ArgumentNullException => (400, "Bad Request", ex.Message, "InvalidArgument"),
            InvalidOperationException => (400, "Bad Request", ex.Message, "InvalidOperation"),
            DbUpdateException dbEx => MapDbException(dbEx),
            NpgsqlException npgsqlEx => MapNpgsqlException(npgsqlEx),
            _ => (500, "Internal server error", isDev ? ex.Message : "An error occurred. Please try again.", "ServerError")
        };

        _logger.LogError(ex, "API Error [{StatusCode}] {Message} | TraceId: {TraceId}", statusCode, message, traceId);

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        var response = new ApiErrorResponse(
            Error: error,
            Message: message,
            ErrorCode: errorCode,
            TraceId: traceId,
            StackTrace: isDev && ex.StackTrace != null ? ex.StackTrace : null
        );

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, JsonOptions));
    }

    private static (int statusCode, string error, string message, string? errorCode) MapDbException(DbUpdateException ex)
    {
        var inner = ex.InnerException;
        if (inner is NpgsqlException npgsql)
            return MapNpgsqlException(npgsql);

        return (500, "Database error", "A database error occurred.", "DbError");
    }

    private static (int statusCode, string error, string message, string? errorCode) MapNpgsqlException(NpgsqlException ex)
    {
        return ex.SqlState switch
        {
            "23503" => (400, "Bad Request", "Referenced record does not exist.", "ForeignKeyViolation"),
            "23505" => (409, "Conflict", "Record already exists.", "UniqueViolation"),
            "23502" => (400, "Bad Request", "Required field is missing.", "NotNullViolation"),
            "08000" or "08003" or "08006" => (503, "Service Unavailable", "Database is unavailable. Please try again later.", "DbUnavailable"),
            _ => (500, "Database error", "A database error occurred.", "DbError")
        };
    }

    private static string GetErrorLabel(HttpStatusCode statusCode) => statusCode switch
    {
        HttpStatusCode.BadRequest => "Bad Request",
        HttpStatusCode.Unauthorized => "Unauthorized",
        HttpStatusCode.Forbidden => "Forbidden",
        HttpStatusCode.NotFound => "Not Found",
        HttpStatusCode.Conflict => "Conflict",
        HttpStatusCode.UnprocessableEntity => "Unprocessable Entity",
        HttpStatusCode.ServiceUnavailable => "Service Unavailable",
        _ => "Error"
    };
}
