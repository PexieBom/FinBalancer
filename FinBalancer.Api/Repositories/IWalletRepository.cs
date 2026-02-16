using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IWalletRepository
{
    Task<List<Wallet>> GetAllAsync();
    Task<List<Wallet>> GetAllByUserIdAsync(Guid userId);
    Task<Wallet?> GetByIdAsync(Guid id);
    Task<Wallet?> GetByIdAndUserIdAsync(Guid id, Guid userId);
    Task<Wallet> AddAsync(Wallet wallet);
    Task<bool> UpdateAsync(Wallet wallet);
    Task<bool> DeleteAsync(Guid id);
}
