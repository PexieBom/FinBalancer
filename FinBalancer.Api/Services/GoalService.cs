using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class GoalService
{
    private readonly IGoalRepository _goalRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public GoalService(
        IGoalRepository goalRepository,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService)
    {
        _goalRepository = goalRepository;
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

    public async Task<List<Goal>> GetAllAsync(Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return new List<Goal>();
        return await _goalRepository.GetAllByUserIdAsync(userId.Value);
    }

    public async Task<Goal?> GetByIdAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;
        return await _goalRepository.GetByIdAndUserIdAsync(id, userId.Value);
    }

    public async Task<Goal?> CreateAsync(Goal goal)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        goal.CurrentAmount = 0;
        goal.UserId = userId.Value;
        return await _goalRepository.AddAsync(goal);
    }

    public async Task<bool> UpdateProgressAsync(Guid id, decimal amount)
    {
        var goal = await GetByIdAsync(id);
        if (goal == null) return false;
        goal.CurrentAmount = amount;
        return await _goalRepository.UpdateAsync(goal);
    }

    public async Task<bool> AddToGoalAsync(Guid id, decimal amount)
    {
        var goal = await GetByIdAsync(id);
        if (goal == null) return false;
        goal.CurrentAmount += amount;
        return await _goalRepository.UpdateAsync(goal);
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;
        var existing = await _goalRepository.GetByIdAndUserIdAsync(id, userId.Value);
        if (existing == null) return false;
        return await _goalRepository.DeleteAsync(id);
    }
}
