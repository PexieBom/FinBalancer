using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbUserEntitlementRepository : IUserEntitlementRepository
{
    private readonly FinBalancerDbContext _db;

    public DbUserEntitlementRepository(FinBalancerDbContext db) => _db = db;

    public async Task<UserEntitlementEntity?> GetByUserIdAsync(Guid userId)
    {
        return await _db.UserEntitlements.FindAsync(userId);
    }

    public async Task<UserEntitlementEntity> UpsertAsync(UserEntitlementEntity entity)
    {
        entity.UpdatedAt = DateTime.UtcNow;
        var existing = await _db.UserEntitlements.FindAsync(entity.UserId);
        if (existing != null)
        {
            existing.IsPremium = entity.IsPremium;
            existing.PremiumUntil = entity.PremiumUntil;
            existing.SourcePlatform = entity.SourcePlatform;
            existing.UpdatedAt = entity.UpdatedAt;
            await _db.SaveChangesAsync();
            return existing;
        }
        _db.UserEntitlements.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }
}
