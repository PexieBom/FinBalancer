using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class GoalService
{
    private readonly IGoalRepository _goalRepository;

    public GoalService(IGoalRepository goalRepository)
    {
        _goalRepository = goalRepository;
    }

    public async Task<List<Goal>> GetAllAsync() => await _goalRepository.GetAllAsync();

    public async Task<Goal?> GetByIdAsync(Guid id) => await _goalRepository.GetByIdAsync(id);

    public async Task<Goal> CreateAsync(Goal goal)
    {
        goal.CurrentAmount = 0;
        return await _goalRepository.AddAsync(goal);
    }

    public async Task<bool> UpdateProgressAsync(Guid id, decimal amount)
    {
        var goal = await _goalRepository.GetByIdAsync(id);
        if (goal == null) return false;
        goal.CurrentAmount = amount;
        return await _goalRepository.UpdateAsync(goal);
    }

    public async Task<bool> AddToGoalAsync(Guid id, decimal amount)
    {
        var goal = await _goalRepository.GetByIdAsync(id);
        if (goal == null) return false;
        goal.CurrentAmount += amount;
        return await _goalRepository.UpdateAsync(goal);
    }

    public async Task<bool> DeleteAsync(Guid id) => await _goalRepository.DeleteAsync(id);
}
