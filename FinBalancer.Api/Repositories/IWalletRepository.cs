using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IWalletRepository
{
    Task<List<Wallet>> GetAllAsync();
    Task<Wallet?> GetByIdAsync(Guid id);
    Task<Wallet> AddAsync(Wallet wallet);
    Task<bool> UpdateAsync(Wallet wallet);
    Task<bool> DeleteAsync(Guid id);
}
