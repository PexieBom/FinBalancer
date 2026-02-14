using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface INotificationRequestRepository
{
    Task<NotificationRequest?> GetByTokenAsync(string token, string type);
    Task<NotificationRequest> AddAsync(NotificationRequest request);
    Task<bool> MarkAsUsedAsync(Guid id);
}
