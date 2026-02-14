using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IRefreshTokenRepository
{
    Task<RefreshTokenStore?> GetByTokenAsync(string token);
    Task AddAsync(RefreshTokenStore refreshToken);
    Task RemoveAsync(string token);
}
