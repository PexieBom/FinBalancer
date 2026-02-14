using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonCustomCategoryRepository : ICustomCategoryRepository
{
    private const string FileName = "custom_categories.json";
    private readonly JsonStorageService _storage;
    private static readonly Guid DefaultUserId = Guid.Empty;

    public JsonCustomCategoryRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<CustomCategory>> GetByUserIdAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<CustomCategory>(FileName);
        return list.Where(c => c.UserId == userId || (userId == DefaultUserId && c.UserId == DefaultUserId)).ToList();
    }

    public async Task<CustomCategory> AddAsync(CustomCategory category)
    {
        category.Id = Guid.NewGuid();
        category.Icon = "custom";
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<CustomCategory>(FileName);
            list.Add(category);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return category;
    }

    public async Task<bool> DeleteAsync(Guid id, Guid userId)
    {
        var deleted = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<CustomCategory>(FileName);
            var item = list.FirstOrDefault(c => c.Id == id && (c.UserId == userId || userId == DefaultUserId));
            if (item != null)
            {
                list.Remove(item);
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                deleted = true;
            }
        });
        return deleted;
    }
}
