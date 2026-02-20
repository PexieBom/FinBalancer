using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbSubscriptionPlanRepository : ISubscriptionPlanRepository
{
    private readonly FinBalancerDbContext _db;

    public DbSubscriptionPlanRepository(FinBalancerDbContext db) => _db = db;

    public async Task<List<SubscriptionPlan>> GetAllAsync()
    {
        var entities = await _db.SubscriptionPlans.Where(p => p.IsActive).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<SubscriptionPlan?> GetByProductIdAsync(string productId)
    {
        var e = await _db.SubscriptionPlans.FirstOrDefaultAsync(p => p.ProductId == productId);
        return e == null ? null : ToModel(e);
    }

    public async Task<SubscriptionPlan?> GetByPlatformProductIdAsync(string platform, string platformProductId)
    {
        var plat = platform.ToLowerInvariant();
        SubscriptionPlanEntity? e = plat == "apple"
            ? await _db.SubscriptionPlans.FirstOrDefaultAsync(p => p.AppleProductId == platformProductId)
            : plat == "google"
                ? await _db.SubscriptionPlans.FirstOrDefaultAsync(p => p.GoogleProductId == platformProductId)
                : plat == "paypal"
                    ? await _db.SubscriptionPlans.FirstOrDefaultAsync(p => p.PayPalPlanId == platformProductId)
                    : null;
        return e == null ? null : ToModel(e);
    }

    private static SubscriptionPlan ToModel(SubscriptionPlanEntity e) => new()
    {
        Id = e.Id,
        Name = e.Name,
        ProductId = e.ProductId,
        AppleProductId = e.AppleProductId,
        GoogleProductId = e.GoogleProductId,
        PayPalPlanId = e.PayPalPlanId,
        Duration = e.Duration,
        Price = e.Price,
        Currency = e.Currency,
        IsActive = e.IsActive
    };
}
