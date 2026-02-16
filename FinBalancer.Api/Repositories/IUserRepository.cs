using FinBalancer.Api.Models;

namespace FinBalancer.Api.Repositories;

public interface IUserRepository
{
    Task<User?> GetFirstOrDefaultAsync();
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByEmailAsync(string email);
    Task<User?> GetByGoogleIdAsync(string googleId);
    Task<User?> GetByAppleIdAsync(string appleId);
    Task<User> AddAsync(User user);
    Task<bool> UpdateAsync(User user);
}
