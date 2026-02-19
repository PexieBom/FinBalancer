using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbAccessTokenRepository : IAccessTokenRepository
{
    private readonly FinBalancerDbContext _db;

    public DbAccessTokenRepository(FinBalancerDbContext db) => _db = db;

    public async Task<Guid?> GetUserIdByTokenAsync(string token)
    {
        var e = await _db.AccessTokens
            .Where(t => t.Token == token && t.ExpiresAt > DateTime.UtcNow)
            .Select(t => t.UserId)
            .FirstOrDefaultAsync();
        return e != default ? e : null;
    }

    public async Task AddAsync(string token, Guid userId, DateTime expiresAt)
    {
        _db.AccessTokens.Add(new AccessTokenEntity
        {
            Token = token,
            UserId = userId,
            ExpiresAt = expiresAt,
            CreatedAt = DateTime.UtcNow
        });
        await _db.SaveChangesAsync();
    }

    public async Task RemoveAsync(string token)
    {
        var e = await _db.AccessTokens.FirstOrDefaultAsync(t => t.Token == token);
        if (e != null)
        {
            _db.AccessTokens.Remove(e);
            await _db.SaveChangesAsync();
        }
    }
}
