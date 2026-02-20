using FinBalancer.Api.Data;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbWalletBudgetRepository : IWalletBudgetRepository
{
    private readonly FinBalancerDbContext _db;

    public DbWalletBudgetRepository(FinBalancerDbContext db) => _db = db;

    public async Task<WalletBudget?> GetByIdAsync(Guid id)
    {
        var e = await _db.WalletBudgets.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<WalletBudget?> GetByWalletIdAsync(Guid walletId)
    {
        var e = await _db.WalletBudgets.FirstOrDefaultAsync(b => b.WalletId == walletId);
        return e == null ? null : ToModel(e);
    }

    public async Task<WalletBudget?> GetByWalletIdAndUserIdAsync(Guid walletId, Guid userId)
    {
        var e = await _db.WalletBudgets.FirstOrDefaultAsync(b => b.WalletId == walletId && b.UserId == userId);
        return e == null ? null : ToModel(e);
    }

    public async Task<WalletBudget> CreateAsync(WalletBudget budget)
    {
        budget.Id = Guid.NewGuid();
        budget.CreatedAt = DateTime.UtcNow;
        budget.UpdatedAt = DateTime.UtcNow;
        var e = ToEntity(budget);
        _db.WalletBudgets.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<WalletBudget> UpdateAsync(WalletBudget budget)
    {
        var e = await _db.WalletBudgets.FindAsync(budget.Id);
        if (e == null) throw new InvalidOperationException("Budget not found");
        e.BudgetAmount = budget.BudgetAmount;
        e.PeriodStartDay = budget.PeriodStartDay;
        e.PeriodStartDate = DateTimeUtils.ToUtc(budget.PeriodStartDate);
        e.PeriodEndDate = DateTimeUtils.ToUtc(budget.PeriodEndDate);
        e.CategoryId = budget.CategoryId;
        e.IsMain = budget.IsMain;
        e.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<WalletBudget> UpsertAsync(WalletBudget budget)
    {
        var existing = await _db.WalletBudgets.FirstOrDefaultAsync(b => b.WalletId == budget.WalletId && b.UserId == budget.UserId);
        if (existing != null)
        {
            existing.BudgetAmount = budget.BudgetAmount;
            existing.PeriodStartDay = budget.PeriodStartDay;
            existing.PeriodStartDate = DateTimeUtils.ToUtc(budget.PeriodStartDate);
            existing.PeriodEndDate = DateTimeUtils.ToUtc(budget.PeriodEndDate);
            existing.CategoryId = budget.CategoryId;
            existing.IsMain = budget.IsMain;
            existing.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return ToModel(existing);
        }
        budget.Id = Guid.NewGuid();
        budget.CreatedAt = DateTime.UtcNow;
        budget.UpdatedAt = DateTime.UtcNow;
        var e = ToEntity(budget);
        _db.WalletBudgets.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> DeleteByIdAsync(Guid id)
    {
        var e = await _db.WalletBudgets.FindAsync(id);
        if (e == null) return false;
        _db.WalletBudgets.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteByWalletIdAsync(Guid walletId)
    {
        var entities = await _db.WalletBudgets.Where(b => b.WalletId == walletId).ToListAsync();
        if (entities.Count == 0) return false;
        _db.WalletBudgets.RemoveRange(entities);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<List<WalletBudget>> GetAllAsync()
    {
        var entities = await _db.WalletBudgets.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<WalletBudget>> GetAllByUserIdAsync(Guid userId)
    {
        var entities = await _db.WalletBudgets.Where(b => b.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    private static WalletBudget ToModel(WalletBudgetEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        WalletId = e.WalletId,
        BudgetAmount = e.BudgetAmount,
        PeriodStartDay = e.PeriodStartDay,
        PeriodStartDate = e.PeriodStartDate,
        PeriodEndDate = e.PeriodEndDate,
        CategoryId = e.CategoryId,
        IsMain = e.IsMain,
        CreatedAt = e.CreatedAt,
        UpdatedAt = e.UpdatedAt
    };

    private static WalletBudgetEntity ToEntity(WalletBudget m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        WalletId = m.WalletId,
        BudgetAmount = m.BudgetAmount,
        PeriodStartDay = m.PeriodStartDay,
        PeriodStartDate = DateTimeUtils.ToUtc(m.PeriodStartDate),
        PeriodEndDate = DateTimeUtils.ToUtc(m.PeriodEndDate),
        CategoryId = m.CategoryId,
        IsMain = m.IsMain,
        CreatedAt = m.CreatedAt,
        UpdatedAt = m.UpdatedAt
    };
}
