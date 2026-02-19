using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbInAppNotificationRepository : IInAppNotificationRepository
{
    private readonly FinBalancerDbContext _db;

    public DbInAppNotificationRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<InAppNotification>> GetByUserIdAsync(Guid userId, int limit = 50)
    {
        var entities = await _db.InAppNotifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(limit)
            .ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<int> GetUnreadCountAsync(Guid userId)
    {
        return await _db.InAppNotifications.CountAsync(n => n.UserId == userId && !n.IsRead);
    }

    public async Task<InAppNotification?> GetByIdAsync(Guid id)
    {
        var e = await _db.InAppNotifications.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<InAppNotification> AddAsync(InAppNotification notification)
    {
        var e = ToEntity(notification);
        _db.InAppNotifications.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task MarkAsReadAsync(Guid id)
    {
        var e = await _db.InAppNotifications.FindAsync(id);
        if (e != null)
        {
            e.IsRead = true;
            await _db.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsReadAsync(Guid userId)
    {
        var entities = await _db.InAppNotifications.Where(n => n.UserId == userId && !n.IsRead).ToListAsync();
        foreach (var e in entities) e.IsRead = true;
        await _db.SaveChangesAsync();
    }

    private static InAppNotification ToModel(InAppNotificationEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Type = e.Type,
        Title = e.Title,
        Body = e.Body,
        IsRead = e.IsRead,
        CreatedAt = e.CreatedAt,
        RelatedId = e.RelatedId,
        ActionRoute = e.ActionRoute
    };

    private static InAppNotificationEntity ToEntity(InAppNotification m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Type = m.Type,
        Title = m.Title,
        Body = m.Body,
        IsRead = m.IsRead,
        CreatedAt = m.CreatedAt,
        RelatedId = m.RelatedId,
        ActionRoute = m.ActionRoute
    };
}
