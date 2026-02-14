namespace FinBalancer.Api.Models;

/// <summary>
/// User-created category. All custom categories use icon "custom".
/// Stored per user (UserId).
/// </summary>
public class CustomCategory
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Type { get; set; } = "expense"; // "income" | "expense"
    /// <summary>Always "custom" for user-created categories.</summary>
    public string Icon { get; set; } = "custom";
}
