using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly TransactionService _transactionService;

    public TransactionsController(TransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpGet]
    public async Task<ActionResult<List<Transaction>>> Get(
        [FromQuery] string? tag,
        [FromQuery] string? project,
        [FromQuery] Guid? walletId)
    {
        var transactions = await _transactionService.GetTransactionsAsync();

        if (!string.IsNullOrEmpty(tag))
            transactions = transactions.Where(t => t.Tags?.Contains(tag) == true).ToList();
        if (!string.IsNullOrEmpty(project))
            transactions = transactions.Where(t => t.Project == project).ToList();
        if (walletId.HasValue)
            transactions = transactions.Where(t => t.WalletId == walletId).ToList();

        return Ok(transactions.OrderByDescending(t => t.DateCreated).ToList());
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<Transaction>> Put(Guid id, [FromBody] Transaction transaction)
    {
        if (id != transaction.Id) return BadRequest();
        var updated = await _transactionService.UpdateTransactionAsync(transaction);
        return updated != null ? Ok(updated) : NotFound();
    }

    [HttpPost]
    public async Task<ActionResult<Transaction>> Post([FromBody] Transaction transaction)
    {
        if (transaction.Amount <= 0)
            return BadRequest("Amount must be positive");

        if (transaction.Type is not "income" and not "expense")
            return BadRequest("Type must be 'income' or 'expense'");

        var result = await _transactionService.AddTransactionAsync(transaction);
        if (result == null)
            return BadRequest("Wallet not found");

        return CreatedAtAction(nameof(Get), result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var deleted = await _transactionService.DeleteTransactionAsync(id);
        if (!deleted)
            return NotFound();
        return NoContent();
    }
}
