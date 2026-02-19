using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IUserPreferencesRepository
{
    Task<UserPreferences?> GetByUserIdAsync(Guid? userId);
    Task<UserPreferences> UpsertAsync(Guid userId, UserPreferences prefs);
}
