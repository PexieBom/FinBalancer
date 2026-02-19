using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbNotificationRequestRepository : INotificationRequestRepository
{
    private readonly FinBalancerDbContext _db;

    public DbNotificationRequestRepository(FinBalancerDbContext db) => _db = db;

    public async Task<NotificationRequest?> GetByTokenAsync(string token, string type)
    {
        var e = await _db.NotificationRequests.FirstOrDefaultAsync(r => r.Token == token && r.Type == type);
        return e == null ? null : ToModel(e);
    }

    public async Task<NotificationRequest> AddAsync(NotificationRequest request)
    {
        var e = ToEntity(request);
        _db.NotificationRequests.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> MarkAsUsedAsync(Guid id)
    {
        var e = await _db.NotificationRequests.FindAsync(id);
        if (e == null) return false;
        e.UsedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return true;
    }

    private static NotificationRequest ToModel(NotificationRequestEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Type = e.Type,
        Token = e.Token,
        ExpiresAt = e.ExpiresAt,
        CreatedAt = e.CreatedAt,
        UsedAt = e.UsedAt
    };

    private static NotificationRequestEntity ToEntity(NotificationRequest m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Type = m.Type,
        Token = m.Token,
        ExpiresAt = m.ExpiresAt,
        CreatedAt = m.CreatedAt,
        UsedAt = m.UsedAt
    };
}
