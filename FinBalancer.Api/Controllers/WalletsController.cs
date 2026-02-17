using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WalletsController : ControllerBase
{
    private readonly WalletService _walletService;
    private readonly BudgetService _budgetService;

    public WalletsController(WalletService walletService, BudgetService budgetService)
    {
        _walletService = walletService;
        _budgetService = budgetService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Wallet>>> Get()
    {
        var wallets = await _walletService.GetWalletsAsync();
        return Ok(wallets);
    }

    [HttpPost]
    public async Task<ActionResult<Wallet>> Post([FromBody] Wallet wallet)
    {
        if (string.IsNullOrWhiteSpace(wallet.Name))
            return BadRequest("Name is required");

        var created = await _walletService.AddWalletAsync(wallet);
        if (created == null) return Unauthorized();
        return CreatedAtAction(nameof(Get), created);
    }

    [HttpPut("{id:guid}/main")]
    public async Task<ActionResult<Wallet>> SetMain(Guid id)
    {
        var updated = await _walletService.SetMainWalletAsync(id);
        if (updated == null) return NotFound();
        return Ok(updated);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<Wallet>> Put(Guid id, [FromBody] Wallet wallet)
    {
        if (id != wallet.Id) return BadRequest();
        var updated = await _walletService.UpdateWalletAsync(wallet);
        if (updated == null) return NotFound();
        return Ok(updated);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await _walletService.DeleteWalletAsync(id);
        if (!deleted) return NotFound();
        return NoContent();
    }

    [HttpGet("{walletId:guid}/budget/current")]
    public async Task<ActionResult<BudgetCurrentDto>> GetBudgetCurrent(Guid walletId)
    {
        var result = await _budgetService.GetCurrentAsync(walletId);
        if (result == null) return NotFound();
        return Ok(result);
    }

    [HttpPost("{walletId:guid}/budget")]
    public async Task<ActionResult<BudgetCurrentDto>> CreateOrUpdateBudget(
        Guid walletId,
        [FromBody] CreateBudgetRequest request)
    {
        var wallet = await _walletService.GetByIdAsync(walletId);
        if (wallet == null) return NotFound("Wallet not found");
        var result = await _budgetService.CreateOrUpdateAsync(
            walletId,
            request.BudgetAmount,
            request.PeriodStartDay,
            request.PeriodStartDate,
            request.PeriodEndDate,
            request.CategoryId);
        if (result == null) return Unauthorized();
        return Ok(result);
    }

    [HttpDelete("{walletId:guid}/budget")]
    public async Task<IActionResult> DeleteBudget(Guid walletId)
    {
        var deleted = await _budgetService.DeleteAsync(walletId);
        if (!deleted) return NotFound();
        return NoContent();
    }
}

public record CreateBudgetRequest(decimal BudgetAmount, int PeriodStartDay = 1, DateTime? PeriodStartDate = null, DateTime? PeriodEndDate = null, Guid? CategoryId = null);
