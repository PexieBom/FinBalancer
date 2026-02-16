using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BudgetsController : ControllerBase
{
    private readonly BudgetService _budgetService;

    public BudgetsController(BudgetService budgetService)
    {
        _budgetService = budgetService;
    }

    [HttpGet("current")]
    public async Task<ActionResult<List<BudgetSummaryDto>>> GetCurrent()
    {
        var result = await _budgetService.GetAllCurrentAsync();
        return Ok(result);
    }

    [HttpGet("global/current")]
    public async Task<ActionResult<BudgetCurrentDto>> GetGlobalCurrent()
    {
        var result = await _budgetService.GetCurrentAsync(Guid.Empty);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost("global")]
    public async Task<ActionResult<BudgetCurrentDto>> CreateOrUpdateGlobal([FromBody] CreateBudgetRequest request)
    {
        var result = await _budgetService.CreateOrUpdateAsync(Guid.Empty, request.BudgetAmount, request.PeriodStartDay);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpDelete("global")]
    public async Task<IActionResult> DeleteGlobal()
    {
        var deleted = await _budgetService.DeleteAsync(Guid.Empty);
        if (!deleted) return NotFound();
        return NoContent();
    }
}
