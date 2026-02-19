namespace FinBalancer.Api.Data;

public class WalletBudgetEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid WalletId { get; set; }
    public decimal BudgetAmount { get; set; }
    public int PeriodStartDay { get; set; } = 1;
    public DateTime? PeriodStartDate { get; set; }
    public DateTime? PeriodEndDate { get; set; }
    public Guid? CategoryId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
