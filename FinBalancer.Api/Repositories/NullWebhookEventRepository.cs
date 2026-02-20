using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories;

/// <summary>
/// Stub implementation for mock storage mode - no DB available.
/// </summary>
public class NullWebhookEventRepository : IWebhookEventRepository
{
    public Task<WebhookEventEntity?> GetByProviderAndEventIdAsync(string provider, string eventId) => Task.FromResult<WebhookEventEntity?>(null);
    public Task<bool> ExistsAsync(string provider, string eventId) => Task.FromResult(false);
    public Task<WebhookEventEntity> AddAsync(WebhookEventEntity entity) => Task.FromResult(entity);
}
