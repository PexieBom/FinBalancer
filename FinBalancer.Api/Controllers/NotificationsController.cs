using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly InAppNotificationService _notificationService;

    public NotificationsController(InAppNotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet]
    public async Task<ActionResult<List<InAppNotificationDto>>> List([FromQuery] int limit = 50)
    {
        var list = await _notificationService.GetForCurrentUserAsync(limit);
        return Ok(list);
    }

    [HttpGet("unread-count")]
    public async Task<ActionResult<int>> UnreadCount()
    {
        var count = await _notificationService.GetUnreadCountAsync();
        return Ok(count);
    }

    [HttpPost("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        await _notificationService.MarkAsReadAsync(id);
        return NoContent();
    }

    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        await _notificationService.MarkAllAsReadAsync();
        return NoContent();
    }
}
