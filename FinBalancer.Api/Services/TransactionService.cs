using FinBalancer.Api.Models;
using FinBalancer.Api.Repositories;

namespace FinBalancer.Api.Services;

public class TransactionService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly IWalletRepository _walletRepository;

    public TransactionService(
        ITransactionRepository transactionRepository,
        IWalletRepository walletRepository)
    {
        _transactionRepository = transactionRepository;
        _walletRepository = walletRepository;
    }

    public async Task<List<Transaction>> GetTransactionsAsync()
    {
        return await _transactionRepository.GetAllAsync();
    }

    public async Task<Transaction?> AddTransactionAsync(Transaction transaction)
    {
        transaction.Id = Guid.NewGuid();
        transaction.DateCreated = DateTime.UtcNow;

        var wallet = await _walletRepository.GetByIdAsync(transaction.WalletId);
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
        var existing = await _transactionRepository.GetByIdAsync(transaction.Id);
        if (existing == null) return null;

        var updated = await _transactionRepository.UpdateAsync(transaction);
        return updated ? transaction : null;
    }

    public async Task<bool> DeleteTransactionAsync(Guid id)
    {
        var transaction = await _transactionRepository.GetByIdAsync(id);
        if (transaction == null)
            return false;

        var wallet = await _walletRepository.GetByIdAsync(transaction.WalletId);
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
