using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonSubcategoryRepository : ISubcategoryRepository
{
    private const string FileName = "subcategories.json";
    private readonly JsonStorageService _storage;

    public JsonSubcategoryRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Subcategory>> GetByCategoryAsync(Guid categoryId)
    {
        var all = await _storage.ReadJsonAsync<Subcategory>(FileName);
        return all.Where(s => s.CategoryId == categoryId).ToList();
    }

    public async Task<List<Subcategory>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Subcategory>(FileName);
    }

    public async Task<Subcategory> AddAsync(Subcategory subcategory)
    {
        subcategory.Id = Guid.NewGuid();
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Subcategory>(FileName);
            list.Add(subcategory);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return subcategory;
    }
}
