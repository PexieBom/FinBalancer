using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class BudgetService
{
    private readonly IWalletBudgetRepository _budgetRepo;
    private readonly ITransactionRepository _transactionRepo;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public BudgetService(
        IWalletBudgetRepository budgetRepo,
        ITransactionRepository transactionRepo,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService)
    {
        _budgetRepo = budgetRepo;
        _transactionRepo = transactionRepo;
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

    public async Task<BudgetCurrentDto?> GetCurrentAsync(Guid walletId, Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return null;

        var budget = await _budgetRepo.GetByWalletIdAndUserIdAsync(walletId, userId.Value);
        if (budget == null) return null;

        return await ComputeCurrentAsync(walletId, budget, userId.Value);
    }

    public async Task<BudgetCurrentDto?> CreateOrUpdateAsync(Guid walletId, decimal budgetAmount, int periodStartDay = 1, DateTime? periodStartDate = null, DateTime? periodEndDate = null, Guid? categoryId = null)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        var clamped = Math.Clamp(periodStartDay, 1, 28);
        var budget = await _budgetRepo.GetByWalletIdAndUserIdAsync(walletId, userId.Value);
        if (budget == null)
        {
            budget = new WalletBudget
            {
                WalletId = walletId,
                UserId = userId.Value,
                BudgetAmount = budgetAmount,
                PeriodStartDay = clamped,
                PeriodStartDate = periodStartDate,
                PeriodEndDate = periodEndDate,
                CategoryId = categoryId,
            };
        }
        else
        {
            budget.BudgetAmount = budgetAmount;
            budget.PeriodStartDay = clamped;
            budget.PeriodStartDate = periodStartDate;
            budget.PeriodEndDate = periodEndDate;
            budget.CategoryId = categoryId;
        }

        await _budgetRepo.UpsertAsync(budget);
        return (await ComputeCurrentAsync(walletId, budget, userId.Value))!;
    }

    public async Task<bool> DeleteAsync(Guid walletId)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;
        var budget = await _budgetRepo.GetByWalletIdAndUserIdAsync(walletId, userId.Value);
        if (budget == null) return false;
        return await _budgetRepo.DeleteByWalletIdAsync(walletId);
    }

    public async Task<List<BudgetSummaryDto>> GetAllCurrentAsync(Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return new List<BudgetSummaryDto>();

        var budgets = await _budgetRepo.GetAllByUserIdAsync(userId.Value);
        var result = new List<BudgetSummaryDto>();
        foreach (var b in budgets)
        {
            var dto = await ComputeCurrentAsync(b.WalletId, b, userId.Value);
            if (dto != null)
                result.Add(new BudgetSummaryDto(b.WalletId, dto));
        }
        return result;
    }

    private async Task<BudgetCurrentDto?> ComputeCurrentAsync(Guid walletId, WalletBudget budget, Guid userId)
    {
        var now = DateTime.UtcNow.Date;
        var (periodStart, periodEnd) = GetPeriodBoundaries(now, budget.PeriodStartDay, budget.CreatedAt, budget.PeriodStartDate, budget.PeriodEndDate);

        var transactions = await _transactionRepo.GetAllByUserIdAsync(userId);
        var isGlobal = walletId == Guid.Empty;
        var expenseInPeriod = transactions
            .Where(t => t.Type == "expense" && (isGlobal || t.WalletId == walletId))
            .Where(t => t.DateCreated.Date >= periodStart && t.DateCreated.Date <= periodEnd)
            .Where(t => !budget.CategoryId.HasValue || t.CategoryId == budget.CategoryId.Value)
            .Sum(t => t.Amount);

        var totalDays = (int)(periodEnd - periodStart).TotalDays + 1;
        var today = now > periodEnd ? periodEnd : now;
        var daysGone = (int)(today - periodStart).TotalDays + 1;
        var daysRemaining = (int)(periodEnd - today).TotalDays;
        if (daysRemaining < 0) daysRemaining = 0;

        var remaining = budget.BudgetAmount - expenseInPeriod;
        var allowancePerDay = daysRemaining <= 0 || remaining <= 0
            ? 0
            : remaining / daysRemaining;

        var expectedSpendUntilToday = totalDays > 0
            ? (budget.BudgetAmount / totalDays) * daysGone
            : 0;
        var overSpend = expenseInPeriod - expectedSpendUntilToday;

        string paceStatus;
        decimal overUnderPerDay = 0;
        if (remaining <= 0)
        {
            paceStatus = "OverPace";
            overUnderPerDay = daysRemaining > 0 ? remaining / daysRemaining : 0;
        }
        else if (Math.Abs(overSpend) < 0.01m)
        {
            paceStatus = "OnTrack";
        }
        else if (overSpend > 0)
        {
            paceStatus = "OverPace";
            overUnderPerDay = daysRemaining > 0 ? -overSpend / daysRemaining : 0;
        }
        else
        {
            paceStatus = "UnderPace";
            overUnderPerDay = daysRemaining > 0 ? -overSpend / daysRemaining : 0;
        }

        var explanation = BuildExplanation(paceStatus, overUnderPerDay, allowancePerDay, remaining);

        return new BudgetCurrentDto(
            budget.BudgetAmount,
            expenseInPeriod,
            remaining,
            daysRemaining,
            allowancePerDay,
            paceStatus,
            overUnderPerDay,
            periodStart,
            periodEnd,
            explanation
        );
    }

    /// <summary>
    /// Budget period: when PeriodStartDate and PeriodEndDate both set = custom range.
    /// Otherwise: from date when set (CreatedAt) to end of month or PeriodEndDate.
    /// For subsequent months: full month (1st to last day).
    /// </summary>
    private static (DateTime Start, DateTime End) GetPeriodBoundaries(DateTime date, int startDay, DateTime createdAt, DateTime? periodStartDate, DateTime? periodEndDate)
    {
        // Custom period: both start and end dates set
        if (periodStartDate.HasValue && periodEndDate.HasValue)
        {
            var start = periodStartDate.Value.Date;
            var end = periodEndDate.Value.Date;
            if (date >= start && date <= end) return (start, end);
            if (date < start) return (start, end); // show upcoming period
            return (start, end); // period ended, show last period
        }

        var created = createdAt.Date;
        var endOfCreatedMonth = new DateTime(created.Year, created.Month, DateTime.DaysInMonth(created.Year, created.Month), 0, 0, 0, DateTimeKind.Utc);
        var effectiveEnd = periodEndDate?.Date ?? endOfCreatedMonth;

        // Same month as creation: from CreatedAt to end of month (or PeriodEndDate if earlier)
        if (date.Year == created.Year && date.Month == created.Month)
        {
            var periodEnd = effectiveEnd < endOfCreatedMonth ? effectiveEnd : endOfCreatedMonth;
            return (created, periodEnd);
        }

        // Past the first period: use full current month
        if (date > effectiveEnd)
        {
            var startOfMonth = new DateTime(date.Year, date.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var endOfMonth = new DateTime(date.Year, date.Month, DateTime.DaysInMonth(date.Year, date.Month), 0, 0, 0, DateTimeKind.Utc);
            var periodEnd = periodEndDate.HasValue && periodEndDate.Value.Date < endOfMonth
                ? periodEndDate.Value.Date
                : endOfMonth;
            return (startOfMonth, periodEnd);
        }

        // PeriodEndDate spans multiple months and we're in between: use periodStartDay logic
        var startDayClamped = Math.Clamp(startDay, 1, 28);
        if (date.Day >= startDayClamped)
        {
            var periodStart = new DateTime(date.Year, date.Month, startDayClamped, 0, 0, 0, DateTimeKind.Utc);
            var periodEnd = periodEndDate?.Date ?? periodStart.AddMonths(1).AddDays(-1);
            return (periodStart, periodEnd);
        }
        else
        {
            var prevMonth = date.AddMonths(-1);
            var periodStart = new DateTime(prevMonth.Year, prevMonth.Month, startDayClamped, 0, 0, 0, DateTimeKind.Utc);
            var periodEnd = periodEndDate?.Date ?? new DateTime(date.Year, date.Month, startDayClamped, 0, 0, 0, DateTimeKind.Utc).AddDays(-1);
            return (periodStart, periodEnd);
        }
    }

    private static string BuildExplanation(string paceStatus, decimal overUnderPerDay, decimal allowancePerDay, decimal remaining)
    {
        var absOver = Math.Abs(overUnderPerDay);
        var sign = overUnderPerDay >= 0 ? "" : "-";

        if (paceStatus == "OverPace")
        {
            if (remaining <= 0)
                return $"You've exceeded your budget. Limit spending to €{allowancePerDay:F2}/day or less to recover.";
            return $"You're €{absOver:F2}/day over pace. Keep spending under €{allowancePerDay:F2}/day to stay within budget.";
        }

        if (paceStatus == "UnderPace")
        {
            return $"You're €{absOver:F2}/day under pace. You can spend about €{allowancePerDay:F2}/day for the rest of the period.";
        }

        return $"You're on track. You can spend about €{allowancePerDay:F2}/day for the rest of the period.";
    }
}

public record BudgetCurrentDto(
    decimal BudgetAmount,
    decimal Spent,
    decimal Remaining,
    int DaysRemaining,
    decimal AllowancePerDay,
    string PaceStatus,
    decimal OverUnderPerDay,
    DateTime PeriodStart,
    DateTime PeriodEnd,
    string Explanation
);

public record BudgetSummaryDto(Guid WalletId, BudgetCurrentDto Current);
