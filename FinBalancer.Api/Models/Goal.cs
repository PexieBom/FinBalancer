namespace FinBalancer.Api.Models;

public class Goal
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public DateTime? Deadline { get; set; }
    public string Icon { get; set; } = "savings";
    public string Type { get; set; } = "savings"; // savings | travel | investment | custom
    public DateTime CreatedAt { get; set; }
}
