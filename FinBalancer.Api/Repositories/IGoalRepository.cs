using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IGoalRepository
{
    Task<List<Goal>> GetAllAsync();
    Task<Goal?> GetByIdAsync(Guid id);
    Task<Goal> AddAsync(Goal goal);
    Task<bool> UpdateAsync(Goal goal);
    Task<bool> DeleteAsync(Guid id);
}
