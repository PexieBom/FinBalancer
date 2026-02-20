using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub implementation - returns null. Replace with real Google Play API integration.
/// </summary>
public class StubGooglePurchaseVerifier : IGooglePurchaseVerifier
{
    public Task<PurchaseVerificationResult?> VerifyAsync(string purchaseToken, string productId, string? orderId = null, CancellationToken ct = default)
        => Task.FromResult<PurchaseVerificationResult?>(null);
}
