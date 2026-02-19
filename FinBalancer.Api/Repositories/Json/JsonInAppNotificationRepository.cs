using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonInAppNotificationRepository : IInAppNotificationRepository
{
    private const string FileName = "in_app_notifications.json";
    private readonly JsonStorageService _storage;

    public JsonInAppNotificationRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<InAppNotification>> GetByUserIdAsync(Guid userId, int limit = 50)
    {
        var list = await _storage.ReadJsonAsync<InAppNotification>(FileName);
        return list
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(limit)
            .ToList();
    }

    public async Task<int> GetUnreadCountAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<InAppNotification>(FileName);
        return list.Count(n => n.UserId == userId && !n.IsRead);
    }

    public async Task<InAppNotification?> GetByIdAsync(Guid id)
    {
        var list = await _storage.ReadJsonAsync<InAppNotification>(FileName);
        return list.FirstOrDefault(n => n.Id == id);
    }

    public async Task<InAppNotification> AddAsync(InAppNotification notification)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<InAppNotification>(FileName);
            list.Add(notification);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return notification;
    }

    public async Task MarkAsReadAsync(Guid id)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<InAppNotification>(FileName);
            var idx = list.FindIndex(n => n.Id == id);
            if (idx >= 0)
            {
                list[idx].IsRead = true;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
            }
        });
    }

    public async Task MarkAllAsReadAsync(Guid userId)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<InAppNotification>(FileName);
            foreach (var n in list.Where(n => n.UserId == userId && !n.IsRead))
                n.IsRead = true;
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
    }
}
