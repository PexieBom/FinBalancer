using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonTransactionRepository : ITransactionRepository
{
    private const string FileName = "transactions.json";
    private readonly JsonStorageService _storage;

    public JsonTransactionRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<List<Transaction>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<Transaction>(FileName);
    }

    public async Task<Transaction?> GetByIdAsync(Guid id)
    {
        var items = await _storage.ReadJsonAsync<Transaction>(FileName);
        return items.FirstOrDefault(t => t.Id == id);
    }

    public async Task<Transaction> AddAsync(Transaction transaction)
    {
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Transaction>(FileName);
            list.Add(transaction);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return transaction;
    }

    public async Task<bool> UpdateAsync(Transaction transaction)
    {
        var updated = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Transaction>(FileName);
            var index = list.FindIndex(t => t.Id == transaction.Id);
            if (index >= 0)
            {
                list[index] = transaction;
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                updated = true;
            }
        });
        return updated;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var deleted = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<Transaction>(FileName);
            var index = list.FindIndex(t => t.Id == id);
            if (index >= 0)
            {
                list.RemoveAt(index);
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                deleted = true;
            }
        });
        return deleted;
    }
}
