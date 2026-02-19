using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class ProjectService
{
    private readonly IProjectRepository _projectRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public ProjectService(
        IProjectRepository projectRepository,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService)
    {
        _projectRepository = projectRepository;
        _currentUser = currentUser;
        _accountLinkService = accountLinkService;
    }

    private async Task<Guid?> ResolveEffectiveUserIdForReadAsync(Guid? viewAsHostId)
    {
        var current = _currentUser.UserId;
        if (!current.HasValue) return null;
        if (!viewAsHostId.HasValue) return current;
        if (viewAsHostId.Value == current.Value) return current;
        var canView = await _accountLinkService.CanGuestViewHostAsync(current.Value, viewAsHostId.Value);
        return canView ? viewAsHostId : null;
    }

    public async Task<List<Project>> GetAllAsync(Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return new List<Project>();
        return await _projectRepository.GetAllByUserIdAsync(userId.Value);
    }

    public async Task<Project?> GetByIdAsync(Guid id, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
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
