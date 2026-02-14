using FinBalancer.Api.Models;
using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WalletsController : ControllerBase
{
    private readonly WalletService _walletService;

    public WalletsController(WalletService walletService)
    {
        _walletService = walletService;
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
        return CreatedAtAction(nameof(Get), created);
    }
}
