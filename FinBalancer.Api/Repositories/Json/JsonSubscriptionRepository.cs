using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonSubscriptionRepository : ISubscriptionRepository
{
    private const string FileName = "subscriptions.json";
    private readonly JsonStorageService _storage;

    public JsonSubscriptionRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<UserSubscription?> GetActiveByUserIdAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<UserSubscription>(FileName);
        return list
            .Where(s => s.UserId == userId && s.Status == "active" && s.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(s => s.ExpiresAt)
            .FirstOrDefault();
    }

    public async Task<List<UserSubscription>> GetByUserIdAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<UserSubscription>(FileName);
        return list.Where(s => s.UserId == userId).OrderByDescending(s => s.CreatedAt).ToList();
    }

    public async Task<UserSubscription?> GetByPurchaseTokenAsync(string platform, string purchaseToken)
    {
        var list = await _storage.ReadJsonAsync<UserSubscription>(FileName);
        return list.FirstOrDefault(s =>
            s.Platform.Equals(platform, StringComparison.OrdinalIgnoreCase) &&
            s.PurchaseToken == purchaseToken);
    }

    public async Task<UserSubscription> AddAsync(UserSubscription subscription)
    {
        subscription.Id = Guid.NewGuid();
        subscription.CreatedAt = DateTime.UtcNow;
        subscription.UpdatedAt = DateTime.UtcNow;

        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<UserSubscription>(FileName);
            list.Add(subscription);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return subscription;
    }

    public async Task<bool> UpdateAsync(UserSubscription subscription)
    {
        subscription.UpdatedAt = DateTime.UtcNow;
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<UserSubscription>(FileName);
            var index = list.FindIndex(s => s.Id == subscription.Id);
            if (index >= 0)
            {
                list[index] = subscription;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }
}
