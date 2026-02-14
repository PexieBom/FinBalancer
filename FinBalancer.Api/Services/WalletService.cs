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
}
