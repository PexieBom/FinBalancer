using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IInAppNotificationRepository
{
    Task<List<InAppNotification>> GetByUserIdAsync(Guid userId, int limit = 50);
    Task<int> GetUnreadCountAsync(Guid userId);
    Task<InAppNotification?> GetByIdAsync(Guid id);
    Task<InAppNotification> AddAsync(InAppNotification notification);
    Task MarkAsReadAsync(Guid id);
    Task MarkAllAsReadAsync(Guid userId);
}
