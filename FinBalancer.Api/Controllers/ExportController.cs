using System.Net;
using System.Text;
using System.Text.Json;
using FinBalancer.Api.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ExportController : ControllerBase
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly IWalletRepository _walletRepository;

    public ExportController(
        ITransactionRepository transactionRepository,
        IWalletRepository walletRepository)
    {
        _transactionRepository = transactionRepository;
        _walletRepository = walletRepository;
    }

    [HttpGet("csv")]
    public async Task<IActionResult> ExportCsv([FromQuery] Guid? walletId)
    {
        var transactions = await _transactionRepository.GetAllAsync();
        var filtered = walletId.HasValue
            ? transactions.Where(t => t.WalletId == walletId).ToList()
            : transactions;

        var sb = new StringBuilder();
        sb.AppendLine("Date,Type,Amount,Note,Tags,Project");
        foreach (var t in filtered.OrderByDescending(t => t.DateCreated))
        {
            sb.AppendLine($"{t.DateCreated:yyyy-MM-dd},{t.Type},{t.Amount},\"{t.Note ?? ""}\",\"{string.Join(",", t.Tags ?? new List<string>())}\",\"{t.Project ?? ""}\"");
        }

        var bytes = Encoding.UTF8.GetBytes(sb.ToString());
        return File(bytes, "text/csv", $"finbalancer_export_{DateTime.UtcNow:yyyyMMdd}.csv");
    }

    [HttpGet("json")]
    public async Task<IActionResult> ExportJson([FromQuery] Guid? walletId)
    {
        var transactions = await _transactionRepository.GetAllAsync();
        var wallets = await _walletRepository.GetAllAsync();

        var filtered = walletId.HasValue
            ? transactions.Where(t => t.WalletId == walletId).ToList()
            : transactions;

        var data = new
        {
            ExportDate = DateTime.UtcNow,
            Wallets = wallets,
            Transactions = filtered
        };

        var json = JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true, PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        var bytes = Encoding.UTF8.GetBytes(json);
        return File(bytes, "application/json", $"finbalancer_export_{DateTime.UtcNow:yyyyMMdd}.json");
    }

    [HttpGet("pdf")]
    public async Task<IActionResult> ExportPdf([FromQuery] Guid? walletId)
    {
        var transactions = await _transactionRepository.GetAllAsync();
        var filtered = walletId.HasValue
            ? transactions.Where(t => t.WalletId == walletId).ToList()
            : transactions;

        var html = new StringBuilder();
        html.Append("<html><head><meta charset='utf-8'><title>FinBalancer Export</title>");
        html.Append("<style>body{font-family:sans-serif;margin:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #ddd;padding:8px}th{background:#f5f5f5}</style></head><body>");
        html.Append($"<h1>FinBalancer Export</h1><p>Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm}</p>");
        html.Append($"<p>Transactions: {filtered.Count}</p>");
        html.Append("<table><tr><th>Date</th><th>Type</th><th>Amount</th><th>Note</th></tr>");
        foreach (var t in filtered.OrderByDescending(t => t.DateCreated).Take(100))
        {
            html.Append($"<tr><td>{t.DateCreated:yyyy-MM-dd}</td><td>{t.Type}</td><td>{t.Amount}</td><td>{WebUtility.HtmlEncode(t.Note ?? "")}</td></tr>");
        }
        html.Append("</table></body></html>");

        var bytes = Encoding.UTF8.GetBytes(html.ToString());
        return File(bytes, "text/html", $"finbalancer_export_{DateTime.UtcNow:yyyyMMdd}.html");
    }
}
