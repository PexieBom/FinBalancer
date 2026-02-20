using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbDeviceTokenRepository : IDeviceTokenRepository
{
    private readonly FinBalancerDbContext _db;

    public DbDeviceTokenRepository(FinBalancerDbContext db) => _db = db;

    public async Task RegisterAsync(Guid userId, string token, string platform)
    {
        var existing = await _db.DeviceTokens
            .FirstOrDefaultAsync(t => t.UserId == userId && t.Token == token);
        var now = DateTime.UtcNow;

        if (existing != null)
        {
            existing.Platform = platform;
            existing.UpdatedAt = now;
        }
        else
        {
            _db.DeviceTokens.Add(new DeviceTokenEntity
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Token = token,
                Platform = platform,
                CreatedAt = now,
                UpdatedAt = now
            });
        }
        await _db.SaveChangesAsync();
    }

    public async Task<List<string>> GetTokensForUserAsync(Guid userId)
    {
        return await _db.DeviceTokens
            .Where(t => t.UserId == userId)
            .Select(t => t.Token)
            .ToListAsync();
    }

    public async Task RemoveByTokenAsync(string token)
    {
        var e = await _db.DeviceTokens.FirstOrDefaultAsync(t => t.Token == token);
        if (e != null)
        {
            _db.DeviceTokens.Remove(e);
            await _db.SaveChangesAsync();
        }
    }
}
