using System.Security.Cryptography;
using FinBalancer.Api.Data;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Services;
using FinBalancer.Api.Services.Billing;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/webhooks")]
public class WebhookController : ControllerBase
{
    private readonly IWebhookVerifier _appleVerifier;
    private readonly IWebhookVerifier _googleVerifier;
    private readonly IWebhookVerifier _paypalVerifier;
    private readonly IWebhookEventRepository _webhookEvents;
    private readonly ISubscriptionPurchaseRepository _purchases;
    private readonly BillingService _billingService;

    public WebhookController(
        StubAppleWebhookVerifier appleVerifier,
        StubGoogleWebhookVerifier googleVerifier,
        StubPayPalWebhookVerifier paypalVerifier,
        IWebhookEventRepository webhookEvents,
        ISubscriptionPurchaseRepository purchases,
        BillingService billingService)
    {
        _appleVerifier = appleVerifier;
        _googleVerifier = googleVerifier;
        _paypalVerifier = paypalVerifier;
        _webhookEvents = webhookEvents;
        _purchases = purchases;
        _billingService = billingService;
    }

    [HttpPost("apple")]
    public Task<IActionResult> Apple() => ProcessWebhookAsync(_appleVerifier, "apple");

    [HttpPost("google")]
    public Task<IActionResult> Google() => ProcessWebhookAsync(_googleVerifier, "google");

    [HttpPost("paypal")]
    public Task<IActionResult> PayPal() => ProcessWebhookAsync(_paypalVerifier, "paypal");

    private async Task<IActionResult> ProcessWebhookAsync(IWebhookVerifier verifier, string platform)
    {
        Request.EnableBuffering();
        using var ms = new MemoryStream();
        await Request.Body.CopyToAsync(ms);
        var body = ms.ToArray();
        Request.Body.Position = 0;

        using var bodyStream = new MemoryStream(body);
        var parsed = await verifier.VerifyAndParseAsync(bodyStream, Request.Headers);
        if (parsed == null)
            return BadRequest("Verification failed");

        if (await _webhookEvents.ExistsAsync(platform, parsed.EventId))
            return Ok();

        var userId = parsed.UserId;
        if (!userId.HasValue)
        {
            var existing = await _purchases.GetByPlatformAndExternalIdAsync(platform, parsed.ExternalId);
            if (existing == null)
                return BadRequest("Unknown subscription, cannot resolve user");
            userId = existing.UserId;
        }

        var purchase = await _purchases.GetByPlatformAndExternalIdAsync(platform, parsed.ExternalId);
        if (purchase != null)
        {
            purchase.Status = parsed.Status;
            purchase.EndTime = parsed.EndTime;
            purchase.RawPayload = parsed.RawPayload;
            purchase.UpdatedAt = DateTime.UtcNow;
            await _purchases.UpdateAsync(purchase);
        }
        else
        {
            await _purchases.AddAsync(new SubscriptionPurchaseEntity
            {
                UserId = userId!.Value,
                Platform = platform,
                ProductCode = parsed.ProductCode,
                ExternalId = parsed.ExternalId,
                Status = parsed.Status,
                StartTime = parsed.StartTime,
                EndTime = parsed.EndTime,
                RawPayload = parsed.RawPayload,
                AutoRenew = true
            });
        }

        await _billingService.RecomputeEntitlementAsync(userId!.Value);

        await _webhookEvents.AddAsync(new WebhookEventEntity
        {
            Provider = platform,
            EventId = parsed.EventId,
            PayloadHash = ComputeSha256Hash(body)
        });

        return Ok();
    }

    private static string ComputeSha256Hash(byte[] data)
    {
        var hash = SHA256.HashData(data);
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}
