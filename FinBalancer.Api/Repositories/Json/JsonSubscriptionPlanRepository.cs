using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonSubscriptionPlanRepository : ISubscriptionPlanRepository
{
    private const string FileName = "subscription_plans.json";
    private readonly JsonStorageService _storage;

    public JsonSubscriptionPlanRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<SubscriptionPlan>> GetAllAsync()
    {
        var list = await _storage.ReadJsonAsync<SubscriptionPlan>(FileName);
        if (list.Count == 0)
        {
            list = GetDefaultPlans();
            await _storage.WriteJsonAsync(FileName, list);
        }
        return list.Where(p => p.IsActive).ToList();
    }

    public async Task<SubscriptionPlan?> GetByProductIdAsync(string productId)
    {
        var list = await GetAllAsync();
        return list.FirstOrDefault(p =>
            p.ProductId == productId ||
            p.AppleProductId == productId ||
            p.GoogleProductId == productId);
    }

    public async Task<SubscriptionPlan?> GetByPlatformProductIdAsync(string platform, string platformProductId)
    {
        var list = await GetAllAsync();
        return platform.Equals("apple", StringComparison.OrdinalIgnoreCase)
            ? list.FirstOrDefault(p => p.AppleProductId == platformProductId || p.ProductId == platformProductId)
            : list.FirstOrDefault(p => p.GoogleProductId == platformProductId || p.ProductId == platformProductId);
    }

    private static List<SubscriptionPlan> GetDefaultPlans()
    {
        return new List<SubscriptionPlan>
        {
            new()
            {
                Id = Guid.NewGuid(),
                Name = "Premium Monthly",
                ProductId = "finbalancer_premium_monthly",
                AppleProductId = "finbalancer_premium_monthly",
                GoogleProductId = "finbalancer_premium_monthly",
                Duration = "monthly",
                Price = 4.99m,
                Currency = "EUR",
                IsActive = true
            },
            new()
            {
                Id = Guid.NewGuid(),
                Name = "Premium Yearly",
                ProductId = "finbalancer_premium_yearly",
                AppleProductId = "finbalancer_premium_yearly",
                GoogleProductId = "finbalancer_premium_yearly",
                Duration = "yearly",
                Price = 39.99m,
                Currency = "EUR",
                IsActive = true
            }
        };
    }
}
