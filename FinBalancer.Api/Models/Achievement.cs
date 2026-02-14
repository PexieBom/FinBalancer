namespace FinBalancer.Api.Models;

public class Achievement
{
    public Guid Id { get; set; }
    public string Key { get; set; } = string.Empty; // first_transaction, goal_reached, etc.
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime? UnlockedAt { get; set; }
}
