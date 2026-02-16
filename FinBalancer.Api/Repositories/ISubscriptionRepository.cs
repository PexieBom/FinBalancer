using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ISubscriptionRepository
{
    Task<UserSubscription?> GetActiveByUserIdAsync(Guid userId);
    Task<List<UserSubscription>> GetByUserIdAsync(Guid userId);
    Task<UserSubscription?> GetByPurchaseTokenAsync(string platform, string purchaseToken);
    Task<UserSubscription> AddAsync(UserSubscription subscription);
    Task<bool> UpdateAsync(UserSubscription subscription);
}
