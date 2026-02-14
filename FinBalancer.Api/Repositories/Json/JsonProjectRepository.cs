using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonProjectRepository : IProjectRepository
{
    private const string FileName = "projects.json";
    private readonly JsonStorageService _storage;

    public JsonProjectRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Project>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Project>(FileName);
    }

    public async Task<Project?> GetByIdAsync(Guid id)
    {
        var list = await _storage.ReadJsonAsync<Project>(FileName);
        return list.FirstOrDefault(p => p.Id == id);
    }

    public async Task<Project> AddAsync(Project project)
    {
        project.Id = Guid.NewGuid();
        project.CreatedAt = DateTime.UtcNow;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Project>(FileName);
            list.Add(project);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return project;
    }

    public async Task<bool> UpdateAsync(Project project)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Project>(FileName);
            var index = list.FindIndex(p => p.Id == project.Id);
            if (index >= 0)
            {
                list[index] = project;
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
            var list = await _storage.ReadJsonUnsafeAsync<Project>(FileName);
            var index = list.FindIndex(p => p.Id == id);
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
