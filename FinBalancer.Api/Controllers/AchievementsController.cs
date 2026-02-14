using FinBalancer.Api.Repositories;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AchievementsController : ControllerBase
{
    private readonly IAchievementRepository _achievementRepository;
    private readonly AchievementService _achievementService;

    public AchievementsController(
        IAchievementRepository achievementRepository,
        AchievementService achievementService)
    {
        _achievementRepository = achievementRepository;
        _achievementService = achievementService;
    }

    [HttpGet]
    public async Task<ActionResult> Get()
    {
        await _achievementService.CheckAndUnlockAchievementsAsync();
        var achievements = await _achievementRepository.GetAllAsync();
        return Ok(achievements);
    }

    [HttpPost("check")]
    public async Task<IActionResult> Check()
    {
        await _achievementService.CheckAndUnlockAchievementsAsync();
        return NoContent();
    }
}
