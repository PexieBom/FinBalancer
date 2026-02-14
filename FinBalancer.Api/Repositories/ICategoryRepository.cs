using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ICategoryRepository
{
    Task<List<Category>> GetAllAsync();
    Task<List<Category>> GetOrSeedDefaultsAsync();
}
