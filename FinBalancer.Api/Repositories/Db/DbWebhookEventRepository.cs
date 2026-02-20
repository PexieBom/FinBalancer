using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbWebhookEventRepository : IWebhookEventRepository
{
    private readonly FinBalancerDbContext _db;

    public DbWebhookEventRepository(FinBalancerDbContext db) => _db = db;

    public async Task<WebhookEventEntity?> GetByProviderAndEventIdAsync(string provider, string eventId)
    {
        return await _db.WebhookEvents
            .FirstOrDefaultAsync(e => e.Provider == provider && e.EventId == eventId);
    }

    public async Task<bool> ExistsAsync(string provider, string eventId)
    {
        return await _db.WebhookEvents
            .AnyAsync(e => e.Provider == provider && e.EventId == eventId);
    }

    public async Task<WebhookEventEntity> AddAsync(WebhookEventEntity entity)
    {
        entity.Id = Guid.NewGuid();
        entity.ProcessedAt = DateTime.UtcNow;
        _db.WebhookEvents.Add(entity);
        await _db.SaveChangesAsync();
        return entity;
    }
}
