using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class WalletService
{
    private readonly IWalletRepository _walletRepository;

    public WalletService(IWalletRepository walletRepository)
    {
        _walletRepository = walletRepository;
    }

    public async Task<List<Wallet>> GetWalletsAsync()
    {
        return await _walletRepository.GetAllAsync();
    }

    public async Task<Wallet> AddWalletAsync(Wallet wallet)
    {
        wallet.Id = Guid.NewGuid();
        await _walletRepository.AddAsync(wallet);
        return wallet;
    }

    public async Task<Wallet?> UpdateWalletAsync(Wallet wallet)
    {
        var existing = await _walletRepository.GetByIdAsync(wallet.Id);
        if (existing == null) return null;
        var ok = await _walletRepository.UpdateAsync(wallet);
        return ok ? wallet : null;
    }

    public async Task<bool> DeleteWalletAsync(Guid id)
    {
        return await _walletRepository.DeleteAsync(id);
    }
}
