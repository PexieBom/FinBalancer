namespace FinBalancer.Api.Models;

public class WalletBudget
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid WalletId { get; set; }
    public decimal BudgetAmount { get; set; }
    /// <summary>Day of month when period starts (1-28). Default 1. Ignored when using CreatedAt-based period.</summary>
    public int PeriodStartDay { get; set; } = 1;
    /// <summary>Optional start date for custom period. When set with PeriodEndDate, defines exact date range.</summary>
    public DateTime? PeriodStartDate { get; set; }
    /// <summary>Optional end date for the budget period. If null, period ends at end of month. For custom period, use with PeriodStartDate.</summary>
    public DateTime? PeriodEndDate { get; set; }
    /// <summary>If set, budget tracks only expenses in this category. If null, tracks all expenses.</summary>
    public Guid? CategoryId { get; set; }
    /// <summary>If true, this budget is shown on dashboard. At most one per user.</summary>
    public bool IsMain { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
