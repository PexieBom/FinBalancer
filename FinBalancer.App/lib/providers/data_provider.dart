import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Transaction> _transactions = [];
  List<Wallet> _wallets = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  List<Wallet> get wallets => _wallets;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance =>
      _wallets.fold(0, (sum, w) => sum + w.balance);

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  List<Transaction> get recentTransactions =>
      _transactions.take(10).toList();

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadTransactions(),
        loadWallets(),
        loadCategories(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _api.getTransactions();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> loadWallets() async {
    try {
      _wallets = await _api.getWallets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _api.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _error = null;
    try {
      final created = await _api.addTransaction(transaction);
      _transactions.insert(0, created);
      await loadWallets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    _error = null;
    try {
      await _api.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      await loadWallets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    _error = null;
    try {
      final created = await _api.addWallet(wallet);
      _wallets.add(created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Map<String, double> getExpensesByCategory() {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == 'expense')) {
      final cat = _categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: t.categoryId, name: 'Unknown', icon: '', type: 'expense'),
      );
      map[cat.name] = (map[cat.name] ?? 0) + t.amount;
    }
    return map;
  }
}
