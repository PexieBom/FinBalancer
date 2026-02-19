namespace FinBalancer.Api.Data;

public class UnlockedAchievementEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string AchievementKey { get; set; } = string.Empty;
    public DateTime UnlockedAt { get; set; }
}
