using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DeviceTokensController : ControllerBase
{
    private readonly DeviceTokenService _service;

    public DeviceTokensController(DeviceTokenService service)
    {
        _service = service;
    }

    /// <summary>Registrira FCM device token za trenutnog korisnika (za push notifikacije).</summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDeviceTokenRequest request)
    {
        if (string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest(new { error = "Token required" });

        var platform = string.IsNullOrWhiteSpace(request.Platform) ? "android" : request.Platform.ToLowerInvariant();
        if (platform != "android" && platform != "ios")
            platform = "android";

        await _service.RegisterAsync(request.Token, platform);
        return NoContent();
    }

    /// <summary>Uklanja device token (npr. pri logoutu).</summary>
    [HttpPost("unregister")]
    public async Task<IActionResult> Unregister([FromBody] UnregisterDeviceTokenRequest request)
    {
        if (string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest(new { error = "Token required" });

        await _service.UnregisterAsync(request.Token);
        return NoContent();
    }
}

public record RegisterDeviceTokenRequest(string Token, string? Platform);
public record UnregisterDeviceTokenRequest(string Token);
