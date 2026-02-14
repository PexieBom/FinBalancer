using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services;

public class UserPreferencesService
{
    private const string FileName = "user_preferences.json";
    private readonly JsonStorageService _storage;

    public UserPreferencesService(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<UserPreferences> GetAsync()
    {
        var prefs = await _storage.ReadObjectAsync<UserPreferences>(FileName);
        return prefs ?? new UserPreferences();
    }

    public async Task<UserPreferences> UpdateAsync(string locale, string currency, string theme = "system")
    {
        var prefs = new UserPreferences { Locale = locale, Currency = currency, Theme = theme };
        await _storage.WriteObjectAsync(FileName, prefs);
        return prefs;
    }
}
