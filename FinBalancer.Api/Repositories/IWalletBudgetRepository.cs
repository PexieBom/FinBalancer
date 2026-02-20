using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IWalletBudgetRepository
{
    Task<WalletBudget?> GetByIdAsync(Guid id);
    Task<WalletBudget?> GetByWalletIdAsync(Guid walletId);
    Task<WalletBudget?> GetByWalletIdAndUserIdAsync(Guid walletId, Guid userId);
    Task<WalletBudget> CreateAsync(WalletBudget budget);
    Task<WalletBudget> UpdateAsync(WalletBudget budget);
    Task<WalletBudget> UpsertAsync(WalletBudget budget); // legacy
    Task<bool> DeleteByIdAsync(Guid id);
    Task<bool> DeleteByWalletIdAsync(Guid walletId); // legacy
    Task<List<WalletBudget>> GetAllAsync();
    Task<List<WalletBudget>> GetAllByUserIdAsync(Guid userId);
}
