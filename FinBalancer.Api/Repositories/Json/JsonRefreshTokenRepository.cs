using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonRefreshTokenRepository : IRefreshTokenRepository
{
    private const string FileName = "refresh_tokens.json";
    private readonly JsonStorageService _storage;

    public JsonRefreshTokenRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<RefreshTokenStore?> GetByTokenAsync(string token)
    {
        var list = await _storage.ReadJsonAsync<RefreshTokenStore>(FileName);
        var found = list.FirstOrDefault(r => r.Token == token && r.ExpiresAt > DateTime.UtcNow);
        return found;
    }

    public async Task AddAsync(RefreshTokenStore refreshToken)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<RefreshTokenStore>(FileName);
            list.RemoveAll(r => r.UserId == refreshToken.UserId);
            list.Add(refreshToken);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
    }

    public async Task RemoveAsync(string token)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<RefreshTokenStore>(FileName);
            list.RemoveAll(r => r.Token == token);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
    }
}
