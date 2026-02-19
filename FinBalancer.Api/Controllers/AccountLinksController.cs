using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AccountLinksController : ControllerBase
{
    private readonly AccountLinkService _accountLinkService;

    public AccountLinksController(AccountLinkService accountLinkService)
    {
        _accountLinkService = accountLinkService;
    }

    /// <summary>Pozovi drugog korisnika po emailu da može pregledavati tvoje podatke (host poziva gosta).</summary>
    [HttpPost("invite")]
    public async Task<ActionResult<object>> Invite([FromBody] InviteRequest request)
    {
        if (string.IsNullOrWhiteSpace(request?.GuestEmail))
            return BadRequest(new { errorCode = "GuestEmailRequired" });

        var result = await _accountLinkService.InviteByEmailAsync(request.GuestEmail);
        if (!result.Success)
            return result.ErrorCode switch
            {
                "Unauthorized" => Unauthorized(),
                "GuestNotFound" => NotFound(new { errorCode = result.ErrorCode, message = "Korisnik s tim emailom nije pronađen." }),
                "CannotInviteSelf" => BadRequest(new { errorCode = result.ErrorCode }),
                "AlreadyLinked" => BadRequest(new { errorCode = result.ErrorCode, message = "Račun je već povezan." }),
                "AlreadyPending" => BadRequest(new { errorCode = result.ErrorCode, message = "Pozivnica je već poslana." }),
                "RevokedPreviously" => BadRequest(new { errorCode = result.ErrorCode }),
                _ => BadRequest(new { errorCode = result.ErrorCode })
            };

        return Ok(new
        {
            linkId = result.Link!.Id,
            guestUserId = result.Link.GuestUserId,
            guestDisplayName = result.GuestDisplayName,
            status = result.Link.Status.ToString(),
            invitedAt = result.Link.InvitedAt
        });
    }

    /// <summary>Lista svih veza (kao host i kao guest).</summary>
    [HttpGet]
    public async Task<ActionResult<List<AccountLinkDto>>> List()
    {
        var list = await _accountLinkService.ListForCurrentUserAsync();
        return Ok(list);
    }

    /// <summary>Lista hostova čije podatke možeš pregledavati (za izbor "pregledaj kao").</summary>
    [HttpGet("linked-hosts")]
    public async Task<ActionResult<List<LinkedHostDto>>> GetLinkedHosts()
    {
        var list = await _accountLinkService.GetLinkedHostsForCurrentUserAsync();
        return Ok(list);
    }

    /// <summary>Prihvati pozivnicu (samo guest).</summary>
    [HttpPost("{id:guid}/accept")]
    public async Task<ActionResult<object>> Accept(Guid id)
    {
        var link = await _accountLinkService.AcceptAsync(id);
        if (link == null)
            return NotFound();
        return Ok(new { linkId = link.Id, status = link.Status.ToString() });
    }

    /// <summary>Opozovi vezu (host ili guest).</summary>
    [HttpPost("{id:guid}/revoke")]
    public async Task<IActionResult> Revoke(Guid id)
    {
        var ok = await _accountLinkService.RevokeAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }
}

public class InviteRequest
{
    public string? GuestEmail { get; set; }
}
