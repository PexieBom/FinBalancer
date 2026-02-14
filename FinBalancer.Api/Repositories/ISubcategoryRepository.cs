using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface ISubcategoryRepository
{
    Task<List<Subcategory>> GetByCategoryAsync(Guid categoryId);
    Task<List<Subcategory>> GetAllAsync();
    Task<Subcategory> AddAsync(Subcategory subcategory);
}
