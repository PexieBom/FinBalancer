using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class InAppNotificationService
{
    private readonly IInAppNotificationRepository _repository;
    private readonly ICurrentUserService _currentUser;
    private readonly PushNotificationService _pushService;

    public InAppNotificationService(
        IInAppNotificationRepository repository,
        ICurrentUserService currentUser,
        PushNotificationService pushService)
    {
        _repository = repository;
        _currentUser = currentUser;
        _pushService = pushService;
    }

    public async Task<List<InAppNotificationDto>> GetForCurrentUserAsync(int limit = 50)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return new List<InAppNotificationDto>();

        var list = await _repository.GetByUserIdAsync(userId.Value, limit);
        return list.Select(Map).ToList();
    }

    public async Task<int> GetUnreadCountAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return 0;
        return await _repository.GetUnreadCountAsync(userId.Value);
    }

    public async Task MarkAsReadAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return;

        var n = await _repository.GetByIdAsync(id);
        if (n != null && n.UserId == userId.Value)
            await _repository.MarkAsReadAsync(id);
    }

    public async Task MarkAllAsReadAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return;
        await _repository.MarkAllAsReadAsync(userId.Value);
    }

    /// <summary>Kreira obavijest za gosta kada host pošalje pozivnicu.</summary>
    public async Task NotifyAccountLinkInviteAsync(Guid guestUserId, string hostDisplayName, Guid linkId)
    {
        var n = new InAppNotification
        {
            Id = Guid.NewGuid(),
            UserId = guestUserId,
            Type = "AccountLinkInvite",
            Title = "Nova pozivnica",
            Body = $"{hostDisplayName} vas je pozvao/la da pregledate njegove/njene podatke.",
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
            RelatedId = linkId.ToString(),
            ActionRoute = "/linked-accounts"
        };
        await _repository.AddAsync(n);
        _ = _pushService.SendToUserAsync(guestUserId, n.Title, n.Body, n.ActionRoute);
    }

    private static InAppNotificationDto Map(InAppNotification n) => new()
    {
        Id = n.Id,
        Type = n.Type,
        Title = n.Title,
        Body = n.Body,
        IsRead = n.IsRead,
        CreatedAt = n.CreatedAt,
        RelatedId = n.RelatedId,
        ActionRoute = n.ActionRoute
    };
}

public class InAppNotificationDto
{
    public Guid Id { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? RelatedId { get; set; }
    public string? ActionRoute { get; set; }
}
