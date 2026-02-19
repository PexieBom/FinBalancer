using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbUserRepository : IUserRepository
{
    private readonly FinBalancerDbContext _db;

    public DbUserRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<User?> GetFirstOrDefaultAsync()
    {
        var e = await _db.Users.OrderBy(u => u.CreatedAt).FirstOrDefaultAsync();
        return e == null ? null : ToModel(e);
    }

    public async Task<User?> GetByIdAsync(Guid id)
    {
        var e = await _db.Users.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        var e = await _db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email.Trim().ToLower());
        return e == null ? null : ToModel(e);
    }

    public async Task<User?> GetByGoogleIdAsync(string googleId)
    {
        var e = await _db.Users.FirstOrDefaultAsync(u => u.GoogleId == googleId);
        return e == null ? null : ToModel(e);
    }

    public async Task<User?> GetByAppleIdAsync(string appleId)
    {
        var e = await _db.Users.FirstOrDefaultAsync(u => u.AppleId == appleId);
        return e == null ? null : ToModel(e);
    }

    public async Task<User> AddAsync(User user)
    {
        var e = ToEntity(user);
        _db.Users.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(User user)
    {
        var e = await _db.Users.FindAsync(user.Id);
        if (e == null) return false;
        e.Email = user.Email;
        e.PasswordHash = user.PasswordHash;
        e.DisplayName = user.DisplayName;
        e.GoogleId = user.GoogleId;
        e.AppleId = user.AppleId;
        e.EmailVerified = user.EmailVerified;
        e.LastLoginAt = user.LastLoginAt;
        await _db.SaveChangesAsync();
        return true;
    }

    private static User ToModel(UserEntity e) => new()
    {
        Id = e.Id,
        Email = e.Email,
        PasswordHash = e.PasswordHash,
        DisplayName = e.DisplayName,
        GoogleId = e.GoogleId,
        AppleId = e.AppleId,
        EmailVerified = e.EmailVerified,
        CreatedAt = e.CreatedAt,
        LastLoginAt = e.LastLoginAt
    };

    private static UserEntity ToEntity(User m) => new()
    {
        Id = m.Id,
        Email = m.Email,
        PasswordHash = m.PasswordHash,
        DisplayName = m.DisplayName,
        GoogleId = m.GoogleId,
        AppleId = m.AppleId,
        EmailVerified = m.EmailVerified,
        CreatedAt = m.CreatedAt,
        LastLoginAt = m.LastLoginAt
    };
}
