namespace FinBalancer.Api.Data;

public class InAppNotificationEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? RelatedId { get; set; }
    public string? ActionRoute { get; set; }
}
