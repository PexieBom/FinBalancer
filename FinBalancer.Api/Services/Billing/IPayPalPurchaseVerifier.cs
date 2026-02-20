using FinBalancer.Api.Models;

namespace FinBalancer.Api.Services.Billing;

/// <summary>
/// Stub interface for PayPal subscription verification.
/// Full implementation will call PayPal Subscriptions API.
/// </summary>
public interface IPayPalPurchaseVerifier
{
    /// <summary>
    /// Creates a PayPal subscription and returns approval URL + subscription ID.
    /// </summary>
    Task<(string? ApprovalUrl, string? SubscriptionId)> CreateSubscriptionAsync(string planId, Guid userId, string returnUrl, string cancelUrl, CancellationToken ct = default);

    /// <summary>
    /// Verifies a PayPal subscription and returns normalized purchase data, or null if invalid.
    /// </summary>
    Task<PurchaseVerificationResult?> VerifyAsync(string subscriptionId, string planId, CancellationToken ct = default);
}
