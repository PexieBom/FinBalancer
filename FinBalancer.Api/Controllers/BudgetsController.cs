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

    /// <summary>Creates a new budget. Free: 1 max. Premium: unlimited.</summary>
    [HttpPost]
    public async Task<ActionResult<BudgetCurrentDto>> Create([FromBody] CreateBudgetRequest request, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var walletId = request.WalletId ?? Guid.Empty;
        var (dto, errorCode) = await _budgetService.CreateAsync(
            walletId,
            request.BudgetAmount,
            request.PeriodStartDay,
            request.PeriodStartDate,
            request.PeriodEndDate,
            request.CategoryId);
        if (errorCode == "BudgetLimitExceeded")
            return BadRequest(new { errorCode });
        if (dto == null) return Unauthorized();
        return Ok(dto);
    }

    /// <summary>Gets current state of a specific budget.</summary>
    [HttpGet("{id:guid}/current")]
    public async Task<ActionResult<BudgetCurrentDto>> GetCurrentById(Guid id, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _budgetService.GetCurrentByBudgetIdAsync(id, viewAsHostId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    /// <summary>Updates a budget.</summary>
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<BudgetCurrentDto>> Update(Guid id, [FromBody] UpdateBudgetRequest request)
    {
        var result = await _budgetService.UpdateAsync(
            id,
            request.BudgetAmount,
            request.PeriodStartDay,
            request.PeriodStartDate,
            request.PeriodEndDate,
            request.CategoryId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    /// <summary>Deletes a budget.</summary>
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await _budgetService.DeleteByIdAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    /// <summary>Sets a budget as main (shown on dashboard).</summary>
    [HttpPost("{id:guid}/main")]
    public async Task<IActionResult> SetMain(Guid id)
    {
        var ok = await _budgetService.SetMainAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }
}
