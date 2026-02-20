namespace FinBalancer.Api.Data;

public class UserEntitlementEntity
{
    public Guid UserId { get; set; }
    public bool IsPremium { get; set; }
    public DateTime? PremiumUntil { get; set; }
    public string? SourcePlatform { get; set; }
    public DateTime UpdatedAt { get; set; }
}
