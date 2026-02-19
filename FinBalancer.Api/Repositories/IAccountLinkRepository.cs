using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IAccountLinkRepository
{
    Task<AccountLink?> GetByIdAsync(Guid id);
    Task<List<AccountLink>> GetByHostUserIdAsync(Guid hostUserId);
    Task<List<AccountLink>> GetByGuestUserIdAsync(Guid guestUserId);
    Task<List<AccountLink>> GetAcceptedByGuestUserIdAsync(Guid guestUserId);
    Task<AccountLink?> GetByHostAndGuestAsync(Guid hostUserId, Guid guestUserId);
    Task<AccountLink> AddAsync(AccountLink link);
    Task<bool> UpdateAsync(AccountLink link);
}
