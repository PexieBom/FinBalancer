namespace FinBalancer.Api.Models;

public class Wallet
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Balance { get; set; }
    public string Currency { get; set; } = "EUR";
    /// <summary>Glavni novčanik - automatski odabran pri dodavanju transakcija.</summary>
    public bool IsMain { get; set; }
}
