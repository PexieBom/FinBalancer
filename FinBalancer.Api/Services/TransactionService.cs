using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class TransactionService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly IWalletRepository _walletRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly AccountLinkService _accountLinkService;

    public TransactionService(
        ITransactionRepository transactionRepository,
        IWalletRepository walletRepository,
        ICurrentUserService currentUser,
        AccountLinkService accountLinkService)
    {
        _transactionRepository = transactionRepository;
        _walletRepository = walletRepository;
        _currentUser = currentUser;
        _accountLinkService = accountLinkService;
    }

    /// <param name="viewAsHostId">Ako je setiran, trenutni korisnik mora biti guest tog hosta da vidi njegove podatke.</param>
    public async Task<List<Transaction>> GetTransactionsAsync(Guid? viewAsHostId = null)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return new List<Transaction>();
        return await _transactionRepository.GetAllByUserIdAsync(userId.Value);
    }

    /// <summary>Paginated transactions with filters. Used for dashboard list.</summary>
    public async Task<List<Transaction>> GetTransactionsPagedAsync(Guid? viewAsHostId, DateTime? dateFrom, DateTime? dateTo, Guid? walletId, string? tag, string? project, Guid? categoryId, int limit, int offset)
    {
        var userId = await ResolveEffectiveUserIdForReadAsync(viewAsHostId);
        if (!userId.HasValue) return new List<Transaction>();
        return await _transactionRepository.GetByUserIdPagedAsync(userId.Value, dateFrom, dateTo, walletId, tag, project, categoryId, limit, offset);
    }

    private async Task<Guid?> ResolveEffectiveUserIdForReadAsync(Guid? viewAsHostId)
    {
        var current = _currentUser.UserId;
        if (!current.HasValue) return null;
        if (!viewAsHostId.HasValue) return current;
        if (viewAsHostId.Value == current.Value) return current;
        var canView = await _accountLinkService.CanGuestViewHostAsync(current.Value, viewAsHostId.Value);
        return canView ? viewAsHostId : null;
    }

    public async Task<Transaction?> AddTransactionAsync(Transaction transaction)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        transaction.Id = Guid.NewGuid();
        transaction.DateCreated = DateTime.UtcNow;
        transaction.UserId = userId.Value;

        var wallet = await _walletRepository.GetByIdAndUserIdAsync(transaction.WalletId, userId.Value);
        if (wallet == null)
            return null;

        if (transaction.Type == "income")
            wallet.Balance += transaction.Amount;
        else if (transaction.Type == "expense")
            wallet.Balance -= transaction.Amount;

        await _walletRepository.UpdateAsync(wallet);
        await _transactionRepository.AddAsync(transaction);
        return transaction;
    }

    public async Task<Transaction?> UpdateTransactionAsync(Transaction transaction)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return null;

        var existing = await _transactionRepository.GetByIdAndUserIdAsync(transaction.Id, userId.Value);
        if (existing == null) return null;

        transaction.UserId = userId.Value;
        var updated = await _transactionRepository.UpdateAsync(transaction);
        return updated ? transaction : null;
    }

    public async Task<bool> DeleteTransactionAsync(Guid id)
    {
        var userId = _currentUser.UserId;
        if (!userId.HasValue) return false;

        var transaction = await _transactionRepository.GetByIdAndUserIdAsync(id, userId.Value);
        if (transaction == null)
            return false;

        var wallet = await _walletRepository.GetByIdAndUserIdAsync(transaction.WalletId, userId.Value);
        if (wallet != null)
        {
            if (transaction.Type == "income")
                wallet.Balance -= transaction.Amount;
            else if (transaction.Type == "expense")
                wallet.Balance += transaction.Amount;
            await _walletRepository.UpdateAsync(wallet);
        }

        return await _transactionRepository.DeleteAsync(id);
    }
}
