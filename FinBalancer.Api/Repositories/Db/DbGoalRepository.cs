using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbGoalRepository : IGoalRepository
{
    private readonly FinBalancerDbContext _db;

    public DbGoalRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<Goal>> GetAllAsync()
    {
        var entities = await _db.Goals.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Goal>> GetAllByUserIdAsync(Guid userId)
    {
        var entities = await _db.Goals.Where(g => g.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<Goal?> GetByIdAsync(Guid id)
    {
        var e = await _db.Goals.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<Goal?> GetByIdAndUserIdAsync(Guid id, Guid userId)
    {
        var e = await _db.Goals.FirstOrDefaultAsync(g => g.Id == id && g.UserId == userId);
        return e == null ? null : ToModel(e);
    }

    public async Task<Goal> AddAsync(Goal goal)
    {
        var e = ToEntity(goal);
        _db.Goals.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(Goal goal)
    {
        var e = await _db.Goals.FindAsync(goal.Id);
        if (e == null) return false;
        e.Name = goal.Name;
        e.TargetAmount = goal.TargetAmount;
        e.CurrentAmount = goal.CurrentAmount;
        e.Deadline = goal.Deadline;
        e.Icon = goal.Icon;
        e.Type = goal.Type;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var e = await _db.Goals.FindAsync(id);
        if (e == null) return false;
        _db.Goals.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    private static Goal ToModel(GoalEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Name = e.Name,
        TargetAmount = e.TargetAmount,
        CurrentAmount = e.CurrentAmount,
        Deadline = e.Deadline,
        Icon = e.Icon,
        Type = e.Type,
        CreatedAt = e.CreatedAt
    };

    private static GoalEntity ToEntity(Goal m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Name = m.Name,
        TargetAmount = m.TargetAmount,
        CurrentAmount = m.CurrentAmount,
        Deadline = m.Deadline,
        Icon = m.Icon,
        Type = m.Type,
        CreatedAt = m.CreatedAt
    };
}
