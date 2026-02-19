namespace FinBalancer.Api.Repositories;

public interface IAccessTokenRepository
{
    Task<Guid?> GetUserIdByTokenAsync(string token);
    Task AddAsync(string token, Guid userId, DateTime expiresAt);
    Task RemoveAsync(string token);
}
