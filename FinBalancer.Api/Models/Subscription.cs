namespace FinBalancer.Api.Models;

/// <summary>
/// User subscription record - stores active/inactive subscriptions from App Store or Google Play.
/// </summary>
public class UserSubscription
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    /// <summary>Platform: "apple" | "google"</summary>
    public string Platform { get; set; } = string.Empty;
    /// <summary>Store product ID (e.g. finbalancer_premium_monthly)</summary>
    public string ProductId { get; set; } = string.Empty;
    /// <summary>Apple: originalTransactionId. Google: purchaseToken.</summary>
    public string PurchaseToken { get; set; } = string.Empty;
    /// <summary>Status: active | expired | cancelled | pending</summary>
    public string Status { get; set; } = "active";
    public DateTime ExpiresAt { get; set; }
    public DateTime? CancelledAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    /// <summary>Apple receipt data (base64) for validation</summary>
    public string? ReceiptData { get; set; }
    /// <summary>Google: order ID</summary>
    public string? OrderId { get; set; }
}
