using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IWalletBudgetRepository
{
    Task<WalletBudget?> GetByWalletIdAsync(Guid walletId);
    Task<WalletBudget?> GetByWalletIdAndUserIdAsync(Guid walletId, Guid userId);
    Task<WalletBudget> UpsertAsync(WalletBudget budget);
    Task<bool> DeleteByWalletIdAsync(Guid walletId);
    Task<List<WalletBudget>> GetAllAsync();
    Task<List<WalletBudget>> GetAllByUserIdAsync(Guid userId);
}
