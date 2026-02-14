namespace FinBalancer.Api.Models;

public class AuthResult
{
    public bool Success { get; set; }
    public string? Token { get; set; }
    /// <summary>Refresh token - valid 1 year. Use to obtain new access token.</summary>
    public string? RefreshToken { get; set; }
    public DateTime? TokenExpiresAt { get; set; }
    public User? User { get; set; }
    public string? Error { get; set; }
}
