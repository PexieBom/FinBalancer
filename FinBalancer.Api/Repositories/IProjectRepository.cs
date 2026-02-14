using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IProjectRepository
{
    Task<List<Project>> GetAllAsync();
    Task<Project?> GetByIdAsync(Guid id);
    Task<Project> AddAsync(Project project);
    Task<bool> UpdateAsync(Project project);
    Task<bool> DeleteAsync(Guid id);
}
