using FinBalancer.Api.Data;

namespace FinBalancer.Api.Repositories;

public interface ISubscriptionPurchaseRepository
{
    Task<SubscriptionPurchaseEntity?> GetByIdAsync(Guid id);
    Task<SubscriptionPurchaseEntity?> GetByPlatformAndExternalIdAsync(string platform, string externalId);
    Task<List<SubscriptionPurchaseEntity>> GetByUserIdAsync(Guid userId);
    Task<List<SubscriptionPurchaseEntity>> GetActiveByUserIdAsync(Guid userId);
    Task<List<SubscriptionPurchaseEntity>> GetActiveAndGraceForReconciliationAsync();
    Task<SubscriptionPurchaseEntity> AddAsync(SubscriptionPurchaseEntity entity);
    Task<bool> UpdateAsync(SubscriptionPurchaseEntity entity);
}
