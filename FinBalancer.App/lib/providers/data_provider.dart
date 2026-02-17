import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart' as app_models;
import '../models/goal.dart';
import '../models/achievement.dart';
import '../models/subcategory.dart';
import '../models/project.dart';
import '../models/wallet_budget.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Transaction> _transactions = [];
  List<Wallet> _wallets = [];
  List<app_models.TransactionCategory> _categories = [];
  List<Goal> _goals = [];
  List<Achievement> _achievements = [];
  List<Subcategory> _subcategories = [];
  List<Project> _projects = [];
  List<BudgetSummary> _budgetSummaries = [];
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
  List<Project> get projects => _projects;
  List<BudgetSummary> get budgetSummaries => _budgetSummaries;
  String? get filterTag => _filterTag;
  String? get filterProject => _filterProject;
  String? get filterWalletId => _filterWalletId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setFilter({String? tag, String? project, String? walletId}) {
    _filterTag = tag;
    _filterProject = project;
    _filterWalletId = walletId;
    resetDisplayedTransactionCount();
    notifyListeners();
  }

  Wallet? get mainWallet {
    if (_wallets.isEmpty) return null;
    final main = _wallets.where((w) => w.isMain).toList();
    return main.isNotEmpty ? main.first : _wallets.first;
  }

  double get totalBalance =>
      _wallets.fold(0, (sum, w) => sum + w.balance);

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  static const int _initialDisplayCount = 20;
  static const int _loadMoreCount = 20;
  int _displayedTransactionCount = _initialDisplayCount;

  List<Transaction> get recentTransactions =>
      _transactions.take(_displayedTransactionCount).toList();

  bool get hasMoreTransactions => _displayedTransactionCount < _transactions.length;

  void loadMoreDisplayedTransactions() {
    if (_displayedTransactionCount < _transactions.length) {
      _displayedTransactionCount = (_displayedTransactionCount + _loadMoreCount)
          .clamp(0, _transactions.length);
      notifyListeners();
    }
  }

  void resetDisplayedTransactionCount() {
    _displayedTransactionCount = _initialDisplayCount;
    notifyListeners();
  }

  /// List of budgets to show on dashboard (for carousel). Only shows budgets that are set.
  /// Single wallet: that wallet's budget if set. All wallets: global + per-wallet budgets.
  List<({String walletId, String walletName, BudgetCurrent budget})> get dashboardBudgets {
    final result = <({String walletId, String walletName, BudgetCurrent budget})>[];
    if (_filterWalletId != null) {
      for (final b in _budgetSummaries) {
        if (b.walletId == _filterWalletId) {
          final w = _wallets.where((x) => x.id == b.walletId).toList();
          final name = w.isEmpty ? 'Wallet' : w.first.name;
          result.add((walletId: b.walletId, walletName: name, budget: b.current));
        }
      }
    } else {
      for (final b in _budgetSummaries) {
        if (b.walletId == ApiService.globalBudgetId) {
          result.add((walletId: b.walletId, walletName: 'All Wallets', budget: b.current));
        } else {
          final w = _wallets.where((x) => x.id == b.walletId).toList();
          final name = w.isEmpty ? 'Wallet' : w.first.name;
          result.add((walletId: b.walletId, walletName: name, budget: b.current));
        }
      }
    }
    return result;
  }

  BudgetCurrent? get dashboardBudget {
    final list = dashboardBudgets;
    return list.isEmpty ? null : list.first.budget;
  }

  String? get dashboardBudgetWalletName {
    if (_filterWalletId == null) return null;
    if (_filterWalletId == ApiService.globalBudgetId) return null;
    final w = _wallets.where((x) => x.id == _filterWalletId).toList();
    return w.isEmpty ? null : w.first.name;
  }

  Future<void> loadAll({String? locale}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Phase 1: Core data for main view (transactions, wallets, categories)
      await Future.wait([
        loadTransactions(),
        loadWallets(),
        loadCategories(locale: locale),
      ]);
      _isLoading = false;
      notifyListeners();

      // Phase 2: Rest in parallel (budgets, goals, achievements, projects)
      await Future.wait([
        loadBudgets(),
        loadGoals(),
        loadAchievements(),
        loadProjects(),
      ]);
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadTransactions({bool resetDisplayedCount = true}) async {
    try {
      _transactions = await _api.getTransactions(
        tag: _filterTag,
        project: _filterProject,
        walletId: _filterWalletId,
      );
      if (resetDisplayedCount) resetDisplayedTransactionCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Refreshes transactions and related data after add/edit without resetting displayed count.
  Future<void> refreshAfterTransactionChange() async {
    try {
      await loadTransactions(resetDisplayedCount: false);
      await loadWallets();
      await loadBudgets();
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

  Future<void> loadCategories({String? locale}) async {
    try {
      _categories = await _api.getCategories(locale: locale);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> loadProjects() async {
    try {
      _projects = await _api.getProjects();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadBudgets() async {
    try {
      _budgetSummaries = await _api.getBudgetsCurrent();
      notifyListeners();
    } catch (e) {
      _budgetSummaries = [];
      rethrow;
    }
  }

  Future<BudgetCurrent?> getWalletBudget(String walletId) async {
    try {
      if (walletId == ApiService.globalBudgetId) {
        return await _api.getGlobalBudgetCurrent();
      }
      return await _api.getWalletBudgetCurrent(walletId);
    } catch (_) {
      return null;
    }
  }

  Future<BudgetCurrent> createOrUpdateBudget(
    String walletId, {
    required double budgetAmount,
    int periodStartDay = 1,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final BudgetCurrent result;
    if (walletId == ApiService.globalBudgetId) {
      result = await _api.createOrUpdateGlobalBudget(
        budgetAmount: budgetAmount,
        periodStartDay: periodStartDay,
        periodStartDate: periodStartDate,
        periodEndDate: periodEndDate,
        categoryId: categoryId,
      );
    } else {
      result = await _api.createOrUpdateWalletBudget(
        walletId,
        budgetAmount: budgetAmount,
        periodStartDay: periodStartDay,
        periodStartDate: periodStartDate,
        periodEndDate: periodEndDate,
        categoryId: categoryId,
      );
    }
    await loadBudgets();
    return result;
  }

  Future<void> deleteBudget(String walletId) async {
    if (walletId == ApiService.globalBudgetId) {
      await _api.deleteGlobalBudget();
    } else {
      await _api.deleteWalletBudget(walletId);
    }
    await loadBudgets();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _error = null;
    try {
      final created = await _api.addTransaction(transaction);
      _transactions.insert(0, created);
      await loadWallets();
      await loadBudgets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    _error = null;
    try {
      final updated = await _api.updateTransaction(transaction);
      final i = _transactions.indexWhere((t) => t.id == transaction.id);
      if (i >= 0) _transactions[i] = updated;
      await loadWallets();
      await loadBudgets();
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
      await loadBudgets();
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

  Future<void> updateWallet(Wallet wallet) async {
    _error = null;
    try {
      await _api.updateWallet(wallet);
      final i = _wallets.indexWhere((w) => w.id == wallet.id);
      if (i >= 0) _wallets[i] = wallet;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> setMainWallet(String walletId) async {
    _error = null;
    try {
      await _api.setMainWallet(walletId);
      await loadWallets();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteWallet(String id) async {
    _error = null;
    try {
      await _api.deleteWallet(id);
      _wallets.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> addCustomCategory(String name, String type) async {
    _error = null;
    try {
      final cat = await _api.addCustomCategory(name, type);
      _categories.add(cat);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteCustomCategory(String id) async {
    _error = null;
    try {
      await _api.deleteCustomCategory(id);
      _categories.removeWhere((c) => c.id == id);
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

  /// Clears all user data (on logout). Prevents stale data when switching accounts.
  void clearUserData() {
    _transactions = [];
    _wallets = [];
    _categories = [];
    _goals = [];
    _achievements = [];
    _subcategories = [];
    _projects = [];
    _budgetSummaries = [];
    _filterTag = null;
    _filterProject = null;
    _filterWalletId = null;
    _displayedTransactionCount = _initialDisplayCount;
    _error = null;
    _isLoading = false;
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
