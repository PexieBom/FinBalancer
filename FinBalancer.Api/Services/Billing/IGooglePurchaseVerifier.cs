using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub interface for Google Play purchase verification.
/// Full implementation will call Google Play Developer API purchases.subscriptions.get.
/// </summary>
public interface IGooglePurchaseVerifier
{
    /// <summary>
    /// Verifies a Google Play purchase and returns normalized purchase data, or null if invalid.
    /// </summary>
    Task<PurchaseVerificationResult?> VerifyAsync(string purchaseToken, string productId, string? orderId = null, CancellationToken ct = default);
}
