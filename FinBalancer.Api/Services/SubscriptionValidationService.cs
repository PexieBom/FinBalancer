using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

/// <summary>
/// Validates subscriptions with Apple App Store and Google Play.
/// In development: accepts valid-looking data. In production: call real store APIs.
/// </summary>
public class SubscriptionValidationService : ISubscriptionValidationService
{
    private readonly ISubscriptionPlanRepository _planRepo;
    private readonly IConfiguration _config;

    public SubscriptionValidationService(ISubscriptionPlanRepository planRepo, IConfiguration config)
    {
        _planRepo = planRepo;
        _config = config;
    }

    public async Task<(bool isValid, DateTime? expiresAt)> ValidateAppleReceiptAsync(string receiptData, string productId)
    {
        if (string.IsNullOrWhiteSpace(receiptData)) return (false, null);

        var plan = await _planRepo.GetByProductIdAsync(productId);
        if (plan == null) return (false, null);

        var useRealValidation = _config.GetValue<bool>("Subscriptions:UseRealValidation");
        if (!useRealValidation)
        {
            // Development: accept and grant 1 month
            return (true, DateTime.UtcNow.AddMonths(1));
        }

        // Production: call Apple verifyReceipt API
        // https://developer.apple.com/documentation/appstorereceipts/verifyreceipt
        return await ValidateAppleReceiptProductionAsync(receiptData, productId);
    }

    public async Task<(bool isValid, DateTime? expiresAt)> ValidateGooglePurchaseAsync(string purchaseToken, string productId, string? orderId = null)
    {
        if (string.IsNullOrWhiteSpace(purchaseToken)) return (false, null);

        var plan = await _planRepo.GetByProductIdAsync(productId);
        if (plan == null) return (false, null);

        var useRealValidation = _config.GetValue<bool>("Subscriptions:UseRealValidation");
        if (!useRealValidation)
        {
            return (true, DateTime.UtcNow.AddMonths(1));
        }

        return await ValidateGooglePurchaseProductionAsync(purchaseToken, productId, orderId);
    }

    private static async Task<(bool isValid, DateTime? expiresAt)> ValidateAppleReceiptProductionAsync(string receiptData, string productId)
    {
        // TODO: Implement Apple receipt verification
        // Use HttpClient to POST to https://buy.itunes.apple.com/verifyReceipt (prod) or https://sandbox.itunes.apple.com/verifyReceipt (sandbox)
        // Body: { "receipt-data": "<base64>", "password": "<shared_secret>" }
        // Parse response for latest_receipt_info or in_app, find expires_date_ms for the product
        await Task.CompletedTask;
        return (false, null);
    }

    private static async Task<(bool isValid, DateTime? expiresAt)> ValidateGooglePurchaseProductionAsync(string purchaseToken, string productId, string? orderId)
    {
        // TODO: Implement Google Play Developer API
        // Use Google.Apis.AndroidPublisher.v3 to call purchases.subscriptions.get
        // Package name + subscriptionId + token
        await Task.CompletedTask;
        return (false, null);
    }
}
