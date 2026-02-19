using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbWalletRepository : IWalletRepository
{
    private readonly FinBalancerDbContext _db;

    public DbWalletRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<Wallet>> GetAllAsync()
    {
        var entities = await _db.Wallets.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Wallet>> GetAllByUserIdAsync(Guid userId)
    {
        var entities = await _db.Wallets.Where(w => w.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<Wallet?> GetByIdAsync(Guid id)
    {
        var e = await _db.Wallets.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<Wallet?> GetByIdAndUserIdAsync(Guid id, Guid userId)
    {
        var e = await _db.Wallets.FirstOrDefaultAsync(w => w.Id == id && w.UserId == userId);
        return e == null ? null : ToModel(e);
    }

    public async Task<Wallet> AddAsync(Wallet wallet)
    {
        var e = ToEntity(wallet);
        _db.Wallets.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(Wallet wallet)
    {
        var e = await _db.Wallets.FindAsync(wallet.Id);
        if (e == null) return false;
        e.Name = wallet.Name;
        e.Balance = wallet.Balance;
        e.Currency = wallet.Currency;
        e.IsMain = wallet.IsMain;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var e = await _db.Wallets.FindAsync(id);
        if (e == null) return false;
        _db.Wallets.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    private static Wallet ToModel(WalletEntity e) => new()
    {
        Id = e.Id,
        UserId = e.UserId,
        Name = e.Name,
        Balance = e.Balance,
        Currency = e.Currency,
        IsMain = e.IsMain
    };

    private static WalletEntity ToEntity(Wallet m) => new()
    {
        Id = m.Id,
        UserId = m.UserId,
        Name = m.Name,
        Balance = m.Balance,
        Currency = m.Currency,
        IsMain = m.IsMain
    };
}
