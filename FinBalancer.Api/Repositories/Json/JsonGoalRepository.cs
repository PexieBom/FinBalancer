using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonGoalRepository : IGoalRepository
{
    private const string FileName = "goals.json";
    private readonly JsonStorageService _storage;

    public JsonGoalRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Goal>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Goal>(FileName);
    }

    public async Task<Goal?> GetByIdAsync(Guid id)
    {
        var items = await _storage.ReadJsonAsync<Goal>(FileName);
        return items.FirstOrDefault(g => g.Id == id);
    }

    public async Task<Goal> AddAsync(Goal goal)
    {
        goal.Id = Guid.NewGuid();
        goal.CreatedAt = DateTime.UtcNow;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Goal>(FileName);
            list.Add(goal);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return goal;
    }

    public async Task<bool> UpdateAsync(Goal goal)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Goal>(FileName);
            var index = list.FindIndex(g => g.Id == goal.Id);
            if (index >= 0)
            {
                list[index] = goal;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var deleted = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Goal>(FileName);
            var index = list.FindIndex(g => g.Id == id);
            if (index >= 0)
            {
                list.RemoveAt(index);
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                deleted = true;
            }
        });
        return deleted;
    }
}
