using System.Text.Json;
using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbCategoryRepository : ICategoryRepository
{
    private readonly FinBalancerDbContext _db;

    public DbCategoryRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<Category>> GetAllAsync()
    {
        var entities = await _db.Categories.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Category>> GetOrSeedDefaultsAsync()
    {
        var entities = await _db.Categories.ToListAsync();
        if (entities.Count == 0)
        {
            var defaults = GetDefaultCategories();
            foreach (var c in defaults)
            {
                var e = ToEntity(c);
                _db.Categories.Add(e);
            }
            await _db.SaveChangesAsync();
            entities = await _db.Categories.ToListAsync();
        }
        return entities.Select(ToModel).ToList();
    }

    private static Category ToModel(CategoryEntity e)
    {
        Dictionary<string, string>? translations = null;
        if (!string.IsNullOrEmpty(e.Translations))
        {
            try
            {
                translations = JsonSerializer.Deserialize<Dictionary<string, string>>(e.Translations);
            }
            catch { /* ignore */ }
        }
        return new Category
        {
            Id = e.Id,
            Name = e.Name,
            Translations = translations,
            Icon = e.Icon,
            Type = e.Type
        };
    }

    private static CategoryEntity ToEntity(Category m) => new()
    {
        Id = m.Id,
        Name = m.Name,
        Translations = m.Translations != null ? JsonSerializer.Serialize(m.Translations) : null,
        Icon = m.Icon ?? "",
        Type = m.Type ?? "expense"
    };

    private static List<Category> GetDefaultCategories()
    {
        return new List<Category>
        {
            new() { Id = Guid.NewGuid(), Name = "Hrana", Icon = "restaurant", Type = "expense", Translations = new() { ["en"] = "Food", ["hr"] = "Hrana", ["de"] = "Essen" } },
            new() { Id = Guid.NewGuid(), Name = "Transport", Icon = "directions_car", Type = "expense", Translations = new() { ["en"] = "Transport", ["hr"] = "Transport", ["de"] = "Transport" } },
            new() { Id = Guid.NewGuid(), Name = "Stanovanje", Icon = "home", Type = "expense", Translations = new() { ["en"] = "Housing", ["hr"] = "Stanovanje", ["de"] = "Wohnen" } },
            new() { Id = Guid.NewGuid(), Name = "Zabava", Icon = "movie", Type = "expense", Translations = new() { ["en"] = "Entertainment", ["hr"] = "Zabava", ["de"] = "Unterhaltung" } },
            new() { Id = Guid.NewGuid(), Name = "Zdravlje", Icon = "local_hospital", Type = "expense", Translations = new() { ["en"] = "Health", ["hr"] = "Zdravlje", ["de"] = "Gesundheit" } },
            new() { Id = Guid.NewGuid(), Name = "Ostalo", Icon = "category", Type = "expense", Translations = new() { ["en"] = "Other", ["hr"] = "Ostalo", ["de"] = "Sonstiges" } },
            new() { Id = Guid.NewGuid(), Name = "Plaća", Icon = "account_balance_wallet", Type = "income", Translations = new() { ["en"] = "Salary", ["hr"] = "Plaća", ["de"] = "Gehalt" } },
            new() { Id = Guid.NewGuid(), Name = "Bonus", Icon = "star", Type = "income", Translations = new() { ["en"] = "Bonus", ["hr"] = "Bonus", ["de"] = "Bonus" } },
            new() { Id = Guid.NewGuid(), Name = "Ostali prihod", Icon = "attach_money", Type = "income", Translations = new() { ["en"] = "Other income", ["hr"] = "Ostali prihod", ["de"] = "Sonstige Einnahmen" } }
        };
    }
}
