using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonUserRepository : IUserRepository
{
    private const string FileName = "users.json";
    private readonly JsonStorageService _storage;

    public JsonUserRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<User?> GetByIdAsync(Guid id)
    {
        var users = await _storage.ReadJsonAsync<User>(FileName);
        return users.FirstOrDefault(u => u.Id == id);
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        var users = await _storage.ReadJsonAsync<User>(FileName);
        return users.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
    }

    public async Task<User?> GetByGoogleIdAsync(string googleId)
    {
        var users = await _storage.ReadJsonAsync<User>(FileName);
        return users.FirstOrDefault(u => u.GoogleId == googleId);
    }

    public async Task<User?> GetByAppleIdAsync(string appleId)
    {
        var users = await _storage.ReadJsonAsync<User>(FileName);
        return users.FirstOrDefault(u => u.AppleId == appleId);
    }

    public async Task<User> AddAsync(User user)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<User>(FileName);
            list.Add(user);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return user;
    }

    public async Task<bool> UpdateAsync(User user)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<User>(FileName);
            var index = list.FindIndex(u => u.Id == user.Id);
            if (index >= 0)
            {
                list[index] = user;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }
}
