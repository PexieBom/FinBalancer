using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IAchievementRepository
{
    Task<List<Achievement>> GetAllAsync();
    Task<bool> UnlockAsync(string key);
    Task<bool> IsUnlockedAsync(string key);
}
