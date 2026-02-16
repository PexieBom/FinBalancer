using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class ProjectService
{
    private readonly IProjectRepository _projectRepository;
    private readonly ICurrentUserService _currentUser;

    public ProjectService(IProjectRepository projectRepository, ICurrentUserService currentUser)
    {
        _projectRepository = projectRepository;
        _currentUser = currentUser;
    }

    public async Task<List<Project>> GetAllAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return new List<Project>();
        return await _projectRepository.GetAllByUserIdAsync(userId.Value);
    }

    public async Task<Project?> GetByIdAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;
        return await _projectRepository.GetByIdAndUserIdAsync(id, userId.Value);
    }

    public async Task<Project?> CreateAsync(Project project)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        project.UserId = userId.Value;
        return await _projectRepository.AddAsync(project);
    }

    public async Task<bool> UpdateAsync(Project project)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;

        var existing = await _projectRepository.GetByIdAndUserIdAsync(project.Id, userId.Value);
        if (existing == null) return false;
        project.UserId = userId.Value;
        return await _projectRepository.UpdateAsync(project);
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;
        var existing = await _projectRepository.GetByIdAndUserIdAsync(id, userId.Value);
        if (existing == null) return false;
        return await _projectRepository.DeleteAsync(id);
    }
}
