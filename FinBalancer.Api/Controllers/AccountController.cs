using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AccountController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ICurrentUserService _currentUser;

    public AccountController(IAuthService authService, ICurrentUserService currentUser)
    {
        _authService = authService;
        _currentUser = currentUser;
    }

    /// <summary>Change password for logged-in user. Requires current password.</summary>
    [HttpPost("password/change")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.CurrentPassword) || string.IsNullOrWhiteSpace(request.NewPassword))
            return BadRequest("CurrentPassword and NewPassword required");

        var error = await _authService.ChangePasswordAsync(userId.Value, request.CurrentPassword, request.NewPassword);
        if (error != null) return BadRequest(new { error });
        return Ok();
    }
}

public record ChangePasswordRequest(string CurrentPassword, string NewPassword);
