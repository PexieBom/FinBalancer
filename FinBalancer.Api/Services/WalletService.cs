using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class WalletService
{
    private readonly IWalletRepository _walletRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;
    private readonly SubscriptionService _subscriptionService;

    private const int FreeWalletLimit = 1;

    public WalletService(
        IWalletRepository walletRepository,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService,
        SubscriptionService subscriptionService)
    {
        _walletRepository = walletRepository;
        _currentUser = currentUser;
        _accountLinkService = accountLinkService;
        _subscriptionService = subscriptionService;
    }

    public async Task<Guid?> ResolveEffectiveUserIdForReadAsync(Guid? viewAsHostId)
    {
        var current = _currentUser.UserId;
        if (!current.HasValue) return null;
        if (!viewAsHostId.HasValue) return current;
        if (viewAsHostId.Value == current.Value) return current;
        var canView = await _accountLinkService.CanGuestViewHostAsync(current.Value, viewAsHostId.Value);
        return canView ? viewAsHostId : null;
    }

    public async Task<List<Wallet>> GetWalletsAsync(Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
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

    public async Task<Wallet?> GetByIdAsync(Guid id, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;
        return await _walletRepository.GetByIdAndUserIdAsync(id, userId.Value);
    }

    public async Task<AddWalletResult> AddWalletAsync(Wallet wallet)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return AddWalletResult.Unauthorized();

        var status = await _subscriptionService.GetStatusAsync(userId.Value);
        var existing = await _walletRepository.GetAllByUserIdAsync(userId.Value);
        if (!status.IsPremium && existing.Count >= FreeWalletLimit)
            return AddWalletResult.WalletLimitExceeded();

        wallet.Id = Guid.NewGuid();
        wallet.UserId = userId.Value;
        wallet.IsMain = existing.Count == 0;
        await _walletRepository.AddAsync(wallet);
        return AddWalletResult.Ok(wallet);
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

public class AddWalletResult
{
    public bool Success { get; init; }
    public Wallet? Wallet { get; init; }
    public string? ErrorCode { get; init; }

    public static AddWalletResult Ok(Wallet w) => new() { Success = true, Wallet = w };
    public static AddWalletResult Unauthorized() => new() { Success = false, ErrorCode = "Unauthorized" };
    public static AddWalletResult WalletLimitExceeded() => new() { Success = false, ErrorCode = "WalletLimitExceeded" };
}
