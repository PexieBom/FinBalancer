namespace FinBalancer.Api.Data;

public class UserPreferenceEntity
{
    public Guid UserId { get; set; }
    public string Locale { get; set; } = "en";
    public string Currency { get; set; } = "EUR";
    public string Theme { get; set; } = "system";
}
