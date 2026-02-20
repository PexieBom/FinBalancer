namespace FinBalancer.Api.Data;

public class SubscriptionPurchaseEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Platform { get; set; } = string.Empty;
    public string ProductCode { get; set; } = string.Empty;
    public string ExternalId { get; set; } = string.Empty;
    public string Status { get; set; } = "active"; // active|grace|on_hold|canceled|expired|refunded
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public string? RawPayload { get; set; } // JSONB stored as string
    public bool AutoRenew { get; set; } = true;
    public string? CancelReason { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
