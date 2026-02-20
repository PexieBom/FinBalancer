namespace FinBalancer.Api.Models;

/// <summary>Konzistentan format za sve API greške.</summary>
public record ApiErrorResponse(
    string Error,
    string Message,
    string? ErrorCode = null,
    string? TraceId = null,
    string? StackTrace = null,
    Dictionary<string, string[]>? Details = null
);
