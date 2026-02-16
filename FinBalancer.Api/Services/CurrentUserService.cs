namespace FinBalancer.Api.Services;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid? UserId
    {
        get
        {
            var ctx = _httpContextAccessor.HttpContext;
            if (ctx?.Items.TryGetValue("UserId", out var val) == true && val is Guid g)
                return g;
            return null;
        }
    }
}
