using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GoalsController : ControllerBase
{
    private readonly GoalService _goalService;
    private readonly AccountLinkService _accountLinkService;
    private readonly ICurrentUserService _currentUser;

    public GoalsController(
        GoalService goalService,
        AccountLinkService accountLinkService,
        ICurrentUserService currentUser)
    {
        _goalService = goalService;
        _accountLinkService = accountLinkService;
        _currentUser = currentUser;
    }

    [HttpGet]
    public async Task<ActionResult<List<Goal>>> Get([FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        return Ok(await _goalService.GetAllAsync(viewAsHostId));
    }

    [HttpPost]
    public async Task<ActionResult<Goal>> Post([FromBody] Goal goal)
    {
        if (string.IsNullOrWhiteSpace(goal.Name))
            return BadRequest("Name required");
        var created = await _goalService.CreateAsync(goal);
        if (created == null) return Unauthorized();
        return CreatedAtAction(nameof(Get), created);
    }

    [HttpPut("{id:guid}/progress")]
    public async Task<IActionResult> UpdateProgress(Guid id, [FromBody] UpdateProgressRequest request)
    {
        var ok = await _goalService.UpdateProgressAsync(id, request.Amount);
        return ok ? NoContent() : NotFound();
    }

    [HttpPut("{id:guid}/add")]
    public async Task<IActionResult> AddToGoal(Guid id, [FromBody] AddToGoalRequest request)
    {
        var ok = await _goalService.AddToGoalAsync(id, request.Amount);
        return ok ? NoContent() : NotFound();
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var ok = await _goalService.DeleteAsync(id);
        return ok ? NoContent() : NotFound();
    }
}

public record UpdateProgressRequest(decimal Amount);
public record AddToGoalRequest(decimal Amount);
