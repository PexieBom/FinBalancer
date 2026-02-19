using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbProjectRepository : IProjectRepository
{
    private readonly FinBalancerDbContext _db;

    public DbProjectRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<Project>> GetAllAsync()
    {
        var entities = await _db.Projects.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Project>> GetAllByUserIdAsync(Guid userId)
    {
        var entities = await _db.Projects.Where(p => p.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<Project?> GetByIdAsync(Guid id)
    {
        var e = await _db.Projects.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<Project?> GetByIdAndUserIdAsync(Guid id, Guid userId)
    {
        var e = await _db.Projects.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);
        return e == null ? null : ToModel(e);
    }

    public async Task<Project> AddAsync(Project project)
    {
        var e = ToEntity(project);
        _db.Projects.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(Project project)
    {
        var e = await _db.Projects.FindAsync(project.Id);
        if (e == null) return false;
        e.Name = project.Name;
        e.Description = project.Description;
        e.Color = project.Color;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var e = await _db.Projects.FindAsync(id);
        if (e == null) return false;
        _db.Projects.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    private static Project ToModel(ProjectEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Name = e.Name,
        Description = e.Description,
        Color = e.Color,
        CreatedAt = e.CreatedAt
    };

    private static ProjectEntity ToEntity(Project m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Name = m.Name,
        Description = m.Description,
        Color = m.Color,
        CreatedAt = m.CreatedAt
    };
}
