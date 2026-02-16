using FinBalancer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace FinBalancer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SubscriptionsController : ControllerBase
{
    private readonly SubscriptionService _subscriptionService;
    private readonly ICurrentUserService _currentUser;

    public SubscriptionsController(SubscriptionService subscriptionService, ICurrentUserService currentUser)
    {
        _subscriptionService = subscriptionService;
        _currentUser = currentUser;
    }

    /// <summary>Get current user's subscription status.</summary>
    [HttpGet("status")]
    public async Task<ActionResult<SubscriptionStatusDto>> GetStatus()
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue || userId.Value == Guid.Empty)
            return Ok(new SubscriptionStatusDto(false, null, null, null));
        var status = await _subscriptionService.GetStatusAsync(userId.Value);
        return Ok(status);
    }

    /// <summary>Get available subscription plans (product IDs for App Store / Google Play).</summary>
    [HttpGet("plans")]
    public async Task<ActionResult<List<SubscriptionPlanDto>>> GetPlans()
    {
        var plans = await _subscriptionService.GetPlansAsync();
        return Ok(plans);
    }

    /// <summary>Validate purchase from App Store or Google Play and activate subscription.</summary>
    [HttpPost("validate")]
    public async Task<ActionResult<SubscriptionStatusDto>> ValidatePurchase([FromBody] ValidatePurchaseRequest request)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return Unauthorized();
        var status = await _subscriptionService.ValidateAndActivateAsync(userId.Value, request);
        if (status == null) return BadRequest("Invalid purchase or validation failed");
        return Ok(status);
    }
}
