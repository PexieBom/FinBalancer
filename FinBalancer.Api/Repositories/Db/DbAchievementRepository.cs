using System.Security.Cryptography;
using System.Text;
using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Services;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbAchievementRepository : IAchievementRepository
{
    private readonly FinBalancerDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public DbAchievementRepository(FinBalancerDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<List<Achievement>> GetAllAsync()
    {
        var definitions = GetAchievementDefinitions();
        var userId = _currentUser.UserId ?? Guid.Empty;
        List<UnlockedAchievementEntity> unlocked;
        if (userId != Guid.Empty)
            unlocked = await _db.UnlockedAchievements.Where(u => u.UserId == userId).ToListAsync();
        else
            unlocked = new List<UnlockedAchievementEntity>();

        return definitions.Select(d => new Achievement
        {
            Id = CreateGuidFromString(d.Key),
            Key = d.Key,
            Name = d.Name,
            Icon = d.Icon,
            Description = d.Description,
            Period = d.Period,
            UnlockedAt = unlocked.FirstOrDefault(u => u.AchievementKey == d.Key)?.UnlockedAt
        }).ToList();
    }

    public async Task<bool> UnlockAsync(string key)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;

        var exists = await _db.UnlockedAchievements.AnyAsync(u => u.UserId == userId.Value && u.AchievementKey == key);
        if (exists) return true;

        _db.UnlockedAchievements.Add(new UnlockedAchievementEntity
        {
            Id = Guid.NewGuid(),
            UserId = userId.Value,
            AchievementKey = key,
            UnlockedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> IsUnlockedAsync(string key)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;
        return await _db.UnlockedAchievements.AnyAsync(u => u.UserId == userId.Value && u.AchievementKey == key);
    }

    private static List<(string Key, string Name, string Icon, string Description, string Period)> GetAchievementDefinitions()
    {
        return new List<(string Key, string Name, string Icon, string Description, string Period)>
        {
            ("first_transaction", "First Step", "touch_app", "Add your first transaction", "lifetime"),
            ("first_goal", "Goal Setter", "flag", "Create your first goal", "lifetime"),
            ("goal_reached", "Achiever", "emoji_events", "Reach a savings goal", "lifetime"),
            ("week_streak", "Weekly Tracker", "local_fire_department", "Log transactions 7 days in a row", "weekly"),
            ("budget_keeper", "Budget Master", "savings", "Stay under budget for a month", "monthly"),
            ("early_bird", "Early Bird", "schedule", "Add transaction before 9 AM", "daily"),
            ("ten_transactions", "Power User", "star", "Add 10 transactions", "lifetime"),
            ("month_saved", "Monthly Saver", "savings", "Saved money in a month (income > expense)", "monthly"),
            ("quarter_positive", "Quarter Winner", "trending_up", "3 months in a row with income > expense", "lifetime"),
            ("app_month", "One Month Active", "calendar_today", "Using FinBalancer for 1 month", "lifetime"),
            ("app_year", "One Year Strong", "celebration", "Using FinBalancer for 1 year", "lifetime")
        };
    }

    private static Guid CreateGuidFromString(string input)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes("achievement-" + input));
        return new Guid(bytes.Take(16).ToArray());
    }
}
