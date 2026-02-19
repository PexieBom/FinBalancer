namespace FinBalancer.Api.Models;

/// <summary>
/// Povezivanje računa: Host (pozivatelj) i Guest (pozvani).
/// Guest može pregledavati sve podatke Host-a; Host ne vidi podatke Guest-a.
/// </summary>
public class AccountLink
{
    public Guid Id { get; set; }
    /// <summary>Korisnik koji je pozvao (vlasnik podataka koje guest vidi).</summary>
    public Guid HostUserId { get; set; }
    /// <summary>Pozvani korisnik koji može pregledavati hostove podatke.</summary>
    public Guid GuestUserId { get; set; }
    public AccountLinkStatus Status { get; set; }
    public DateTime InvitedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}

public enum AccountLinkStatus
{
    Pending = 0,
    Accepted = 1,
    Revoked = 2
}
