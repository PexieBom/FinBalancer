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
    public async Task<ActionResult<List<Transaction>>> Get()
    {
        var transactions = await _transactionService.GetTransactionsAsync();
        return Ok(transactions.OrderByDescending(t => t.DateCreated).ToList());
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
