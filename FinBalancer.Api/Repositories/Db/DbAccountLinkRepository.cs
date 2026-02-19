using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbAccountLinkRepository : IAccountLinkRepository
{
    private readonly FinBalancerDbContext _db;

    public DbAccountLinkRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<AccountLink?> GetByIdAsync(Guid id)
    {
        var e = await _db.AccountLinks.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<List<AccountLink>> GetByHostUserIdAsync(Guid hostUserId)
    {
        var entities = await _db.AccountLinks.Where(l => l.HostUserId == hostUserId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<AccountLink>> GetByGuestUserIdAsync(Guid guestUserId)
    {
        var entities = await _db.AccountLinks.Where(l => l.GuestUserId == guestUserId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<AccountLink>> GetAcceptedByGuestUserIdAsync(Guid guestUserId)
    {
        var entities = await _db.AccountLinks.Where(l => l.GuestUserId == guestUserId && l.Status == (int)AccountLinkStatus.Accepted).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<AccountLink?> GetByHostAndGuestAsync(Guid hostUserId, Guid guestUserId)
    {
        var e = await _db.AccountLinks.FirstOrDefaultAsync(l => l.HostUserId == hostUserId && l.GuestUserId == guestUserId);
        return e == null ? null : ToModel(e);
    }

    public async Task<AccountLink> AddAsync(AccountLink link)
    {
        var e = ToEntity(link);
        _db.AccountLinks.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(AccountLink link)
    {
        var e = await _db.AccountLinks.FindAsync(link.Id);
        if (e == null) return false;
        e.Status = (int)link.Status;
        e.RespondedAt = link.RespondedAt;
        await _db.SaveChangesAsync();
        return true;
    }

    private static AccountLink ToModel(AccountLinkEntity e) => new()
    {
        Id = e.Id,
        HostUserId = e.HostUserId,
        GuestUserId = e.GuestUserId,
        Status = (AccountLinkStatus)e.Status,
        InvitedAt = e.InvitedAt,
        RespondedAt = e.RespondedAt
    };

    private static AccountLinkEntity ToEntity(AccountLink m) => new()
    {
        Id = m.Id,
        HostUserId = m.HostUserId,
        GuestUserId = m.GuestUserId,
        Status = (int)m.Status,
        InvitedAt = m.InvitedAt,
        RespondedAt = m.RespondedAt
    };
}
