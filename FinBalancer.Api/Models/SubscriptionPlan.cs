namespace FinBalancer.Api.Models;

/// <summary>
/// Subscription plan definition - maps to App Store / Google Play products.
/// </summary>
public class SubscriptionPlan
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty; // Shared key (e.g. finbalancer_premium_monthly)
    /// <summary>Apple App Store product ID</summary>
    public string? AppleProductId { get; set; }
    /// <summary>Google Play product ID</summary>
    public string? GoogleProductId { get; set; }
    public string Duration { get; set; } = "monthly"; // monthly | yearly
    public decimal Price { get; set; }
    public string Currency { get; set; } = "EUR";
    public bool IsActive { get; set; } = true;
}
