using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BudgetsController : ControllerBase
{
    private readonly BudgetService _budgetService;
    private readonly AccountLinkService _accountLinkService;
    private readonly ICurrentUserService _currentUser;

    public BudgetsController(
        BudgetService budgetService,
        AccountLinkService accountLinkService,
        ICurrentUserService currentUser)
    {
        _budgetService = budgetService;
        _accountLinkService = accountLinkService;
        _currentUser = currentUser;
    }

    [HttpGet("current")]
    public async Task<ActionResult<List<BudgetSummaryDto>>> GetCurrent([FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _budgetService.GetAllCurrentAsync(viewAsHostId);
        return Ok(result);
    }

    [HttpGet("global/current")]
    public async Task<ActionResult<BudgetCurrentDto>> GetGlobalCurrent([FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _budgetService.GetCurrentAsync(Guid.Empty, viewAsHostId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost("global")]
    public async Task<ActionResult<BudgetCurrentDto>> CreateOrUpdateGlobal([FromBody] CreateBudgetRequest request)
    {
        var result = await _budgetService.CreateOrUpdateAsync(Guid.Empty, request.BudgetAmount, request.PeriodStartDay, request.PeriodStartDate, request.PeriodEndDate, request.CategoryId);
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
