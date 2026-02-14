namespace FinBalancer.Api.Models;

/// <summary>
/// Stored refresh token - valid 1 year from creation.
/// </summary>
public class RefreshTokenStore
{
    public string Token { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
