using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbSubcategoryRepository : ISubcategoryRepository
{
    private readonly FinBalancerDbContext _db;

    public DbSubcategoryRepository(FinBalancerDbContext db) => _db = db;

    public async Task<List<Subcategory>> GetByCategoryAsync(Guid categoryId)
    {
        var entities = await _db.Subcategories.Where(s => s.CategoryId == categoryId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Subcategory>> GetAllAsync()
    {
        var entities = await _db.Subcategories.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<Subcategory> AddAsync(Subcategory subcategory)
    {
        var e = ToEntity(subcategory);
        _db.Subcategories.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    private static Subcategory ToModel(SubcategoryEntity e) => new()
    {
        Id = e.Id,
        CategoryId = e.CategoryId,
        Name = e.Name
    };

    private static SubcategoryEntity ToEntity(Subcategory m) => new()
    {
        Id = m.Id,
        CategoryId = m.CategoryId,
        Name = m.Name
    };
}
