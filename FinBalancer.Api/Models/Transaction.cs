namespace FinBalancer.Api.Models;

public class Transaction
{
    public Guid Id { get; set; }
    public decimal Amount { get; set; }
    public string Type { get; set; } = "expense";
    public Guid CategoryId { get; set; }
    public Guid? SubcategoryId { get; set; }
    public Guid WalletId { get; set; }
    public string? Note { get; set; }
    public List<string> Tags { get; set; } = new();
    public string? Project { get; set; }
    public DateTime DateCreated { get; set; }
}
