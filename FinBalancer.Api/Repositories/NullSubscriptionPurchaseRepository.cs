using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories;

/// <summary>
/// Stub implementation for mock storage mode - no DB available.
/// </summary>
public class NullSubscriptionPurchaseRepository : ISubscriptionPurchaseRepository
{
    public Task<SubscriptionPurchaseEntity?> GetByIdAsync(Guid id) => Task.FromResult<SubscriptionPurchaseEntity?>(null);
    public Task<SubscriptionPurchaseEntity?> GetByPlatformAndExternalIdAsync(string platform, string externalId) => Task.FromResult<SubscriptionPurchaseEntity?>(null);
    public Task<List<SubscriptionPurchaseEntity>> GetByUserIdAsync(Guid userId) => Task.FromResult(new List<SubscriptionPurchaseEntity>());
    public Task<List<SubscriptionPurchaseEntity>> GetActiveByUserIdAsync(Guid userId) => Task.FromResult(new List<SubscriptionPurchaseEntity>());
    public Task<List<SubscriptionPurchaseEntity>> GetActiveAndGraceForReconciliationAsync() => Task.FromResult(new List<SubscriptionPurchaseEntity>());
    public Task<SubscriptionPurchaseEntity> AddAsync(SubscriptionPurchaseEntity entity) => Task.FromResult(entity);
    public Task<bool> UpdateAsync(SubscriptionPurchaseEntity entity) => Task.FromResult(false);
}
