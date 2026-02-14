import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart' as app_models;
import '../models/goal.dart';
import '../models/achievement.dart';
import '../models/subcategory.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Transaction> _transactions = [];
  List<Wallet> _wallets = [];
  List<app_models.TransactionCategory> _categories = [];
  List<Goal> _goals = [];
  List<Achievement> _achievements = [];
  List<Subcategory> _subcategories = [];
  String? _filterTag;
  String? _filterProject;
  String? _filterWalletId;
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  List<Wallet> get wallets => _wallets;
  List<app_models.TransactionCategory> get categories => _categories;
  List<Goal> get goals => _goals;
  List<Achievement> get achievements => _achievements;
  List<Subcategory> get subcategories => _subcategories;
  String? get filterTag => _filterTag;
  String? get filterProject => _filterProject;
  String? get filterWalletId => _filterWalletId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setFilter({String? tag, String? project, String? walletId}) {
    _filterTag = tag;
    _filterProject = project;
    _filterWalletId = walletId;
    notifyListeners();
  }

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
        loadGoals(),
        loadAchievements(),
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
      _transactions = await _api.getTransactions(
        tag: _filterTag,
        project: _filterProject,
        walletId: _filterWalletId,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> loadGoals() async {
    try {
      _goals = await _api.getGoals();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadAchievements() async {
    try {
      _achievements = await _api.getAchievements();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadSubcategories({String? categoryId}) async {
    try {
      _subcategories = await _api.getSubcategories(categoryId: categoryId);
      notifyListeners();
    } catch (e) {
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
        orElse: () => app_models.TransactionCategory(id: t.categoryId, name: 'Unknown', icon: '', type: 'expense'),
      );
      map[cat.name] = (map[cat.name] ?? 0) + t.amount;
    }
    return map;
  }
}
