using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbUserPreferencesRepository : IUserPreferencesRepository
{
    private readonly FinBalancerDbContext _db;

    public DbUserPreferencesRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<UserPreferences?> GetByUserIdAsync(Guid? userId)
    {
        if (userId == null) return null;
        var e = await _db.UserPreferences.FindAsync(userId.Value);
        return e == null ? null : ToModel(e);
    }

    public async Task<UserPreferences> UpsertAsync(Guid userId, UserPreferences prefs)
    {
        var e = await _db.UserPreferences.FindAsync(userId);
        if (e == null)
        {
            e = new UserPreferenceEntity
            {
                UserId = userId,
                Locale = prefs.Locale,
                Currency = prefs.Currency,
                Theme = prefs.Theme
            };
            _db.UserPreferences.Add(e);
        }
        else
        {
            e.Locale = prefs.Locale;
            e.Currency = prefs.Currency;
            e.Theme = prefs.Theme;
        }
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    private static UserPreferences ToModel(UserPreferenceEntity e) => new()
    {
        Locale = e.Locale,
        Currency = e.Currency,
        Theme = e.Theme
    };
}
