namespace FinBalancer.Api.Models;

/// <summary>Obavijest prikazana korisniku u aplikaciji.</summary>
public class InAppNotification
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Type { get; set; } = string.Empty; // AccountLinkInvite, BudgetAlert, etc.
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    /// <summary>Opcionalni ID vezanog entiteta (npr. linkId za AccountLinkInvite).</summary>
    public string? RelatedId { get; set; }
    public string? ActionRoute { get; set; } // e.g. /linked-accounts
}
