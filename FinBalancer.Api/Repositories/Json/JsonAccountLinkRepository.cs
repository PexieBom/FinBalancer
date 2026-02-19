using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonAccountLinkRepository : IAccountLinkRepository
{
    private const string FileName = "account_links.json";
    private readonly JsonStorageService _storage;

    public JsonAccountLinkRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<AccountLink?> GetByIdAsync(Guid id)
    {
        var list = await _storage.ReadJsonAsync<AccountLink>(FileName);
        return list.FirstOrDefault(l => l.Id == id);
    }

    public async Task<List<AccountLink>> GetByHostUserIdAsync(Guid hostUserId)
    {
        var list = await _storage.ReadJsonAsync<AccountLink>(FileName);
        return list.Where(l => l.HostUserId == hostUserId).ToList();
    }

    public async Task<List<AccountLink>> GetByGuestUserIdAsync(Guid guestUserId)
    {
        var list = await _storage.ReadJsonAsync<AccountLink>(FileName);
        return list.Where(l => l.GuestUserId == guestUserId).ToList();
    }

    public async Task<List<AccountLink>> GetAcceptedByGuestUserIdAsync(Guid guestUserId)
    {
        var list = await _storage.ReadJsonAsync<AccountLink>(FileName);
        return list.Where(l => l.GuestUserId == guestUserId && l.Status == AccountLinkStatus.Accepted).ToList();
    }

    public async Task<AccountLink?> GetByHostAndGuestAsync(Guid hostUserId, Guid guestUserId)
    {
        var list = await _storage.ReadJsonAsync<AccountLink>(FileName);
        return list.FirstOrDefault(l => l.HostUserId == hostUserId && l.GuestUserId == guestUserId);
    }

    public async Task<AccountLink> AddAsync(AccountLink link)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<AccountLink>(FileName);
            list.Add(link);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return link;
    }

    public async Task<bool> UpdateAsync(AccountLink link)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<AccountLink>(FileName);
            var index = list.FindIndex(l => l.Id == link.Id);
            if (index >= 0)
            {
                list[index] = link;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }
}
