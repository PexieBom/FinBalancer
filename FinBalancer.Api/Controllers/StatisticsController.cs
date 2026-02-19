using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StatisticsController : ControllerBase
{
    private readonly StatisticsService _statisticsService;
    private readonly AdvancedStatisticsService _advancedStatisticsService;
    private readonly AccountLinkService _accountLinkService;
    private readonly ICurrentUserService _currentUser;

    public StatisticsController(
        StatisticsService statisticsService,
        AdvancedStatisticsService advancedStatisticsService,
        AccountLinkService accountLinkService,
        ICurrentUserService currentUser)
    {
        _statisticsService = statisticsService;
        _advancedStatisticsService = advancedStatisticsService;
        _accountLinkService = accountLinkService;
        _currentUser = currentUser;
    }

    [HttpGet("spending-by-category")]
    public async Task<ActionResult<SpendingByCategoryDto>> GetSpendingByCategory(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _statisticsService.GetSpendingByCategoryAsync(walletId, dateFrom, dateTo, viewAsHostId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("income-expense-summary")]
    public async Task<ActionResult<IncomeExpenseSummaryDto>> GetIncomeExpenseSummary(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _statisticsService.GetIncomeExpenseSummaryAsync(walletId, dateFrom, dateTo, viewAsHostId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("budget-prediction")]
    public async Task<ActionResult<BudgetPredictionDto>> GetBudgetPrediction([FromQuery] Guid? walletId, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _advancedStatisticsService.GetBudgetPredictionAsync(walletId, viewAsHostId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("budget-alerts")]
    public async Task<ActionResult<List<BudgetAlertDto>>> GetBudgetAlerts([FromQuery] Guid? walletId, [FromQuery] Guid? viewAsHostId)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _advancedStatisticsService.GetBudgetAlertsAsync(walletId, viewAsHostId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("cashflow-trend")]
    public async Task<ActionResult<TrendDataDto>> GetCashflowTrend(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo, [FromQuery] int months = 6, [FromQuery] Guid? viewAsHostId = null)
    {
        if (viewAsHostId.HasValue)
        {
            var userId = _currentUser.UserId;
            if (!userId.HasValue) return Unauthorized();
            if (!await _accountLinkService.CanGuestViewHostAsync(userId.Value, viewAsHostId.Value))
                return Forbid();
        }
        var result = await _advancedStatisticsService.GetCashflowTrendAsync(walletId, months, dateFrom, dateTo, viewAsHostId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }
}
