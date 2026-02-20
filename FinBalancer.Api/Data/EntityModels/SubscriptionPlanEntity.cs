namespace FinBalancer.Api.Data;

public class SubscriptionPlanEntity
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty;
    public string? AppleProductId { get; set; }
    public string? GoogleProductId { get; set; }
    public string? PayPalPlanId { get; set; }
    public string Duration { get; set; } = "monthly";
    public decimal Price { get; set; }
    public string Currency { get; set; } = "EUR";
    public bool IsActive { get; set; } = true;
}
