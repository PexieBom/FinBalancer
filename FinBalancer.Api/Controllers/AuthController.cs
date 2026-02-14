using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResult>> Register([FromBody] RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            return BadRequest("Email and password required");

        var result = await _authService.RegisterAsync(
            request.Email,
            request.Password,
            request.DisplayName ?? request.Email.Split('@')[0]);
        return Ok(result);
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResult>> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            return BadRequest("Email and password required");

        var result = await _authService.LoginAsync(request.Email, request.Password);
        return Ok(result);
    }

    [HttpPost("login/google")]
    public async Task<ActionResult<AuthResult>> LoginGoogle([FromBody] OAuthLoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.ProviderId) || string.IsNullOrWhiteSpace(request.Email))
            return BadRequest("ProviderId and Email required");

        var result = await _authService.LoginWithGoogleAsync(
            request.ProviderId,
            request.Email,
            request.DisplayName);
        return Ok(result);
    }

    [HttpPost("login/apple")]
    public async Task<ActionResult<AuthResult>> LoginApple([FromBody] OAuthLoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.ProviderId))
            return BadRequest("ProviderId required");

        var result = await _authService.LoginWithAppleAsync(
            request.ProviderId,
            request.Email,
            request.DisplayName);
        return Ok(result);
    }

    [HttpPost("password/reset-request")]
    public async Task<ActionResult<AuthResult>> RequestPasswordReset([FromBody] ResetPasswordRequest request, [FromQuery] bool dev = false)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
            return BadRequest("Email required");

        var result = await _authService.RequestPasswordResetAsync(request.Email, dev);
        return Ok(result);
    }

    [HttpPost("password/reset")]
    public async Task<ActionResult<AuthResult>> ResetPassword([FromBody] ResetPasswordConfirmRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Token) || string.IsNullOrWhiteSpace(request.NewPassword))
            return BadRequest("Token and NewPassword required");

        var result = await _authService.ResetPasswordAsync(request.Token, request.NewPassword);
        return Ok(result);
    }
}

public record RegisterRequest(string Email, string Password, string? DisplayName);
public record LoginRequest(string Email, string Password);
public record OAuthLoginRequest(string ProviderId, string? Email, string? DisplayName);
public record ResetPasswordRequest(string Email);
public record ResetPasswordConfirmRequest(string Token, string NewPassword);
