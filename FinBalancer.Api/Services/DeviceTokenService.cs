using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class DeviceTokenService
{
    private readonly IDeviceTokenRepository _repository;
    private readonly ICurrentUserService _currentUser;

    public DeviceTokenService(IDeviceTokenRepository repository, ICurrentUserService currentUser)
    {
        _repository = repository;
        _currentUser = currentUser;
    }

    public async Task RegisterAsync(string token, string platform)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return;

        await _repository.RegisterAsync(userId.Value, token.Trim(), platform);
    }

    public async Task UnregisterAsync(string token)
    {
        await _repository.RemoveByTokenAsync(token.Trim());
    }
}
