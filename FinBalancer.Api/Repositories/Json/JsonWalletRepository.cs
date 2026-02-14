using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonWalletRepository : IWalletRepository
{
    private const string FileName = "wallets.json";
    private readonly JsonStorageService _storage;

    public JsonWalletRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Wallet>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Wallet>(FileName);
    }

    public async Task<Wallet?> GetByIdAsync(Guid id)
    {
        var items = await _storage.ReadJsonAsync<Wallet>(FileName);
        return items.FirstOrDefault(w => w.Id == id);
    }

    public async Task<Wallet> AddAsync(Wallet wallet)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Wallet>(FileName);
            list.Add(wallet);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return wallet;
    }

    public async Task<bool> UpdateAsync(Wallet wallet)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Wallet>(FileName);
            var index = list.FindIndex(w => w.Id == wallet.Id);
            if (index >= 0)
            {
                list[index] = wallet;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }
}
