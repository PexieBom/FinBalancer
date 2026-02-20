using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ITransactionRepository
{
    Task<List<Transaction>> GetAllAsync();
    Task<List<Transaction>> GetAllByUserIdAsync(Guid userId);
    Task<List<Transaction>> GetByUserIdPagedAsync(Guid userId, DateTime? dateFrom, DateTime? dateTo, Guid? walletId, string? tag, string? project, Guid? categoryId, int limit, int offset);
    Task<Transaction?> GetByIdAsync(Guid id);
    Task<Transaction?> GetByIdAndUserIdAsync(Guid id, Guid userId);
    Task<Transaction> AddAsync(Transaction transaction);
    Task<bool> UpdateAsync(Transaction transaction);
    Task<bool> DeleteAsync(Guid id);
}
