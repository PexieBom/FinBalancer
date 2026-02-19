using System.Security.Cryptography;
using System.Text;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class MockAuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly INotificationRequestRepository _notificationRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IAccessTokenRepository _accessTokenRepository;
    private static readonly Dictionary<string, Guid> MockTokens = new();
    private static readonly TimeSpan AccessTokenLifetime = TimeSpan.FromHours(24);
    private static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(365);

    public MockAuthService(
        IUserRepository userRepository,
        INotificationRequestRepository notificationRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IAccessTokenRepository accessTokenRepository)
    {
        _userRepository = userRepository;
        _notificationRepository = notificationRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _accessTokenRepository = accessTokenRepository;
    }

    public async Task<AuthResult> RegisterAsync(string email, string password, string displayName)
    {
        var existing = await _userRepository.GetByEmailAsync(email);
        if (existing != null)
            return new AuthResult { Success = false, Error = "Email already registered" };

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email.ToLowerInvariant(),
            PasswordHash = HashPassword(password),
            DisplayName = displayName,
            EmailVerified = false,
            CreatedAt = DateTime.UtcNow
        };
        await _userRepository.AddAsync(user);
        var (token, refreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = token, RefreshToken = refreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<AuthResult> LoginAsync(string email, string password)
    {
        var user = await _userRepository.GetByEmailAsync(email);
        if (user == null)
            return new AuthResult { Success = false, Error = "Invalid email or password" };

        if (user.PasswordHash == null)
            return new AuthResult { Success = false, Error = "Please use Google or Apple to sign in" };

        if (!VerifyPassword(password, user.PasswordHash))
            return new AuthResult { Success = false, Error = "Invalid email or password" };

        user.LastLoginAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user);
        var (token, refreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = token, RefreshToken = refreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<AuthResult> LoginWithGoogleAsync(string googleId, string email, string? displayName)
    {
        var user = await _userRepository.GetByGoogleIdAsync(googleId)
            ?? await _userRepository.GetByEmailAsync(email);

        if (user == null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                Email = email.ToLowerInvariant(),
                GoogleId = googleId,
                DisplayName = displayName ?? email.Split('@')[0],
                EmailVerified = true,
                CreatedAt = DateTime.UtcNow,
                LastLoginAt = DateTime.UtcNow
            };
            await _userRepository.AddAsync(user);
        }
        else
        {
            if (user.GoogleId == null)
            {
                user.GoogleId = googleId;
                await _userRepository.UpdateAsync(user);
            }
            user.LastLoginAt = DateTime.UtcNow;
            await _userRepository.UpdateAsync(user);
        }

        var (token, refreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = token, RefreshToken = refreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<AuthResult> LoginWithAppleAsync(string appleId, string? email, string? displayName)
    {
        var user = await _userRepository.GetByAppleIdAsync(appleId);
        if (user == null && !string.IsNullOrEmpty(email))
            user = await _userRepository.GetByEmailAsync(email);

        if (user == null)
        {
            user = new User
            {
                Id = Guid.NewGuid(),
                Email = email?.ToLowerInvariant() ?? $"{appleId}@privaterelay.appleid.com",
                AppleId = appleId,
                DisplayName = displayName ?? "Apple User",
                EmailVerified = true,
                CreatedAt = DateTime.UtcNow,
                LastLoginAt = DateTime.UtcNow
            };
            await _userRepository.AddAsync(user);
        }
        else
        {
            if (user.AppleId == null)
            {
                user.AppleId = appleId;
                await _userRepository.UpdateAsync(user);
            }
            user.LastLoginAt = DateTime.UtcNow;
            await _userRepository.UpdateAsync(user);
        }

        var (token, refreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = token, RefreshToken = refreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<AuthResult?> RequestPasswordResetAsync(string email, bool returnTokenForDev = false)
    {
        var user = await _userRepository.GetByEmailAsync(email);
        if (user == null || user.PasswordHash == null)
            return new AuthResult { Success = true }; // Don't reveal if user exists

        var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)).Replace("+", "-").Replace("/", "_").TrimEnd('=');
        var request = new NotificationRequest
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            Type = "PasswordReset",
            Token = token,
            ExpiresAt = DateTime.UtcNow.AddHours(24),
            CreatedAt = DateTime.UtcNow
        };
        await _notificationRepository.AddAsync(request);
        // Mock: In production, send email with reset link. Token stored in notification_requests.json
        return new AuthResult { Success = true, Token = returnTokenForDev ? token : null };
    }

    public async Task<AuthResult?> ResetPasswordAsync(string token, string newPassword)
    {
        var request = await _notificationRepository.GetByTokenAsync(token, "PasswordReset");
        if (request == null)
            return new AuthResult { Success = false, Error = "Invalid or expired token" };

        var user = await _userRepository.GetByIdAsync(request.UserId);
        if (user == null)
            return new AuthResult { Success = false, Error = "User not found" };

        user.PasswordHash = HashPassword(newPassword);
        await _userRepository.UpdateAsync(user);
        await _notificationRepository.MarkAsUsedAsync(request.Id);

        var (authToken, refreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = authToken, RefreshToken = refreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<AuthResult?> RefreshTokenAsync(string refreshToken)
    {
        var stored = await _refreshTokenRepository.GetByTokenAsync(refreshToken);
        if (stored == null)
            return new AuthResult { Success = false, Error = "Invalid or expired refresh token" };

        var user = await _userRepository.GetByIdAsync(stored.UserId);
        if (user == null)
            return new AuthResult { Success = false, Error = "User not found" };

        await _refreshTokenRepository.RemoveAsync(refreshToken);
        var (newToken, newRefreshToken) = await GenerateTokensAsync(user.Id);
        return new AuthResult { Success = true, Token = newToken, RefreshToken = newRefreshToken, TokenExpiresAt = DateTime.UtcNow.Add(AccessTokenLifetime), User = user };
    }

    public async Task<User?> GetUserByTokenAsync(string token)
    {
        if (MockTokens.TryGetValue(token, out var userId))
            return await _userRepository.GetByIdAsync(userId);
        if (token == "local_mock")
            return await _userRepository.GetFirstOrDefaultAsync();
        var dbUserId = await _accessTokenRepository.GetUserIdByTokenAsync(token);
        if (dbUserId.HasValue)
            return await _userRepository.GetByIdAsync(dbUserId.Value);
        return null;
    }

    private async Task<(string AccessToken, string RefreshToken)> GenerateTokensAsync(Guid userId)
    {
        var accessToken = "mock_" + Convert.ToBase64String(Guid.NewGuid().ToByteArray()).Replace("+", "-").Replace("/", "_").TrimEnd('=');
        MockTokens[accessToken] = userId;

        var expiresAt = DateTime.UtcNow.Add(AccessTokenLifetime);
        await _accessTokenRepository.AddAsync(accessToken, userId, expiresAt);

        var refreshToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)).Replace("+", "-").Replace("/", "_").TrimEnd('=');
        await _refreshTokenRepository.AddAsync(new RefreshTokenStore
        {
            Token = refreshToken,
            UserId = userId,
            ExpiresAt = DateTime.UtcNow.Add(RefreshTokenLifetime),
            CreatedAt = DateTime.UtcNow
        });

        return (accessToken, refreshToken);
    }

    private static string HashPassword(string password)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password + "FinBalancerSalt"));
        return Convert.ToBase64String(bytes);
    }

    private static bool VerifyPassword(string password, string hash)
    {
        return HashPassword(password) == hash;
    }
}
