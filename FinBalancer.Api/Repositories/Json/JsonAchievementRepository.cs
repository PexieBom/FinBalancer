using System.Security.Cryptography;
using System.Text;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonAchievementRepository : IAchievementRepository
{
    private const string FileName = "achievements.json";
    private const string UnlockedFileName = "achievements_unlocked.json";
    private readonly JsonStorageService _storage;

    public JsonAchievementRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Achievement>> GetAllAsync()
    {
        var definitions = GetAchievementDefinitions();
        var unlocked = await _storage.ReadJsonAsync<UnlockedAchievement>(UnlockedFileName);

        return definitions.Select(d => new Achievement
        {
            Id = CreateGuidFromString(d.Key),
            Key = d.Key,
            Name = d.Name,
            Icon = d.Icon,
            Description = d.Description,
            UnlockedAt = unlocked.FirstOrDefault(u => u.Key == d.Key)?.UnlockedAt
        }).ToList();
    }

    public async Task<bool> UnlockAsync(string key)
    {
        var unlocked = await _storage.ReadJsonAsync<UnlockedAchievement>(UnlockedFileName);
        if (unlocked.Any(u => u.Key == key)) return true;

        unlocked.Add(new UnlockedAchievement { Key = key, UnlockedAt = DateTime.UtcNow });
        await _storage.WriteJsonAsync(UnlockedFileName, unlocked);
        return true;
    }

    public async Task<bool> IsUnlockedAsync(string key)
    {
        var unlocked = await _storage.ReadJsonAsync<UnlockedAchievement>(UnlockedFileName);
        return unlocked.Any(u => u.Key == key);
    }

    private static List<AchievementDefinition> GetAchievementDefinitions()
    {
        return new List<AchievementDefinition>
        {
            new() { Key = "first_transaction", Name = "First Step", Icon = "touch_app", Description = "Add your first transaction" },
            new() { Key = "first_goal", Name = "Goal Setter", Icon = "flag", Description = "Create your first goal" },
            new() { Key = "goal_reached", Name = "Achiever", Icon = "emoji_events", Description = "Reach a savings goal" },
            new() { Key = "week_streak", Name = "Weekly Tracker", Icon = "local_fire_department", Description = "Log transactions 7 days in a row" },
            new() { Key = "budget_keeper", Name = "Budget Master", Icon = "savings", Description = "Stay under budget for a month" },
            new() { Key = "early_bird", Name = "Early Bird", Icon = "schedule", Description = "Add transaction before 9 AM" },
            new() { Key = "ten_transactions", Name = "Power User", Icon = "star", Description = "Add 10 transactions" }
        };
    }

    private static Guid CreateGuidFromString(string input)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes("achievement-" + input));
        return new Guid(bytes.Take(16).ToArray());
    }

    private class AchievementDefinition
    {
        public string Key { get; set; } = "";
        public string Name { get; set; } = "";
        public string Icon { get; set; } = "";
        public string Description { get; set; } = "";
    }

    private class UnlockedAchievement
    {
        public string Key { get; set; } = "";
        public DateTime UnlockedAt { get; set; }
    }
}
