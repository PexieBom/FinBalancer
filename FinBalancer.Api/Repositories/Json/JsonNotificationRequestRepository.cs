using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonNotificationRequestRepository : INotificationRequestRepository
{
    private const string FileName = "notification_requests.json";
    private readonly JsonStorageService _storage;

    public JsonNotificationRequestRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<NotificationRequest?> GetByTokenAsync(string token, string type)
    {
        var requests = await _storage.ReadJsonAsync<NotificationRequest>(FileName);
        return requests.FirstOrDefault(r => r.Token == token && r.Type == type && r.UsedAt == null && r.ExpiresAt > DateTime.UtcNow);
    }

    public async Task<NotificationRequest> AddAsync(NotificationRequest request)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<NotificationRequest>(FileName);
            list.Add(request);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return request;
    }

    public async Task<bool> MarkAsUsedAsync(Guid id)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<NotificationRequest>(FileName);
            var index = list.FindIndex(r => r.Id == id);
            if (index >= 0)
            {
                list[index].UsedAt = DateTime.UtcNow;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }
}
