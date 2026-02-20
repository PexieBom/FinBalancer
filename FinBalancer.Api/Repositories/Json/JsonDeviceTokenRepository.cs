using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonDeviceTokenRepository : IDeviceTokenRepository
{
    private const string FileName = "device_tokens.json";
    private readonly JsonStorageService _storage;

    public JsonDeviceTokenRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task RegisterAsync(Guid userId, string token, string platform)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<DeviceToken>(FileName);
            var existing = list.FirstOrDefault(t => t.UserId == userId && t.Token == token);
            var now = DateTime.UtcNow;

            if (existing != null)
            {
                existing.Platform = platform;
                existing.UpdatedAt = now;
            }
            else
            {
                list.Add(new DeviceToken
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    Token = token,
                    Platform = platform,
                    CreatedAt = now,
                    UpdatedAt = now
                });
            }
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
    }

    public async Task<List<string>> GetTokensForUserAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<DeviceToken>(FileName);
        return list.Where(t => t.UserId == userId).Select(t => t.Token).ToList();
    }

    public async Task RemoveByTokenAsync(string token)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<DeviceToken>(FileName);
            list.RemoveAll(t => t.Token == token);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
    }
}
