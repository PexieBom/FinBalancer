using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Repositories.Json;

public class JsonWalletBudgetRepository : IWalletBudgetRepository
{
    private const string FileName = "wallet_budgets.json";
    private readonly JsonStorageService _storage;

    public JsonWalletBudgetRepository(JsonStorageService storage)
    {
        _storage = storage;
    }

    public async Task<WalletBudget?> GetByIdAsync(Guid id)
    {
        var list = await _storage.ReadJsonAsync<WalletBudget>(FileName);
        return list.FirstOrDefault(b => b.Id == id);
    }

    public async Task<WalletBudget?> GetByWalletIdAsync(Guid walletId)
    {
        var list = await _storage.ReadJsonAsync<WalletBudget>(FileName);
        return list.FirstOrDefault(b => b.WalletId == walletId);
    }

    public async Task<WalletBudget?> GetByWalletIdAndUserIdAsync(Guid walletId, Guid userId)
    {
        var list = await _storage.ReadJsonAsync<WalletBudget>(FileName);
        return list.FirstOrDefault(b => b.WalletId == walletId && b.UserId == userId);
    }

    public async Task<WalletBudget> CreateAsync(WalletBudget budget)
    {
        budget.Id = Guid.NewGuid();
        budget.CreatedAt = DateTime.UtcNow;
        budget.UpdatedAt = DateTime.UtcNow;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
            list.Add(budget);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return budget;
    }

    public async Task<WalletBudget> UpdateAsync(WalletBudget budget)
    {
        budget.UpdatedAt = DateTime.UtcNow;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
            var idx = list.FindIndex(b => b.Id == budget.Id);
            if (idx < 0) throw new InvalidOperationException("Budget not found");
            list[idx] = budget;
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return budget;
    }

    public async Task<WalletBudget> UpsertAsync(WalletBudget budget)
    {
        budget.UpdatedAt = DateTime.UtcNow;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
            var existing = list.FirstOrDefault(b => b.WalletId == budget.WalletId && b.UserId == budget.UserId);
            if (existing != null)
            {
                budget.Id = existing.Id;
                budget.CreatedAt = existing.CreatedAt;
                budget.IsMain = existing.IsMain;
                list.Remove(existing);
            }
            else
            {
                budget.Id = Guid.NewGuid();
                budget.CreatedAt = DateTime.UtcNow;
            }
            list.Add(budget);
            await _storage.WriteJsonUnsafeAsync(FileName, list);
        });
        return budget;
    }

    public async Task<bool> DeleteByIdAsync(Guid id)
    {
        var deleted = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
            var idx = list.FindIndex(b => b.Id == id);
            if (idx >= 0)
            {
                list.RemoveAt(idx);
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                deleted = true;
            }
        });
        return deleted;
    }

    public async Task<bool> DeleteByWalletIdAsync(Guid walletId)
    {
        var deleted = false;
        await _storage.ExecuteInLockAsync(FileName, async () =>
        {
            var list = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
            var index = list.FindIndex(b => b.WalletId == walletId);
            if (index >= 0)
            {
                list.RemoveAt(index);
                await _storage.WriteJsonUnsafeAsync(FileName, list);
                deleted = true;
            }
        });
        return deleted;
    }

    public async Task<List<WalletBudget>> GetAllAsync()
    {
        return await _storage.ReadJsonAsync<WalletBudget>(FileName);
    }

    public async Task<List<WalletBudget>> GetAllByUserIdAsync(Guid userId)
    {
        var list = await _storage.ReadJsonAsync<WalletBudget>(FileName);
        var userBudgets = list.Where(b => b.UserId == userId).ToList();
        if (userBudgets.Count > 0 && !userBudgets.Any(b => b.IsMain))
        {
            await _storage.ExecuteInLockAsync(FileName, async () =>
            {
                var full = await _storage.ReadJsonUnsafeAsync<WalletBudget>(FileName);
                var first = full.Where(b => b.UserId == userId).OrderBy(b => b.CreatedAt).FirstOrDefault();
                if (first != null)
                {
                    first.IsMain = true;
                    var idx = full.FindIndex(b => b.Id == first.Id);
                    if (idx >= 0) full[idx] = first;
                    await _storage.WriteJsonUnsafeAsync(FileName, full);
                }
            });
            list = await _storage.ReadJsonAsync<WalletBudget>(FileName);
            userBudgets = list.Where(b => b.UserId == userId).ToList();
        }
        return userBudgets;
    }
}
