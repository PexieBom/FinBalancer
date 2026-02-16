using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class AchievementService
{
    private readonly IAchievementRepository _achievementRepository;
    private readonly ITransactionRepository _transactionRepository;
    private readonly IGoalRepository _goalRepository;
    private readonly ICurrentUserService _currentUser;

    public AchievementService(
        IAchievementRepository achievementRepository,
        ITransactionRepository transactionRepository,
        IGoalRepository goalRepository,
        ICurrentUserService currentUser)
    {
        _achievementRepository = achievementRepository;
        _transactionRepository = transactionRepository;
        _goalRepository = goalRepository;
        _currentUser = currentUser;
    }

    public async Task CheckAndUnlockAchievementsAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);
        var goals = await _goalRepository.GetAllByUserIdAsync(userId.Value);

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

        var now = DateTime.UtcNow;
        var thisMonthStart = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var monthIncome = transactions.Where(t => t.Type == "income" && t.DateCreated >= thisMonthStart).Sum(t => t.Amount);
        var monthExpense = transactions.Where(t => t.Type == "expense" && t.DateCreated >= thisMonthStart).Sum(t => t.Amount);
        if (monthIncome > monthExpense && monthExpense > 0 && !await _achievementRepository.IsUnlockedAsync("month_saved"))
            await _achievementRepository.UnlockAsync("month_saved");

        var threeMonthsAgo = now.AddMonths(-3);
        var positiveMonths = 0;
        for (var m = 0; m < 3; m++)
        {
            var monthStart = threeMonthsAgo.AddMonths(m);
            var monthEnd = monthStart.AddMonths(1);
            var inc = transactions.Where(t => t.Type == "income" && t.DateCreated >= monthStart && t.DateCreated < monthEnd).Sum(t => t.Amount);
            var exp = transactions.Where(t => t.Type == "expense" && t.DateCreated >= monthStart && t.DateCreated < monthEnd).Sum(t => t.Amount);
            if (inc > exp) positiveMonths++;
        }
        if (positiveMonths >= 3 && !await _achievementRepository.IsUnlockedAsync("quarter_positive"))
            await _achievementRepository.UnlockAsync("quarter_positive");

        var firstTx = transactions.OrderBy(t => t.DateCreated).FirstOrDefault();
        if (firstTx != null)
        {
            var daysSinceFirst = (now - firstTx.DateCreated).TotalDays;
            if (daysSinceFirst >= 30 && !await _achievementRepository.IsUnlockedAsync("app_month"))
                await _achievementRepository.UnlockAsync("app_month");
            if (daysSinceFirst >= 365 && !await _achievementRepository.IsUnlockedAsync("app_year"))
                await _achievementRepository.UnlockAsync("app_year");
        }
    }
}
