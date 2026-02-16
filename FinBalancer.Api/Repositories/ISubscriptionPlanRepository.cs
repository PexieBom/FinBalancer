using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ISubscriptionPlanRepository
{
    Task<List<SubscriptionPlan>> GetAllAsync();
    Task<SubscriptionPlan?> GetByProductIdAsync(string productId);
    Task<SubscriptionPlan?> GetByPlatformProductIdAsync(string platform, string platformProductId);
}
