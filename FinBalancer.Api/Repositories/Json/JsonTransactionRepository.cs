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

    public async Task<List<Transaction>> GetAllByUserIdAsync(Guid userId)
    {
        var items = await _storage.ReadJsonAsync<Transaction>(FileName);
        return items.Where(t => t.UserId == userId).ToList();
    }

    public async Task<List<Transaction>> GetByUserIdPagedAsync(Guid userId, DateTime? dateFrom, DateTime? dateTo, Guid? walletId, string? tag, string? project, Guid? categoryId, int limit, int offset)
    {
        var items = await _storage.ReadJsonAsync<Transaction>(FileName);
        var filtered = items.Where(t => t.UserId == userId).AsEnumerable();
        if (dateFrom.HasValue)
            filtered = filtered.Where(t => t.DateCreated.Date >= dateFrom.Value.Date);
        if (dateTo.HasValue)
            filtered = filtered.Where(t => t.DateCreated.Date <= dateTo.Value.Date);
        if (walletId.HasValue)
            filtered = filtered.Where(t => t.WalletId == walletId.Value);
        if (!string.IsNullOrEmpty(tag))
            filtered = filtered.Where(t => t.Tags?.Contains(tag) == true);
        if (!string.IsNullOrEmpty(project))
            filtered = filtered.Where(t => t.Project == project);
        if (categoryId.HasValue)
            filtered = filtered.Where(t => t.CategoryId == categoryId.Value);

        return filtered
            .OrderByDescending(t => t.DateCreated)
            .Skip(offset)
            .Take(limit)
            .ToList();
    }

    public async Task<Transaction?> GetByIdAsync(Guid id)
    {
        var items = await _storage.ReadJsonAsync<Transaction>(FileName);
        return items.FirstOrDefault(t => t.Id == id);
    }

    public async Task<Transaction?> GetByIdAndUserIdAsync(Guid id, Guid userId)
    {
        var items = await _storage.ReadJsonAsync<Transaction>(FileName);
        return items.FirstOrDefault(t => t.Id == id && t.UserId == userId);
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
