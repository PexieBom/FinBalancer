using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GoalsController : ControllerBase
{
    private readonly GoalService _goalService;

    public GoalsController(GoalService goalService)
    {
        _goalService = goalService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Goal>>> Get() => Ok(await _goalService.GetAllAsync());

    [HttpPost]
    public async Task<ActionResult<Goal>> Post([FromBody] Goal goal)
    {
        if (string.IsNullOrWhiteSpace(goal.Name))
            return BadRequest("Name required");
        var created = await _goalService.CreateAsync(goal);
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
