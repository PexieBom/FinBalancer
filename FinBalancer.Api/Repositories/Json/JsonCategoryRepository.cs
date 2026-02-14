using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonCategoryRepository : ICategoryRepository
{
    private const string FileName = "categories.json";
    private readonly JsonStorageService _storage;

    public JsonCategoryRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Category>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Category>(FileName);
    }

    public async Task<List<Category>> GetOrSeedDefaultsAsync()
    {
        var categories = await _storage.ReadJsonAsync<Category>(FileName);
        if (categories.Count == 0)
        {
            categories = GetDefaultCategories();
            await _storage.WriteJsonAsync(FileName, categories);
        }
        return categories;
    }

    private static List<Category> GetDefaultCategories()
    {
        return new List<Category>
        {
            new() { Id = Guid.NewGuid(), Name = "Hrana", Icon = "restaurant", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Transport", Icon = "directions_car", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Stanovanje", Icon = "home", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Zabava", Icon = "movie", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Zdravlje", Icon = "local_hospital", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Ostalo", Icon = "category", Type = "expense" },
            new() { Id = Guid.NewGuid(), Name = "Plaća", Icon = "account_balance_wallet", Type = "income" },
            new() { Id = Guid.NewGuid(), Name = "Bonus", Icon = "star", Type = "income" },
            new() { Id = Guid.NewGuid(), Name = "Ostali prihod", Icon = "attach_money", Type = "income" }
        };
    }
}
