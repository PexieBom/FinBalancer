using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonUserPreferencesRepository : IUserPreferencesRepository
{
    private const string FileName = "user_preferences.json";
    private readonly JsonStorageService _storage;

    public JsonUserPreferencesRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<UserPreferences?> GetByUserIdAsync(Guid? userId)
    {
        var prefs = await _storage.ReadObjectAsync<UserPreferences>(FileName);
        return prefs ?? new UserPreferences();
    }

    public async Task<UserPreferences> UpsertAsync(Guid userId, UserPreferences prefs)
    {
        await _storage.WriteObjectAsync(FileName, prefs);
        return prefs;
    }
}
