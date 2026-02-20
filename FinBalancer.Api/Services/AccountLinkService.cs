using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class AccountLinkService
{
    private readonly IAccountLinkRepository _linkRepository;
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly InAppNotificationService _notificationService;

    public AccountLinkService(
        IAccountLinkRepository linkRepository,
        IUserRepository userRepository,
        ICurrentUserService currentUser,
        InAppNotificationService notificationService)
    {
        _linkRepository = linkRepository;
        _userRepository = userRepository;
        _currentUser = currentUser;
        _notificationService = notificationService;
    }

    /// <summary>Provjerava može li trenutni korisnik (kao guest) pregledavati podatke hosta.</summary>
    public async Task<bool> CanGuestViewHostAsync(Guid guestUserId, Guid hostUserId)
    {
        if (guestUserId == hostUserId) return true;
        var link = await _linkRepository.GetByHostAndGuestAsync(hostUserId, guestUserId);
        return link != null && link.Status == AccountLinkStatus.Accepted;
    }

    /// <summary>Host poziva gosta po emailu. Gost mora imati račun.</summary>
    public async Task<AccountLinkInviteResult> InviteByEmailAsync(string guestEmail)
    {
        var hostUserId = _currentUser.UserId;
        if (!hostUserId.HasValue)
            return AccountLinkInviteResult.Unauthorized();

        var guest = await _userRepository.GetByEmailAsync(guestEmail.Trim());
        if (guest == null)
            return AccountLinkInviteResult.GuestNotFound();

        if (guest.Id == hostUserId.Value)
            return AccountLinkInviteResult.CannotInviteSelf();

        var existing = await _linkRepository.GetByHostAndGuestAsync(hostUserId.Value, guest.Id);
        AccountLink link;
        if (existing != null)
        {
            if (existing.Status == AccountLinkStatus.Accepted)
                return AccountLinkInviteResult.AlreadyLinked();
            if (existing.Status == AccountLinkStatus.Pending)
                return AccountLinkInviteResult.AlreadyPending();
            if (existing.Status == AccountLinkStatus.Revoked)
            {
                existing.Status = AccountLinkStatus.Pending;
                existing.InvitedAt = DateTime.UtcNow;
                existing.RespondedAt = null;
                await _linkRepository.UpdateAsync(existing);
                link = existing;
            }
            else
                return AccountLinkInviteResult.RevokedPreviously();
        }
        else
        {
            link = new AccountLink
            {
                Id = Guid.NewGuid(),
                HostUserId = hostUserId.Value,
                GuestUserId = guest.Id,
                Status = AccountLinkStatus.Pending,
                InvitedAt = DateTime.UtcNow,
                RespondedAt = null
            };
            await _linkRepository.AddAsync(link);
        }
        var hostUser = await _userRepository.GetByIdAsync(hostUserId.Value);
        await _notificationService.NotifyAccountLinkInviteAsync(guest.Id, hostUser?.DisplayName ?? hostUser?.Email ?? "Neko", link.Id);
        return AccountLinkInviteResult.Ok(link, guest.DisplayName);
    }

    /// <summary>Lista svih veza za trenutnog korisnika (kao host i kao guest).</summary>
    public async Task<List<AccountLinkDto>> ListForCurrentUserAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return new List<AccountLinkDto>();

        var asHost = await _linkRepository.GetByHostUserIdAsync(userId.Value);
        var asGuest = await _linkRepository.GetByGuestUserIdAsync(userId.Value);
        var allLinkIds = asHost.Concat(asGuest).Select(l => l.Id).Distinct().ToList();
        var links = asHost.Concat(asGuest).DistinctBy(l => l.Id).ToList();

        var result = new List<AccountLinkDto>();
        foreach (var link in links)
        {
            var isHost = link.HostUserId == userId;
            var otherId = isHost ? link.GuestUserId : link.HostUserId;
            var other = await _userRepository.GetByIdAsync(otherId);
            result.Add(new AccountLinkDto
            {
                Id = link.Id,
                HostUserId = link.HostUserId,
                GuestUserId = link.GuestUserId,
                Status = link.Status,
                InvitedAt = link.InvitedAt,
                RespondedAt = link.RespondedAt,
                IsCurrentUserHost = isHost,
                OtherUserId = otherId,
                OtherDisplayName = other?.DisplayName ?? other?.Email ?? "?",
                OtherEmail = other?.Email
            });
        }
        return result.OrderByDescending(x => x.InvitedAt).ToList();
    }

    /// <summary>Lista hostova čije podatke trenutni korisnik (kao guest) može pregledavati.</summary>
    public async Task<List<LinkedHostDto>> GetLinkedHostsForCurrentUserAsync()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return new List<LinkedHostDto>();

        var accepted = await _linkRepository.GetAcceptedByGuestUserIdAsync(userId.Value);
        var result = new List<LinkedHostDto>();
        foreach (var link in accepted)
        {
            var host = await _userRepository.GetByIdAsync(link.HostUserId);
            result.Add(new LinkedHostDto
            {
                HostUserId = link.HostUserId,
                DisplayName = host?.DisplayName ?? host?.Email ?? "?",
                Email = host?.Email,
                LinkedAt = link.RespondedAt ?? link.InvitedAt
            });
        }
        return result.OrderByDescending(x => x.LinkedAt).ToList();
    }

    /// <summary>Guest prihvaća pozivnicu.</summary>
    public async Task<AccountLink?> AcceptAsync(Guid linkId)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        var link = await _linkRepository.GetByIdAsync(linkId);
        if (link == null || link.GuestUserId != userId.Value || link.Status != AccountLinkStatus.Pending)
            return null;

        link.Status = AccountLinkStatus.Accepted;
        link.RespondedAt = DateTime.UtcNow;
        await _linkRepository.UpdateAsync(link);
        return link;
    }

    /// <summary>Host ili guest opoziva vezu.</summary>
    public async Task<bool> RevokeAsync(Guid linkId)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;

        var link = await _linkRepository.GetByIdAsync(linkId);
        if (link == null) return false;
        if (link.HostUserId != userId.Value && link.GuestUserId != userId.Value)
            return false;

        link.Status = AccountLinkStatus.Revoked;
        link.RespondedAt = DateTime.UtcNow;
        return await _linkRepository.UpdateAsync(link);
    }
}

public class AccountLinkDto
{
    public Guid Id { get; set; }
    public Guid HostUserId { get; set; }
    public Guid GuestUserId { get; set; }
    public AccountLinkStatus Status { get; set; }
    public DateTime InvitedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
    public bool IsCurrentUserHost { get; set; }
    public Guid OtherUserId { get; set; }
    public string OtherDisplayName { get; set; } = string.Empty;
    public string? OtherEmail { get; set; }
}

public class LinkedHostDto
{
    public Guid HostUserId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public DateTime LinkedAt { get; set; }
}

public class AccountLinkInviteResult
{
    public bool Success { get; set; }
    public AccountLink? Link { get; set; }
    public string? GuestDisplayName { get; set; }
    public string? ErrorCode { get; set; }

    public static AccountLinkInviteResult Ok(AccountLink link, string guestDisplayName) =>
        new() { Success = true, Link = link, GuestDisplayName = guestDisplayName };

    public static AccountLinkInviteResult Unauthorized() =>
        new() { Success = false, ErrorCode = "Unauthorized" };

    public static AccountLinkInviteResult GuestNotFound() =>
        new() { Success = false, ErrorCode = "GuestNotFound" };

    public static AccountLinkInviteResult CannotInviteSelf() =>
        new() { Success = false, ErrorCode = "CannotInviteSelf" };

    public static AccountLinkInviteResult AlreadyLinked() =>
        new() { Success = false, ErrorCode = "AlreadyLinked" };

    public static AccountLinkInviteResult AlreadyPending() =>
        new() { Success = false, ErrorCode = "AlreadyPending" };

    public static AccountLinkInviteResult RevokedPreviously() =>
        new() { Success = false, ErrorCode = "RevokedPreviously" };
}
