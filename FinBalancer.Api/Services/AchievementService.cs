using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class AchievementService
{
    private readonly IAchievementRepository _achievementRepository;
    private readonly ITransactionRepository _transactionRepository;
    private readonly IGoalRepository _goalRepository;

    public AchievementService(
        IAchievementRepository achievementRepository,
        ITransactionRepository transactionRepository,
        IGoalRepository goalRepository)
    {
        _achievementRepository = achievementRepository;
        _transactionRepository = transactionRepository;
        _goalRepository = goalRepository;
    }

    public async Task CheckAndUnlockAchievementsAsync()
    {
        var transactions = await _transactionRepository.GetAllAsync();
        var goals = await _goalRepository.GetAllAsync();

        if (transactions.Count >= 1 && !await _achievementRepository.IsUnlockedAsync("first_transaction"))
            await _achievementRepository.UnlockAsync("first_transaction");

        if (transactions.Count >= 10 && !await _achievementRepository.IsUnlockedAsync("ten_transactions"))
            await _achievementRepository.UnlockAsync("ten_transactions");

        if (goals.Count >= 1 && !await _achievementRepository.IsUnlockedAsync("first_goal"))
            await _achievementRepository.UnlockAsync("first_goal");

        if (goals.Any(g => g.CurrentAmount >= g.TargetAmount) && !await _achievementRepository.IsUnlockedAsync("goal_reached"))
            await _achievementRepository.UnlockAsync("goal_reached");

        var earlyToday = transactions.Any(t =>
            t.DateCreated.Date == DateTime.UtcNow.Date &&
            t.DateCreated.Hour < 9);
        if (earlyToday && !await _achievementRepository.IsUnlockedAsync("early_bird"))
            await _achievementRepository.UnlockAsync("early_bird");
    }
}
