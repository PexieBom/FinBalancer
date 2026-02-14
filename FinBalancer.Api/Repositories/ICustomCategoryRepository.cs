using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ICustomCategoryRepository
{
    Task<List<CustomCategory>> GetByUserIdAsync(Guid userId);
    Task<CustomCategory> AddAsync(CustomCategory category);
    Task<bool> DeleteAsync(Guid id, Guid userId);
}
