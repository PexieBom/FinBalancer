using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbSubscriptionPurchaseRepository : ISubscriptionPurchaseRepository
{
    private readonly FinBalancerDbContext _db;

    public DbSubscriptionPurchaseRepository(FinBalancerDbContext db) => _db = db;

    public async Task<SubscriptionPurchaseEntity?> GetByIdAsync(Guid id)
    {
        return await _db.SubscriptionPurchases.FindAsync(id);
    }

    public async Task<SubscriptionPurchaseEntity?> GetByPlatformAndExternalIdAsync(string platform, string externalId)
    {
        return await _db.SubscriptionPurchases
            .FirstOrDefaultAsync(p => p.Platform == platform && p.ExternalId == externalId);
    }

    public async Task<List<SubscriptionPurchaseEntity>> GetByUserIdAsync(Guid userId)
    {
        return await _db.SubscriptionPurchases
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.StartTime)
            .ToListAsync();
    }

    public async Task<List<SubscriptionPurchaseEntity>> GetActiveByUserIdAsync(Guid userId)
    {
        var now = DateTime.UtcNow;
        return await _db.SubscriptionPurchases
            .Where(p => p.UserId == userId
                && (p.Status == "active" || p.Status == "grace")
                && (p.EndTime == null || p.EndTime > now))
            .OrderByDescending(p => p.EndTime ?? p.StartTime)
            .ToListAsync();
    }

    public async Task<List<SubscriptionPurchaseEntity>> GetActiveAndGraceForReconciliationAsync()
    {
        return await _db.SubscriptionPurchases
            .Where(p => p.Status == "active" || p.Status == "grace")
            .ToListAsync();
    }

    public async Task<SubscriptionPurchaseEntity> AddAsync(SubscriptionPurchaseEntity entity)
    {
        entity.Id = Guid.NewGuid();
        entity.CreatedAt = DateTime.UtcNow;
        entity.UpdatedAt = DateTime.UtcNow;
        _db.SubscriptionPurchases.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }

    public async Task<bool> UpdateAsync(SubscriptionPurchaseEntity entity)
    {
        var existing = await _db.SubscriptionPurchases.FindAsync(entity.Id);
        if (existing == null) return false;
        existing.Status = entity.Status;
        existing.EndTime = entity.EndTime;
        existing.RawPayload = entity.RawPayload;
        existing.AutoRenew = entity.AutoRenew;
        existing.CancelReason = entity.CancelReason;
        existing.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return true;
    }
}
