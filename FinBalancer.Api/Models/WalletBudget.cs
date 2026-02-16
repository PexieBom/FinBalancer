namespace FinBalancer.Api.Models;

public class WalletBudget
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid WalletId { get; set; }
    public decimal BudgetAmount { get; set; }
    /// <summary>Day of month when period starts (1-28). Default 1. Ignored when using CreatedAt-based period.</summary>
    public int PeriodStartDay { get; set; } = 1;
    /// <summary>Optional end date for the budget period. If null, period ends at end of month.</summary>
    public DateTime? PeriodEndDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
