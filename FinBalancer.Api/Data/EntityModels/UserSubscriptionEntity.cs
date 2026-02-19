namespace FinBalancer.Api.Data;

public class UserSubscriptionEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Platform { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty;
    public string PurchaseToken { get; set; } = string.Empty;
    public string Status { get; set; } = "active";
    public DateTime ExpiresAt { get; set; }
    public DateTime? CancelledAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string? ReceiptData { get; set; }
    public string? OrderId { get; set; }
}
