using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class UserPreferencesService
{
    private readonly IUserPreferencesRepository _repository;
    private readonly ICurrentUserService _currentUser;

    public UserPreferencesService(IUserPreferencesRepository repository, ICurrentUserService currentUser)
    {
        _repository = repository;
        _currentUser = currentUser;
    }

    public async Task<UserPreferences> GetAsync()
    {
        var prefs = await _repository.GetByUserIdAsync(_currentUser.UserId);
        return prefs ?? new UserPreferences();
    }

    public async Task<UserPreferences> UpdateAsync(string locale, string currency, string theme = "system")
    {
        var prefs = new UserPreferences { Locale = locale, Currency = currency, Theme = theme };
        var userId = _currentUser.UserId;
        if (userId == null)
            return prefs; // Nije ulogiran – vraćamo predložene vrijednosti bez spremanja
        return await _repository.UpsertAsync(userId.Value, prefs);
    }
}
