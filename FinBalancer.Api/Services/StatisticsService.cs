using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class StatisticsService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public StatisticsService(
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

    public async Task<SpendingByCategoryDto?> GetSpendingByCategoryAsync(Guid? walletId = null, DateTime? dateFrom = null, DateTime? dateTo = null, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);
        var categories = await _categoryRepository.GetOrSeedDefaultsAsync();

        var filtered = transactions
            .Where(t => t.Type == "expense")
            .Where(t => !walletId.HasValue || t.WalletId == walletId);
        if (dateFrom.HasValue) filtered = filtered.Where(t => t.DateCreated >= dateFrom.Value);
        if (dateTo.HasValue) filtered = filtered.Where(t => t.DateCreated <= dateTo.Value);
        var expenseTransactions = filtered.ToList();

        var byCategory = expenseTransactions
            .GroupBy(t => t.CategoryId)
            .Select(g =>
            {
                var category = categories.FirstOrDefault(c => c.Id == g.Key);
                return new CategorySpendingDto(
                    g.Key,
                    category?.Name ?? "Unknown",
                    category?.Icon ?? "",
                    g.Sum(t => t.Amount),
                    g.Count());
            })
            .OrderByDescending(x => x.Total)
            .ToList();

        return new SpendingByCategoryDto(byCategory.Sum(x => x.Total), byCategory);
    }

    public async Task<IncomeExpenseSummaryDto?> GetIncomeExpenseSummaryAsync(Guid? walletId = null, DateTime? dateFrom = null, DateTime? dateTo = null, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var transactions = await _transactionRepository.GetAllByUserIdAsync(userId.Value);

        var filtered = walletId.HasValue
            ? transactions.Where(t => t.WalletId == walletId)
            : transactions.AsEnumerable();
        if (dateFrom.HasValue) filtered = filtered.Where(t => t.DateCreated >= dateFrom.Value);
        if (dateTo.HasValue) filtered = filtered.Where(t => t.DateCreated <= dateTo.Value);
        var list = filtered.ToList();

        var income = list.Where(t => t.Type == "income").Sum(t => t.Amount);
        var expense = list.Where(t => t.Type == "expense").Sum(t => t.Amount);

        var byMonth = list
            .GroupBy(t => new { t.DateCreated.Year, t.DateCreated.Month })
            .Select(g => new MonthlySummaryDto(
                g.Key.Year,
                g.Key.Month,
                g.Where(t => t.Type == "income").Sum(t => t.Amount),
                g.Where(t => t.Type == "expense").Sum(t => t.Amount)))
            .OrderByDescending(x => x.Year).ThenByDescending(x => x.Month)
            .Take(12)
            .ToList();

        return new IncomeExpenseSummaryDto(income, expense, income - expense, byMonth);
    }
}

public record SpendingByCategoryDto(decimal TotalExpense, List<CategorySpendingDto> ByCategory);
public record CategorySpendingDto(Guid CategoryId, string CategoryName, string CategoryIcon, decimal Total, int Count);
public record IncomeExpenseSummaryDto(decimal TotalIncome, decimal TotalExpense, decimal Balance, List<MonthlySummaryDto> ByMonth);
public record MonthlySummaryDto(int Year, int Month, decimal Income, decimal Expense);
