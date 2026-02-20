using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Services.Billing;

namespace FinBalancer.Api.Services;

/// <summary>
/// Re-verifies active/grace subscriptions with providers and fixes entitlement if webhooks were missed.
/// Safe to rerun, idempotent.
/// </summary>
public class SubscriptionReconciliationService
{
    private readonly ISubscriptionPurchaseRepository _purchases;
    private readonly ISubscriptionPlanRepository _plans;
    private readonly IApplePurchaseVerifier _appleVerifier;
    private readonly IGooglePurchaseVerifier _googleVerifier;
    private readonly IPayPalPurchaseVerifier _paypalVerifier;
    private readonly BillingService _billingService;

    public SubscriptionReconciliationService(
        ISubscriptionPurchaseRepository purchases,
        ISubscriptionPlanRepository plans,
        IApplePurchaseVerifier appleVerifier,
        IGooglePurchaseVerifier googleVerifier,
        IPayPalPurchaseVerifier paypalVerifier,
        BillingService billingService)
    {
        _purchases = purchases;
        _plans = plans;
        _appleVerifier = appleVerifier;
        _googleVerifier = googleVerifier;
        _paypalVerifier = paypalVerifier;
        _billingService = billingService;
    }

    public async Task RunAsync(CancellationToken ct = default)
    {
        var list = await _purchases.GetActiveAndGraceForReconciliationAsync();
        var now = DateTime.UtcNow;

        foreach (var p in list)
        {
            if (p.EndTime.HasValue && p.EndTime.Value < now)
            {
                p.Status = "expired";
                p.UpdatedAt = now;
                await _purchases.UpdateAsync(p);
                await _billingService.RecomputeEntitlementAsync(p.UserId);
                continue;
            }

            var plan = await _plans.GetByProductIdAsync(p.ProductCode);
            if (plan == null) continue;

            PurchaseVerificationResult? result = null;
            if (p.Platform == "paypal")
                result = await _paypalVerifier.VerifyAsync(p.ExternalId, plan.PayPalPlanId ?? plan.ProductId, ct);
            else if (p.Platform == "google")
                result = await _googleVerifier.VerifyAsync(p.ExternalId, plan.GoogleProductId ?? plan.ProductId, null, ct);
            else if (p.Platform == "apple")
            {
                var receiptData = ExtractReceiptFromPayload(p.RawPayload);
                if (!string.IsNullOrEmpty(receiptData))
                    result = await _appleVerifier.VerifyAsync(receiptData, plan.AppleProductId ?? plan.ProductId, ct);
            }

            if (result != null && (result.Status != p.Status || result.EndTime != p.EndTime))
            {
                p.Status = result.Status;
                p.EndTime = result.EndTime;
                p.RawPayload = result.RawPayload;
                p.AutoRenew = result.AutoRenew;
                p.CancelReason = result.CancelReason;
                p.UpdatedAt = now;
                await _purchases.UpdateAsync(p);
                await _billingService.RecomputeEntitlementAsync(p.UserId);
            }
        }
    }

    private static string? ExtractReceiptFromPayload(string? rawPayload)
    {
        if (string.IsNullOrEmpty(rawPayload)) return null;
        try
        {
            var doc = System.Text.Json.JsonDocument.Parse(rawPayload);
            if (doc.RootElement.TryGetProperty("receiptData", out var r)) return r.GetString();
            if (doc.RootElement.TryGetProperty("receipt_data", out var rd)) return rd.GetString();
        }
        catch { }
        return null;
    }
}
