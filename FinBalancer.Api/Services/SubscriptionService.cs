using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class SubscriptionService
{
    private readonly ISubscriptionRepository _subscriptionRepo;
    private readonly ISubscriptionPlanRepository _planRepo;
    private readonly ISubscriptionValidationService _validationService;

    public SubscriptionService(
        ISubscriptionRepository subscriptionRepo,
        ISubscriptionPlanRepository planRepo,
        ISubscriptionValidationService validationService)
    {
        _subscriptionRepo = subscriptionRepo;
        _planRepo = planRepo;
        _validationService = validationService;
    }

    public async Task<SubscriptionStatusDto> GetStatusAsync(Guid userId)
    {
        var active = await _subscriptionRepo.GetActiveByUserIdAsync(userId);
        if (active != null)
        {
            return new SubscriptionStatusDto(true, active.ExpiresAt, active.ProductId, active.Platform);
        }
        return new SubscriptionStatusDto(false, null, null, null);
    }

    public async Task<List<SubscriptionPlanDto>> GetPlansAsync()
    {
        var plans = await _planRepo.GetAllAsync();
        return plans.Select(p => new SubscriptionPlanDto(
            p.Id,
            p.Name,
            p.ProductId,
            p.AppleProductId ?? p.ProductId,
            p.GoogleProductId ?? p.ProductId,
            p.Duration,
            p.Price,
            p.Currency)).ToList();
    }

    public async Task<SubscriptionStatusDto?> ValidateAndActivateAsync(Guid userId, ValidatePurchaseRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Platform) || string.IsNullOrWhiteSpace(request.ProductId))
            return null;

        var (isValid, expiresAt) = request.Platform.ToLowerInvariant() switch
        {
            "apple" => await _validationService.ValidateAppleReceiptAsync(
                request.ReceiptData ?? request.PurchaseToken ?? "", request.ProductId),
            "google" => await _validationService.ValidateGooglePurchaseAsync(
                request.PurchaseToken ?? "", request.ProductId, request.OrderId),
            _ => (false, (DateTime?)null)
        };

        if (!isValid || !expiresAt.HasValue) return null;

        var existing = await _subscriptionRepo.GetByPurchaseTokenAsync(
            request.Platform, request.PurchaseToken ?? request.ReceiptData ?? "");

        if (existing != null)
        {
            existing.Status = "active";
            existing.ExpiresAt = expiresAt.Value;
            existing.UpdatedAt = DateTime.UtcNow;
            await _subscriptionRepo.UpdateAsync(existing);
            return new SubscriptionStatusDto(true, existing.ExpiresAt, existing.ProductId, existing.Platform);
        }

        var subscription = new UserSubscription
        {
            UserId = userId,
            Platform = request.Platform.ToLowerInvariant(),
            ProductId = request.ProductId,
            PurchaseToken = request.PurchaseToken ?? request.ReceiptData ?? "",
            Status = "active",
            ExpiresAt = expiresAt.Value,
            ReceiptData = request.Platform.Equals("apple", StringComparison.OrdinalIgnoreCase) ? request.ReceiptData : null,
            OrderId = request.OrderId
        };
        await _subscriptionRepo.AddAsync(subscription);
        return new SubscriptionStatusDto(true, subscription.ExpiresAt, subscription.ProductId, subscription.Platform);
    }

    /// <summary>For webhooks: update subscription status from store notifications.</summary>
    public async Task ProcessStoreNotificationAsync(string platform, Dictionary<string, string> payload)
    {
        // Apple: NOTIFICATION_TYPE = SUBSCRIBED, DID_RENEW, EXPIRED, etc.
        // Google: subscriptionNotification message
        await Task.CompletedTask;
    }
}

public record SubscriptionStatusDto(bool IsPremium, DateTime? ExpiresAt, string? ProductId, string? Platform);

public record SubscriptionPlanDto(Guid Id, string Name, string ProductId, string AppleProductId, string GoogleProductId, string Duration, decimal Price, string Currency);

public record ValidatePurchaseRequest(string Platform, string ProductId, string? PurchaseToken, string? ReceiptData, string? OrderId);
