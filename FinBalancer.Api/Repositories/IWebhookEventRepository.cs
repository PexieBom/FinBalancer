using FinBalancer.Api.Data;

namespace FinBalancer.Api.Repositories;

public interface IWebhookEventRepository
{
    Task<WebhookEventEntity?> GetByProviderAndEventIdAsync(string provider, string eventId);
    Task<bool> ExistsAsync(string provider, string eventId);
    Task<WebhookEventEntity> AddAsync(WebhookEventEntity entity);
}
