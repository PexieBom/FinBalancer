using FinBalancer.Api.Data;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using FinBalancer.Api.Services.Billing;

namespace FinBalancer.Api.Services;

public class BillingService
{
    private readonly ISubscriptionPurchaseRepository _purchaseRepo;
    private readonly IUserEntitlementRepository _entitlementRepo;
    private readonly ISubscriptionPlanRepository _planRepo;
    private readonly IApplePurchaseVerifier _appleVerifier;
    private readonly IGooglePurchaseVerifier _googleVerifier;
    private readonly IPayPalPurchaseVerifier _paypalVerifier;

    public BillingService(
        ISubscriptionPurchaseRepository purchaseRepo,
        IUserEntitlementRepository entitlementRepo,
        ISubscriptionPlanRepository planRepo,
        IApplePurchaseVerifier appleVerifier,
        IGooglePurchaseVerifier googleVerifier,
        IPayPalPurchaseVerifier paypalVerifier)
    {
        _purchaseRepo = purchaseRepo;
        _entitlementRepo = entitlementRepo;
        _planRepo = planRepo;
        _appleVerifier = appleVerifier;
        _googleVerifier = googleVerifier;
        _paypalVerifier = paypalVerifier;
    }

    /// <summary>Confirms mobile purchase and returns entitlement, or null if verification fails.</summary>
    public async Task<UserEntitlementEntity?> ConfirmMobilePurchaseAsync(Guid userId, string platform, string productCode, string? storeProductId, string? purchaseToken, string? receiptData, string? orderId)
    {
        var plat = platform.ToLowerInvariant();
        if (plat is not "apple" and not "google") return null;

        var plan = await _planRepo.GetByProductIdAsync(productCode)
            ?? await _planRepo.GetByPlatformProductIdAsync(plat, storeProductId ?? "");
        if (plan == null) return null;

        PurchaseVerificationResult? verification = plat == "apple"
            ? await _appleVerifier.VerifyAsync(receiptData ?? purchaseToken ?? "", plan.AppleProductId ?? plan.ProductId)
            : await _googleVerifier.VerifyAsync(purchaseToken ?? "", plan.GoogleProductId ?? plan.ProductId, orderId);
        if (verification == null) return null;

        var externalId = verification.ExternalId;
        var existing = await _purchaseRepo.GetByPlatformAndExternalIdAsync(plat, externalId);
        if (existing != null)
        {
            existing.Status = verification.Status;
            existing.EndTime = verification.EndTime;
            existing.RawPayload = verification.RawPayload;
            existing.AutoRenew = verification.AutoRenew;
            existing.CancelReason = verification.CancelReason;
            existing.UpdatedAt = DateTime.UtcNow;
            await _purchaseRepo.UpdateAsync(existing);
        }
        else
        {
            await _purchaseRepo.AddAsync(new SubscriptionPurchaseEntity
            {
                UserId = userId,
                Platform = plat,
                ProductCode = plan.ProductId,
                ExternalId = externalId,
                Status = verification.Status,
                StartTime = verification.StartTime,
                EndTime = verification.EndTime,
                RawPayload = verification.RawPayload,
                AutoRenew = true
            });
        }
        await RecomputeEntitlementAsync(userId);
        return await GetEntitlementAsync(userId);
    }

    /// <summary>Creates PayPal subscription, returns (approvalUrl, subscriptionId) or (null, null).</summary>
    public async Task<(string? ApprovalUrl, string? SubscriptionId)> CreatePayPalSubscriptionAsync(Guid userId, string productCode, string? paypalPlanId, string returnUrl, string cancelUrl)
    {
        var plan = await _planRepo.GetByProductIdAsync(productCode)
            ?? (string.IsNullOrEmpty(paypalPlanId) ? null : await _planRepo.GetByPlatformProductIdAsync("paypal", paypalPlanId));
        if (plan == null) return (null, null);
        var planId = plan.PayPalPlanId ?? plan.ProductId;
        return await _paypalVerifier.CreateSubscriptionAsync(planId, userId, returnUrl, cancelUrl);
    }

    /// <summary>Confirms PayPal subscription and returns entitlement, or null if verification fails.</summary>
    public async Task<UserEntitlementEntity?> ConfirmPayPalSubscriptionAsync(Guid userId, string subscriptionId, string productCode)
    {
        var plan = await _planRepo.GetByProductIdAsync(productCode);
        if (plan == null) return null;
        var planId = plan.PayPalPlanId ?? plan.ProductId;
        var verification = await _paypalVerifier.VerifyAsync(subscriptionId, planId);
        if (verification == null) return null;

        var existing = await _purchaseRepo.GetByPlatformAndExternalIdAsync("paypal", verification.ExternalId);
        if (existing != null)
        {
            existing.Status = verification.Status;
            existing.EndTime = verification.EndTime;
            existing.RawPayload = verification.RawPayload;
            existing.UpdatedAt = DateTime.UtcNow;
            await _purchaseRepo.UpdateAsync(existing);
        }
        else
        {
            await _purchaseRepo.AddAsync(new SubscriptionPurchaseEntity
            {
                UserId = userId,
                Platform = "paypal",
                ProductCode = plan.ProductId,
                ExternalId = verification.ExternalId,
                Status = verification.Status,
                StartTime = verification.StartTime,
                EndTime = verification.EndTime,
                RawPayload = verification.RawPayload,
                AutoRenew = true
            });
        }
        await RecomputeEntitlementAsync(userId);
        return await GetEntitlementAsync(userId);
    }

    /// <summary>
    /// Recomputes the user's entitlement based on active subscription purchases.
    /// Writes to user_entitlements.
    /// </summary>
    public async Task RecomputeEntitlementAsync(Guid userId)
    {
        var active = await _purchaseRepo.GetActiveByUserIdAsync(userId);
        var best = active
            .Where(p => p.Status == "active" || p.Status == "grace")
            .OrderByDescending(p => p.EndTime ?? DateTime.MaxValue)
            .FirstOrDefault();

        var entity = new UserEntitlementEntity
        {
            UserId = userId,
            IsPremium = best != null,
            PremiumUntil = best?.EndTime,
            SourcePlatform = best?.Platform,
            UpdatedAt = DateTime.UtcNow
        };
        await _entitlementRepo.UpsertAsync(entity);
    }

    /// <summary>
    /// Returns the current entitlement for the user (from user_entitlements).
    /// If not found, returns a non-premium entitlement.
    /// </summary>
    public async Task<UserEntitlementEntity> GetEntitlementAsync(Guid userId)
    {
        var e = await _entitlementRepo.GetByUserIdAsync(userId);
        if (e != null) return e;
        return new UserEntitlementEntity
        {
            UserId = userId,
            IsPremium = false,
            PremiumUntil = null,
            SourcePlatform = null,
            UpdatedAt = DateTime.UtcNow
        };
    }
}
