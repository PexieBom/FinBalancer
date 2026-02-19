namespace FinBalancer.Api.Data;

public class TransactionEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public decimal Amount { get; set; }
    public string Type { get; set; } = "expense";
    public Guid CategoryId { get; set; }
    public Guid? SubcategoryId { get; set; }
    public Guid WalletId { get; set; }
    public string? Note { get; set; }
    public string? Tags { get; set; } // JSON array stored as string/jsonb
    public string? Project { get; set; }
    public Guid? ProjectId { get; set; }
    public DateTime DateCreated { get; set; }
    public bool IsYearlyExpense { get; set; }
}
