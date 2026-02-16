using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IGoalRepository
{
    Task<List<Goal>> GetAllAsync();
    Task<List<Goal>> GetAllByUserIdAsync(Guid userId);
    Task<Goal?> GetByIdAsync(Guid id);
    Task<Goal?> GetByIdAndUserIdAsync(Guid id, Guid userId);
    Task<Goal> AddAsync(Goal goal);
    Task<bool> UpdateAsync(Goal goal);
    Task<bool> DeleteAsync(Guid id);
}
