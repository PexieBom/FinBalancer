using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StatisticsController : ControllerBase
{
    private readonly StatisticsService _statisticsService;

    public StatisticsController(StatisticsService statisticsService)
    {
        _statisticsService = statisticsService;
    }

    [HttpGet("spending-by-category")]
    public async Task<ActionResult<SpendingByCategoryDto>> GetSpendingByCategory([FromQuery] Guid? walletId)
    {
        var result = await _statisticsService.GetSpendingByCategoryAsync(walletId);
        return Ok(result);
    }

    [HttpGet("income-expense-summary")]
    public async Task<ActionResult<IncomeExpenseSummaryDto>> GetIncomeExpenseSummary([FromQuery] Guid? walletId)
    {
        var result = await _statisticsService.GetIncomeExpenseSummaryAsync(walletId);
        return Ok(result);
    }
}
