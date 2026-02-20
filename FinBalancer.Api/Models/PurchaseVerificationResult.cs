namespace FinBalancer.Api.Models;

/// <summary>
/// Normalized result from Apple/Google/PayPal purchase verification.
/// </summary>
public record PurchaseVerificationResult(
    string ExternalId,
    string Status, // active|grace|on_hold|canceled|expired|refunded
    DateTime StartTime,
    DateTime? EndTime,
    string? RawPayload,
    bool AutoRenew,
    string? CancelReason
);
