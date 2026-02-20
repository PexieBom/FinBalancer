using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories;

/// <summary>
/// Stub implementation for mock storage mode - no DB available.
/// </summary>
public class NullUserEntitlementRepository : IUserEntitlementRepository
{
    public Task<UserEntitlementEntity?> GetByUserIdAsync(Guid userId) => Task.FromResult<UserEntitlementEntity?>(null);
    public Task<UserEntitlementEntity> UpsertAsync(UserEntitlementEntity entity) => Task.FromResult(entity);
}
