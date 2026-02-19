using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbRefreshTokenRepository : IRefreshTokenRepository
{
    private readonly FinBalancerDbContext _db;

    public DbRefreshTokenRepository(FinBalancerDbContext db) => _db = db;

    public async Task<RefreshTokenStore?> GetByTokenAsync(string token)
    {
        var e = await _db.RefreshTokens.FirstOrDefaultAsync(t => t.Token == token);
        return e == null ? null : ToModel(e);
    }

    public async Task AddAsync(RefreshTokenStore refreshToken)
    {
        var e = ToEntity(refreshToken);
        _db.RefreshTokens.Add(e);
        await _db.SaveChangesAsync();
    }

    public async Task RemoveAsync(string token)
    {
        var e = await _db.RefreshTokens.FirstOrDefaultAsync(t => t.Token == token);
        if (e != null)
        {
            _db.RefreshTokens.Remove(e);
            await _db.SaveChangesAsync();
        }
    }

    private static RefreshTokenStore ToModel(RefreshTokenEntity e) => new()
    {
        Token = e.Token,
        UserId = e.UserId,
        ExpiresAt = e.ExpiresAt,
        CreatedAt = e.CreatedAt
    };

    private static RefreshTokenEntity ToEntity(RefreshTokenStore m) => new()
    {
        Token = m.Token,
        UserId = m.UserId,
        ExpiresAt = m.ExpiresAt,
        CreatedAt = m.CreatedAt
    };
}
