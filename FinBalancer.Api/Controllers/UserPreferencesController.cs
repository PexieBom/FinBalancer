using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserPreferencesController : ControllerBase
{
    private readonly UserPreferencesService _preferencesService;

    public UserPreferencesController(UserPreferencesService preferencesService)
    {
        _preferencesService = preferencesService;
    }

    [HttpGet]
    public async Task<ActionResult<UserPreferences>> Get()
    {
        var prefs = await _preferencesService.GetAsync();
        return Ok(prefs);
    }

    [HttpPut]
    public async Task<ActionResult<UserPreferences>> Put([FromBody] UserPreferencesRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Locale) || string.IsNullOrWhiteSpace(request.Currency))
            return BadRequest("Locale and Currency required");
        var theme = request.Theme ?? "system";
        if (theme is not "light" and not "dark" and not "system") theme = "system";
        var prefs = await _preferencesService.UpdateAsync(request.Locale, request.Currency, theme);
        return Ok(prefs);
    }
}

public record UserPreferencesRequest(string Locale, string Currency, string? Theme);
