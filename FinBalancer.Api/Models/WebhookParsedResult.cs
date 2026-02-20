namespace FinBalancer.Api.Models;

/// <summary>
/// Normalized result from webhook payload parsing (Apple/Google/PayPal).
/// </summary>
public record WebhookParsedResult(
    string EventId,
    string ExternalId,
    Guid? UserId,
    string Status,
    DateTime StartTime,
    DateTime? EndTime,
    string ProductCode,
    string? RawPayload
);
