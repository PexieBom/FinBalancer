namespace FinBalancer.Api.Repositories;

/// <summary>No-op implementacija kad koristimo JSON storage (UseMockData).</summary>
public class NullAccessTokenRepository : IAccessTokenRepository
{
    public Task<Guid?> GetUserIdByTokenAsync(string token) => Task.FromResult<Guid?>(null);
    public Task AddAsync(string token, Guid userId, DateTime expiresAt) => Task.CompletedTask;
    public Task RemoveAsync(string token) => Task.CompletedTask;
}
