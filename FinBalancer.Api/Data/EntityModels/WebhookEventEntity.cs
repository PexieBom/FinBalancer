namespace FinBalancer.Api.Data;

public class WebhookEventEntity
{
    public Guid Id { get; set; }
    public string Provider { get; set; } = string.Empty;
    public string EventId { get; set; } = string.Empty;
    public string? PayloadHash { get; set; }
    public DateTime ProcessedAt { get; set; }
}
