using FinBalancer.Api.Data;

namespace FinBalancer.Api.Repositories;

public interface IUserEntitlementRepository
{
    Task<UserEntitlementEntity?> GetByUserIdAsync(Guid userId);
    Task<UserEntitlementEntity> UpsertAsync(UserEntitlementEntity entity);
}
