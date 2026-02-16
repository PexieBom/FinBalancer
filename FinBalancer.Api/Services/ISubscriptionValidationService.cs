namespace FinBalancer.Api.Services;

public interface ISubscriptionValidationService
{
    /// <summary>Validates Apple receipt and returns expiration date if valid.</summary>
    Task<(bool isValid, DateTime? expiresAt)> ValidateAppleReceiptAsync(string receiptData, string productId);

    /// <summary>Validates Google Play purchase and returns expiration date if valid.</summary>
    Task<(bool isValid, DateTime? expiresAt)> ValidateGooglePurchaseAsync(string purchaseToken, string productId, string? orderId = null);
}
