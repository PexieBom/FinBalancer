namespace FinBalancer.Api.Data;

public class DeviceTokenEntity
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public string Platform { get; set; } = "android";
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
