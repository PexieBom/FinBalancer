using System.Text.Json;
using FinBalancer.Api.Data;
using FinBalancer.Api.Infrastructure;
using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;
using Microsoft.EntityFrameworkCore;

namespace FinBalancer.Api.Repositories.Db;

public class DbTransactionRepository : ITransactionRepository
{
    private readonly FinBalancerDbContext _db;

    public DbTransactionRepository(FinBalancerDbContext db)
    {
        _db = db;
    }

    public async Task<List<Transaction>> GetAllAsync()
    {
        var entities = await _db.Transactions.ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Transaction>> GetAllByUserIdAsync(Guid userId)
    {
        var entities = await _db.Transactions.Where(t => t.UserId == userId).ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<List<Transaction>> GetByUserIdPagedAsync(Guid userId, DateTime? dateFrom, DateTime? dateTo, Guid? walletId, string? tag, string? project, Guid? categoryId, int limit, int offset)
    {
        var query = _db.Transactions.Where(t => t.UserId == userId);
        if (dateFrom.HasValue)
        {
            var fromUtc = DateTimeUtils.ToUtc(dateFrom.Value).Date;
            query = query.Where(t => t.DateCreated >= fromUtc);
        }
        if (dateTo.HasValue)
        {
            var toUtc = DateTimeUtils.ToUtc(dateTo.Value).Date.AddDays(1);
            query = query.Where(t => t.DateCreated < toUtc);
        }
        if (walletId.HasValue)
            query = query.Where(t => t.WalletId == walletId.Value);
        if (!string.IsNullOrEmpty(tag))
            query = query.Where(t => t.Tags != null && t.Tags.Contains(tag));
        if (!string.IsNullOrEmpty(project))
            query = query.Where(t => t.Project == project);
        if (categoryId.HasValue)
            query = query.Where(t => t.CategoryId == categoryId.Value);

        var entities = await query
            .OrderByDescending(t => t.DateCreated)
            .Skip(offset)
            .Take(limit)
            .ToListAsync();
        return entities.Select(ToModel).ToList();
    }

    public async Task<Transaction?> GetByIdAsync(Guid id)
    {
        var e = await _db.Transactions.FindAsync(id);
        return e == null ? null : ToModel(e);
    }

    public async Task<Transaction?> GetByIdAndUserIdAsync(Guid id, Guid userId)
    {
        var e = await _db.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
        return e == null ? null : ToModel(e);
    }

    public async Task<Transaction> AddAsync(Transaction transaction)
    {
        var e = ToEntity(transaction);
        _db.Transactions.Add(e);
        await _db.SaveChangesAsync();
        return ToModel(e);
    }

    public async Task<bool> UpdateAsync(Transaction transaction)
    {
        var e = await _db.Transactions.FindAsync(transaction.Id);
        if (e == null) return false;
        e.Amount = transaction.Amount;
        e.Type = transaction.Type;
        e.CategoryId = transaction.CategoryId;
        e.SubcategoryId = transaction.SubcategoryId;
        e.WalletId = transaction.WalletId;
        e.Note = transaction.Note;
        e.Tags = transaction.Tags?.Count > 0 ? JsonSerializer.Serialize(transaction.Tags) : null;
        e.Project = transaction.Project;
        e.ProjectId = transaction.ProjectId;
        e.DateCreated = DateTimeUtils.ToUtc(transaction.DateCreated);
        e.IsYearlyExpense = transaction.IsYearlyExpense;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var e = await _db.Transactions.FindAsync(id);
        if (e == null) return false;
        _db.Transactions.Remove(e);
        await _db.SaveChangesAsync();
        return true;
    }

    private static Transaction ToModel(TransactionEntity e)
    {
        var tags = new List<string>();
        if (!string.IsNullOrEmpty(e.Tags))
        {
            try
            {
                var deserialized = JsonSerializer.Deserialize<List<string>>(e.Tags);
                if (deserialized != null) tags = deserialized;
            }
            catch { /* ignore */ }
        }
        return new Transaction
        {
            Id = e.Id,
            UserId = e.UserId,
            Amount = e.Amount,
            Type = e.Type,
            CategoryId = e.CategoryId,
            SubcategoryId = e.SubcategoryId,
            WalletId = e.WalletId,
            Note = e.Note,
            Tags = tags,
            Project = e.Project,
            ProjectId = e.ProjectId,
            DateCreated = e.DateCreated,
            IsYearlyExpense = e.IsYearlyExpense
        };
    }

    private static TransactionEntity ToEntity(Transaction m)
    {
        return new TransactionEntity
        {
            Id = m.Id,
            UserId = m.UserId,
            Amount = m.Amount,
            Type = m.Type,
            CategoryId = m.CategoryId,
            SubcategoryId = m.SubcategoryId,
            WalletId = m.WalletId,
            Note = m.Note,
            Tags = m.Tags?.Count > 0 ? JsonSerializer.Serialize(m.Tags) : null,
            Project = m.Project,
            ProjectId = m.ProjectId,
            DateCreated = DateTimeUtils.ToUtc(m.DateCreated),
            IsYearlyExpense = m.IsYearlyExpense
        };
    }
}
