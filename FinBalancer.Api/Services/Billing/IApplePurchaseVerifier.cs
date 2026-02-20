using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub interface for Apple App Store receipt verification.
/// Full implementation will call Apple verifyReceipt API.
/// </summary>
public interface IApplePurchaseVerifier
{
    /// <summary>
    /// Verifies an Apple receipt and returns normalized purchase data, or null if invalid.
    /// </summary>
    Task<PurchaseVerificationResult?> VerifyAsync(string receiptData, string productId, CancellationToken ct = default);
}
