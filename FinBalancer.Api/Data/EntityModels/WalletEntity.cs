namespace FinBalancer.Api.Data;

public class WalletEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Balance { get; set; }
    public string Currency { get; set; } = "EUR";
    public bool IsMain { get; set; }
}
