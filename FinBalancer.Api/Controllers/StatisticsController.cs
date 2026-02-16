using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StatisticsController : ControllerBase
{
    private readonly StatisticsService _statisticsService;
    private readonly AdvancedStatisticsService _advancedStatisticsService;

    public StatisticsController(
        StatisticsService statisticsService,
        AdvancedStatisticsService advancedStatisticsService)
    {
        _statisticsService = statisticsService;
        _advancedStatisticsService = advancedStatisticsService;
    }

    [HttpGet("spending-by-category")]
    public async Task<ActionResult<SpendingByCategoryDto>> GetSpendingByCategory(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo)
    {
        var result = await _statisticsService.GetSpendingByCategoryAsync(walletId, dateFrom, dateTo);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("income-expense-summary")]
    public async Task<ActionResult<IncomeExpenseSummaryDto>> GetIncomeExpenseSummary(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo)
    {
        var result = await _statisticsService.GetIncomeExpenseSummaryAsync(walletId, dateFrom, dateTo);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("budget-prediction")]
    public async Task<ActionResult<BudgetPredictionDto>> GetBudgetPrediction([FromQuery] Guid? walletId)
    {
        var result = await _advancedStatisticsService.GetBudgetPredictionAsync(walletId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("budget-alerts")]
    public async Task<ActionResult<List<BudgetAlertDto>>> GetBudgetAlerts([FromQuery] Guid? walletId)
    {
        var result = await _advancedStatisticsService.GetBudgetAlertsAsync(walletId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpGet("cashflow-trend")]
    public async Task<ActionResult<TrendDataDto>> GetCashflowTrend(
        [FromQuery] Guid? walletId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo, [FromQuery] int months = 6)
    {
        var result = await _advancedStatisticsService.GetCashflowTrendAsync(walletId, months, dateFrom, dateTo);
        if (result == null) return Unauthorized();
        return Ok(result);
    }
}
