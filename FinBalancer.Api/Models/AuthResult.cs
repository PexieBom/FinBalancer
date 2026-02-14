namespace FinBalancer.Api.Models;

public class AuthResult
{
    public bool Success { get; set; }
    public string? Token { get; set; }
    public User? User { get; set; }
    public string? Error { get; set; }
}
