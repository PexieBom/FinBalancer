using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub implementation - returns null. Replace with real PayPal Subscriptions API integration.
/// </summary>
public class StubPayPalPurchaseVerifier : IPayPalPurchaseVerifier
{
    public Task<(string? ApprovalUrl, string? SubscriptionId)> CreateSubscriptionAsync(string planId, Guid userId, string returnUrl, string cancelUrl, CancellationToken ct = default)
        => Task.FromResult<(string?, string?)>((null, null));

    public Task<PurchaseVerificationResult?> VerifyAsync(string subscriptionId, string planId, CancellationToken ct = default)
        => Task.FromResult<PurchaseVerificationResult?>(null);
}
