using FinBalancer.Api.Services;
using FinBalancer.Api.Services.Billing;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BillingController : ControllerBase
{
    private readonly BillingService _billingService;
    private readonly ICurrentUserService _currentUser;

    public BillingController(BillingService billingService, ICurrentUserService currentUser)
    {
        _billingService = billingService;
        _currentUser = currentUser;
    }

    /// <summary>Returns server-authoritative premium entitlement.</summary>
    [HttpGet("entitlement")]
    public async Task<ActionResult<EntitlementDto>> GetEntitlement()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue)
            return Ok(new EntitlementDto(false, null, null, DateTime.UtcNow));

        var e = await _billingService.GetEntitlementAsync(userId.Value);
        return Ok(new EntitlementDto(
            e.IsPremium,
            e.PremiumUntil,
            e.SourcePlatform,
            DateTime.UtcNow));
    }

    /// <summary>Confirms a mobile (iOS/Android) purchase and updates entitlement.</summary>
    [HttpPost("mobile/confirm")]
    public async Task<ActionResult<EntitlementDto>> ConfirmMobile([FromBody] MobileConfirmRequest request)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return Unauthorized();

        var ent = await _billingService.ConfirmMobilePurchaseAsync(
            userId.Value,
            request.Platform ?? "",
            request.ProductCode ?? "",
            request.StoreProductId,
            request.PurchaseToken,
            request.ReceiptData,
            request.OrderId);
        if (ent == null) return BadRequest("Verification failed");
        return Ok(new EntitlementDto(ent.IsPremium, ent.PremiumUntil, ent.SourcePlatform, DateTime.UtcNow));
    }

    /// <summary>Creates a PayPal subscription and returns approval URL.</summary>
    [HttpPost("paypal/create-subscription")]
    public async Task<ActionResult<PayPalCreateResponse>> CreatePayPalSubscription([FromBody] PayPalCreateRequest request)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return Unauthorized();

        var (approvalUrl, subscriptionId) = await _billingService.CreatePayPalSubscriptionAsync(
            userId.Value,
            request.ProductCode ?? "",
            request.PayPalPlanId,
            request.ReturnUrl ?? "",
            request.CancelUrl ?? "");
        if (string.IsNullOrEmpty(approvalUrl) || string.IsNullOrEmpty(subscriptionId))
            return BadRequest("Could not create PayPal subscription");
        return Ok(new PayPalCreateResponse(approvalUrl, subscriptionId));
    }

    /// <summary>Confirms a PayPal subscription after user approval.</summary>
    [HttpPost("paypal/confirm")]
    public async Task<ActionResult<EntitlementDto>> ConfirmPayPal([FromBody] PayPalConfirmRequest request)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return Unauthorized();
        if (string.IsNullOrEmpty(request.SubscriptionId)) return BadRequest("SubscriptionId required");

        var ent = await _billingService.ConfirmPayPalSubscriptionAsync(
            userId.Value,
            request.SubscriptionId,
            request.ProductCode ?? "");
        if (ent == null) return BadRequest("Verification failed");
        return Ok(new EntitlementDto(ent.IsPremium, ent.PremiumUntil, ent.SourcePlatform, DateTime.UtcNow));
    }
}

public record EntitlementDto(bool IsPremium, DateTime? PremiumUntil, string? SourcePlatform, DateTime ServerTimeUtc);
public record MobileConfirmRequest(string Platform, string ProductCode, string? StoreProductId, string? PurchaseToken, string? ReceiptData, string? OrderId);
public record PayPalCreateRequest(string ProductCode, string? PayPalPlanId, string ReturnUrl, string CancelUrl);
public record PayPalCreateResponse(string ApprovalUrl, string PayPalSubscriptionId);
public record PayPalConfirmRequest(string SubscriptionId, string ProductCode);
