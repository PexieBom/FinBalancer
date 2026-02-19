namespace FinBalancer.Api.Data;

public class AccountLinkEntity
{
    public Guid Id { get; set; }
    public Guid HostUserId { get; set; }
    public Guid GuestUserId { get; set; }
    public int Status { get; set; } // 0=Pending, 1=Accepted, 2=Revoked
    public DateTime InvitedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}
