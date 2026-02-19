using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class AdvancedStatisticsService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public AdvancedStatisticsService(
        ITransactionRepository transactionRepository,
        ICategoryRepository categoryRepository,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService)
    {
        _transactionRepository = transactionRepository;
        _categoryRepository = categoryRepository;
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

    public async Task<BudgetPredictionDto?> GetBudgetPredictionAsync(Guid? walletId = null, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);
        var categories = await _categoryRepository.GetOrSeedDefaultsAsync();

        var filtered = transactions
            .Where(t => t.Type == "expense")
            .Where(t => !t.IsYearlyExpense)
            .Where(t => !walletId.HasValue || t.WalletId == walletId)
            .Where(t => t.DateCreated >= DateTime.UtcNow.AddMonths(-3))
            .ToList();

        var byCategory = new List<CategoryPredictionDto>();
        foreach (var group in filtered.GroupBy(t => t.CategoryId))
        {
            var cat = categories.FirstOrDefault(c => c.Id == group.Key);
            var monthlyTotals = filtered
                .Where(t => t.CategoryId == group.Key)
                .GroupBy(t => new { t.DateCreated.Year, t.DateCreated.Month })
                .Select(grp => grp.Sum(t => t.Amount))
                .ToList();
            var monthlyAvg = monthlyTotals.Count > 0 ? monthlyTotals.Average() : 0;
            var predicted = (decimal)monthlyAvg * 1.05m;
            byCategory.Add(new CategoryPredictionDto(
                group.Key,
                cat?.Name ?? "Unknown",
                (decimal)monthlyAvg,
                predicted));
        }

        return new BudgetPredictionDto(byCategory, byCategory.Sum(c => c.PredictedNextMonth));
    }

    public async Task<List<BudgetAlertDto>?> GetBudgetAlertsAsync(Guid? walletId = null, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);
        var categories = await _categoryRepository.GetOrSeedDefaultsAsync();

        var thisMonth = transactions
            .Where(t => t.Type == "expense")
            .Where(t => !walletId.HasValue || t.WalletId == walletId)
            .Where(t => t.DateCreated.Year == DateTime.UtcNow.Year && t.DateCreated.Month == DateTime.UtcNow.Month)
            .ToList();

        var last3Months = transactions
            .Where(t => t.Type == "expense")
            .Where(t => !walletId.HasValue || t.WalletId == walletId)
            .Where(t => t.DateCreated >= DateTime.UtcNow.AddMonths(-3))
            .ToList();

        var alerts = new List<BudgetAlertDto>();

        foreach (var category in categories.Where(c => c.Type == "expense"))
        {
            var thisMonthSpent = thisMonth.Where(t => t.CategoryId == category.Id).Sum(t => t.Amount);
            var monthlySums = last3Months
                .Where(t => t.CategoryId == category.Id)
                .GroupBy(t => new { t.DateCreated.Year, t.DateCreated.Month })
                .Select(g => g.Sum(t => t.Amount))
                .ToList();
            var avgSpent = monthlySums.Count > 0 ? monthlySums.Average() : 0;

            if (avgSpent > 0 && thisMonthSpent > (decimal)avgSpent * 1.2m)
            {
                var pct = (double)(thisMonthSpent / (decimal)avgSpent * 100 - 100);
                alerts.Add(new BudgetAlertDto(
                    category.Name,
                    thisMonthSpent,
                    (decimal)avgSpent,
                    $"Trošiš {pct:F0}% više od prosjeka u {category.Name}"));
            }
        }

        return alerts;
    }

    public async Task<TrendDataDto?> GetCashflowTrendAsync(Guid? walletId = null, int months = 6, DateTime? dateFrom = null, DateTime? dateTo = null, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);

        var filtered = walletId.HasValue
            ? transactions.Where(t => t.WalletId == walletId)
            : transactions.AsEnumerable();
        if (dateFrom.HasValue) filtered = filtered.Where(t => t.DateCreated >= dateFrom.Value);
        if (dateTo.HasValue) filtered = filtered.Where(t => t.DateCreated <= dateTo.Value);
        if (!dateFrom.HasValue && !dateTo.HasValue)
            filtered = filtered.Where(t => t.DateCreated >= DateTime.UtcNow.AddMonths(-months));
        var list = filtered.ToList();

        var byMonth = list
            .GroupBy(t => new { t.DateCreated.Year, t.DateCreated.Month })
            .OrderBy(g => g.Key.Year).ThenBy(g => g.Key.Month)
            .Select(g =>
            {
                var income = g.Where(t => t.Type == "income").Sum(t => t.Amount);
                var expense = g.Where(t => t.Type == "expense").Sum(t => t.Amount);
                return new TrendPointDto(g.Key.Year, g.Key.Month, income, expense, income - expense);
            })
            .ToList();

        return new TrendDataDto(byMonth);
    }
}

public record BudgetPredictionDto(List<CategoryPredictionDto> ByCategory, decimal TotalPredictedNextMonth);
public record CategoryPredictionDto(Guid CategoryId, string CategoryName, decimal AverageMonthly, decimal PredictedNextMonth);
public record BudgetAlertDto(string CategoryName, decimal CurrentSpending, decimal AverageSpending, string Message);
public record TrendDataDto(List<TrendPointDto> Points);
public record TrendPointDto(int Year, int Month, decimal Income, decimal Expense, decimal Net);
