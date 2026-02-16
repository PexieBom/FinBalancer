using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class WalletService
{
    private readonly IWalletRepository _walletRepository;
    private readonly ICurrentUserService _currentUser;

    public WalletService(IWalletRepository walletRepository, ICurrentUserService currentUser)
    {
        _walletRepository = walletRepository;
        _currentUser = currentUser;
    }

    public async Task<List<Wallet>> GetWalletsAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return new List<Wallet>();
        var list = await _walletRepository.GetAllByUserIdAsync(userId.Value);
        var hasMain = list.Any(w => w.IsMain);
        if (!hasMain && list.Count > 0)
        {
            list[0].IsMain = true;
            await _walletRepository.UpdateAsync(list[0]);
        }
        return list;
    }

    public async Task<Wallet?> GetByIdAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;
        return await _walletRepository.GetByIdAndUserIdAsync(id, userId.Value);
    }

    public async Task<Wallet?> AddWalletAsync(Wallet wallet)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        var existing = await _walletRepository.GetAllByUserIdAsync(userId.Value);
        wallet.Id = Guid.NewGuid();
        wallet.UserId = userId.Value;
        wallet.IsMain = existing.Count == 0;
        await _walletRepository.AddAsync(wallet);
        return wallet;
    }

    public async Task<Wallet?> UpdateWalletAsync(Wallet wallet)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        var existing = await _walletRepository.GetByIdAndUserIdAsync(wallet.Id, userId.Value);
        if (existing == null) return null;
        wallet.UserId = userId.Value;
        var ok = await _walletRepository.UpdateAsync(wallet);
        return ok ? wallet : null;
    }

    public async Task<bool> DeleteWalletAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;
        var existing = await _walletRepository.GetByIdAndUserIdAsync(id, userId.Value);
        if (existing == null) return false;
        var all = await _walletRepository.GetAllByUserIdAsync(userId.Value);
        var wasMain = existing.IsMain;
        var ok = await _walletRepository.DeleteAsync(id);
        if (ok && wasMain && all.Count > 1)
        {
            var remaining = all.Where(w => w.Id != id).ToList();
            var next = remaining.First();
            next.IsMain = true;
            await _walletRepository.UpdateAsync(next);
        }
        return ok;
    }

    public async Task<Wallet?> SetMainWalletAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;
        var wallet = await _walletRepository.GetByIdAndUserIdAsync(id, userId.Value);
        if (wallet == null) return null;
        var all = await _walletRepository.GetAllByUserIdAsync(userId.Value);
        foreach (var w in all)
        {
            w.IsMain = w.Id == id;
            await _walletRepository.UpdateAsync(w);
        }
        wallet.IsMain = true;
        return wallet;
    }
}
