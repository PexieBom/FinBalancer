using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services;

public interface IAuthService
{
    Task<AuthResult> RegisterAsync(string email, string password, string displayName);
    Task<AuthResult> LoginAsync(string email, string password);
    Task<AuthResult> LoginWithGoogleAsync(string googleId, string email, string? displayName);
    Task<AuthResult> LoginWithAppleAsync(string appleId, string? email, string? displayName);
    Task<AuthResult?> RequestPasswordResetAsync(string email, bool returnTokenForDev = false);
    Task<AuthResult?> ResetPasswordAsync(string token, string newPassword);
    Task<User?> GetUserByTokenAsync(string token);
    Task<AuthResult?> RefreshTokenAsync(string refreshToken);
}
