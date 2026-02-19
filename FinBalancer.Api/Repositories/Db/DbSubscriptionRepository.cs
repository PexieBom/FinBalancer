using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbSubscriptionRepository : ISubscriptionRepository
{
    private readonly FinBalancerDbContext _db;

    public DbSubscriptionRepository(FinBalancerDbContext db) => _db = db;

    public async Task<UserSubscription?> GetActiveByUserIdAsync(Guid userId)
    {
        var now = DateTime.UtcNow;
        var e = await _db.UserSubscriptions
            .Where(s => s.UserId == userId && s.Status == "active" && s.ExpiresAt > now)
            .OrderByDescending(s => s.ExpiresAt)
            .FirstOrDefaultAsync();
        return e == null ? null : ToModel(e);
    }

    public async Task<List<UserSubscription>> GetByUserIdAsync(Guid userId)
    {
        var entities = await _db.UserSubscriptions.Where(s => s.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<UserSubscription?> GetByPurchaseTokenAsync(string platform, string purchaseToken)
    {
        var e = await _db.UserSubscriptions.FirstOrDefaultAsync(s => s.Platform == platform && s.PurchaseToken == purchaseToken);
        return e == null ? null : ToModel(e);
    }

    public async Task<UserSubscription> AddAsync(UserSubscription subscription)
    {
        var e = ToEntity(subscription);
        _db.UserSubscriptions.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(UserSubscription subscription)
    {
        var e = await _db.UserSubscriptions.FindAsync(subscription.Id);
        if (e == null) return false;
        e.Status = subscription.Status;
        e.ExpiresAt = subscription.ExpiresAt;
        e.CancelledAt = subscription.CancelledAt;
        e.UpdatedAt = subscription.UpdatedAt;
        e.ReceiptData = subscription.ReceiptData;
        e.OrderId = subscription.OrderId;
        await _db.SaveChangesAsync();
        return true;
    }

    private static UserSubscription ToModel(UserSubscriptionEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Platform = e.Platform,
        ProductId = e.ProductId,
        PurchaseToken = e.PurchaseToken,
        Status = e.Status,
        ExpiresAt = e.ExpiresAt,
        CancelledAt = e.CancelledAt,
        CreatedAt = e.CreatedAt,
        UpdatedAt = e.UpdatedAt,
        ReceiptData = e.ReceiptData,
        OrderId = e.OrderId
    };

    private static UserSubscriptionEntity ToEntity(UserSubscription m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Platform = m.Platform,
        ProductId = m.ProductId,
        PurchaseToken = m.PurchaseToken,
        Status = m.Status,
        ExpiresAt = m.ExpiresAt,
        CancelledAt = m.CancelledAt,
        CreatedAt = m.CreatedAt,
        UpdatedAt = m.UpdatedAt,
        ReceiptData = m.ReceiptData,
        OrderId = m.OrderId
    };
}
