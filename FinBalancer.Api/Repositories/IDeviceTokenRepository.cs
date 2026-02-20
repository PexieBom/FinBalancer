namespace FinBalancer.Api.Repositories;

public interface IDeviceTokenRepository
{
    Task RegisterAsync(Guid userId, string token, string platform);
    Task<List<string>> GetTokensForUserAsync(Guid userId);
    Task RemoveByTokenAsync(string token);
}
