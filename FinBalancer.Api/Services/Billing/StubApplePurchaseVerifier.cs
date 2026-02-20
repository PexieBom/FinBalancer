using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub implementation - returns null. Replace with real Apple verifyReceipt integration.
/// </summary>
public class StubApplePurchaseVerifier : IApplePurchaseVerifier
{
    public Task<PurchaseVerificationResult?> VerifyAsync(string receiptData, string productId, CancellationToken ct = default)
        => Task.FromResult<PurchaseVerificationResult?>(null);
}
