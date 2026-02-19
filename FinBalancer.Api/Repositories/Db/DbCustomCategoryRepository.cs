using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbCustomCategoryRepository : ICustomCategoryRepository
{
    private readonly FinBalancerDbContext _db;

    public DbCustomCategoryRepository(FinBalancerDbContext db) => _db = db;

    public async Task<List<CustomCategory>> GetByUserIdAsync(Guid userId)
    {
        var entities = await _db.CustomCategories.Where(c => c.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<CustomCategory> AddAsync(CustomCategory category)
    {
        var e = ToEntity(category);
        _db.CustomCategories.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> DeleteAsync(Guid id, Guid userId)
    {
        var e = await _db.CustomCategories.FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId);
        if (e == null) return false;
        _db.CustomCategories.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    private static CustomCategory ToModel(CustomCategoryEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Name = e.Name,
        Type = e.Type,
        Icon = e.Icon
    };

    private static CustomCategoryEntity ToEntity(CustomCategory m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Name = m.Name,
        Type = m.Type,
        Icon = m.Icon
    };
}
