namespace FinBalancer.Api.Models;

public class UserPreferences
{
    public string Locale { get; set; } = "en";
    public string Currency { get; set; } = "EUR";
    public string Theme { get; set; } = "system"; // light | dark | system
}
