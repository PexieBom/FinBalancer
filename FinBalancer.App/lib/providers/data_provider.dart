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

  static const int _pageSize = 50;

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
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  /// '1m'|'3m'|'6m'|'12m'|'month'|'year'|'custom'|'all' - za označavanje odabranog perioda u UI.
  String _selectedPeriodId = 'month';
  double _periodIncome = 0;
  double _periodExpense = 0;
  bool _hasMoreTransactions = true;
  bool _isLoadingMore = false;
  bool _isLoading = false;
  String? _error;
  /// Kad je setiran, prikazuju se podaci tog hosta (guest pregled).
  String? _viewAsHostId;

  List<Transaction> get transactions => _transactions;
  String? get viewAsHostId => _viewAsHostId;
  bool get isViewingAsGuest => _viewAsHostId != null && _viewAsHostId!.isNotEmpty;
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
  DateTime? get filterDateFrom => _filterDateFrom;
  DateTime? get filterDateTo => _filterDateTo;
  String get selectedPeriodId => _selectedPeriodId;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMoreTransactions => _hasMoreTransactions;

  void setFilter({String? tag, String? project, String? walletId, DateTime? dateFrom, DateTime? dateTo}) {
    _filterTag = tag;
    _filterProject = project;
    _filterWalletId = walletId;
    _filterDateFrom = dateFrom;
    _filterDateTo = dateTo;
    notifyListeners();
  }

  /// Postavlja period na zadnjih N mjeseci (npr. 3 = zadnja 3 mjeseca).
  void setPeriodMonths(int months) {
    _selectedPeriodId = '${months}m';
    final now = DateTime.now();
    _filterDateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _filterDateFrom = DateTime(now.year, now.month - months, now.day, 0, 0, 0);
    notifyListeners();
  }

  /// Postavlja period na početak ovog mjeseca do danas.
  void setCurrentMonth() {
    _selectedPeriodId = 'month';
    final now = DateTime.now();
    _filterDateFrom = DateTime(now.year, now.month, 1, 0, 0, 0);
    _filterDateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    notifyListeners();
  }

  /// Postavlja period na početak ove godine do danas.
  void setPeriodThisYear() {
    _selectedPeriodId = 'year';
    final now = DateTime.now();
    _filterDateFrom = DateTime(now.year, 1, 1, 0, 0, 0);
    _filterDateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    notifyListeners();
  }

  /// Uklanja filter perioda (prikazuje sve transakcije).
  void clearPeriodFilter() {
    _selectedPeriodId = 'all';
    _filterDateFrom = null;
    _filterDateTo = null;
    notifyListeners();
  }

  /// Postavlja prilagođeni raspon datuma (od–do).
  void setCustomPeriod(DateTime dateFrom, DateTime dateTo) {
    _selectedPeriodId = 'custom';
    _filterDateFrom = DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 0, 0, 0);
    _filterDateTo = DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);
    notifyListeners();
  }

  void setViewAsHostId(String? hostId) {
    if (_viewAsHostId == hostId) return;
    _viewAsHostId = hostId;
    notifyListeners();
  }

  Wallet? get mainWallet {
    if (_wallets.isEmpty) return null;
    final main = _wallets.where((w) => w.isMain).toList();
    return main.isNotEmpty ? main.first : _wallets.first;
  }

  double get totalBalance =>
      _wallets.fold(0, (sum, w) => sum + w.balance);

  double get totalIncome => _periodIncome;
  double get totalExpense => _periodExpense;

  List<Transaction> get recentTransactions => _transactions;

  /// Učitava sljedećih 50 transakcija iz baze.
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMoreTransactions) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final next = await _api.getTransactions(
        tag: _filterTag,
        project: _filterProject,
        walletId: _filterWalletId,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        viewAsHostId: _viewAsHostId,
        limit: _pageSize,
        offset: _transactions.length,
      );
      _transactions.addAll(next);
      _hasMoreTransactions = next.length >= _pageSize;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// List of budgets to show on dashboard. Prikazuje samo glavni budžet (isMain).
  List<({String walletId, String walletName, BudgetCurrent budget, String? categoryName})> get dashboardBudgets {
    final result = <({String walletId, String walletName, BudgetCurrent budget, String? categoryName})>[];
    for (final b in _budgetSummaries) {
      if (!b.isMain) continue;
      final w = _wallets.where((x) => x.id == b.walletId).toList();
      final name = b.walletId == ApiService.globalBudgetId
          ? 'All Wallets'
          : (w.isEmpty ? 'Wallet' : w.first.name);
      result.add((walletId: b.walletId, walletName: name, budget: b.current, categoryName: b.categoryName));
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
    // Default: ovaj mjesec (1. do danas).
    if (_filterDateFrom == null && _filterDateTo == null) {
      setCurrentMonth();
    }
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

      // Phase 2: Rest in parallel (budgets, goals, achievements)
      await Future.wait([
        loadBudgets(),
        loadGoals(),
        loadAchievements(),
      ]);
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _api.getTransactions(
        tag: _filterTag,
        project: _filterProject,
        walletId: _filterWalletId,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        viewAsHostId: _viewAsHostId,
        limit: _pageSize,
        offset: 0,
      );
      _hasMoreTransactions = _transactions.length >= _pageSize;

      final summary = await _api.getIncomeExpenseSummary(
        walletId: _filterWalletId,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        viewAsHostId: _viewAsHostId,
      );
      _periodIncome = (summary['totalIncome'] as num?)?.toDouble() ?? 0;
      _periodExpense = (summary['totalExpense'] as num?)?.toDouble() ?? 0;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Refreshes transactions and related data after add/edit.
  Future<void> refreshAfterTransactionChange() async {
    try {
      await loadTransactions();
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
      _goals = await _api.getGoals(viewAsHostId: _viewAsHostId);
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
      _wallets = await _api.getWallets(viewAsHostId: _viewAsHostId);
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
      _projects = await _api.getProjects(viewAsHostId: _viewAsHostId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadBudgets() async {
    try {
      _budgetSummaries = await _api.getBudgetsCurrent(viewAsHostId: _viewAsHostId);
      notifyListeners();
    } catch (e) {
      _budgetSummaries = [];
      rethrow;
    }
  }

  Future<BudgetCurrent?> getWalletBudget(String walletId) async {
    try {
      if (walletId == ApiService.globalBudgetId) {
        return await _api.getGlobalBudgetCurrent(viewAsHostId: _viewAsHostId);
      }
      return await _api.getWalletBudgetCurrent(walletId, viewAsHostId: _viewAsHostId);
    } catch (_) {
      return null;
    }
  }

  Future<BudgetCurrent?> getBudgetById(String budgetId) async {
    try {
      return await _api.getBudgetCurrentById(budgetId, viewAsHostId: _viewAsHostId);
    } catch (_) {
      return null;
    }
  }

  /// Kreira novi budžet (Premium: neograničeno, Free: max 1).
  Future<BudgetCurrent> createBudget({
    String? walletId,
    required double budgetAmount,
    int periodStartDay = 1,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final result = await _api.createBudget(
      walletId: walletId ?? ApiService.globalBudgetId,
      budgetAmount: budgetAmount,
      periodStartDay: periodStartDay,
      periodStartDate: periodStartDate,
      periodEndDate: periodEndDate,
      categoryId: categoryId,
      viewAsHostId: _viewAsHostId,
    );
    await loadBudgets();
    notifyListeners();
    return result;
  }

  /// Ažurira postojeći budžet po id.
  Future<BudgetCurrent> updateBudget(
    String budgetId, {
    required double budgetAmount,
    int periodStartDay = 1,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final result = await _api.updateBudget(
      budgetId,
      budgetAmount: budgetAmount,
      periodStartDay: periodStartDay,
      periodStartDate: periodStartDate,
      periodEndDate: periodEndDate,
      categoryId: categoryId,
    );
    await loadBudgets();
    notifyListeners();
    return result;
  }

  Future<void> deleteBudgetById(String budgetId) async {
    await _api.deleteBudget(budgetId);
    await loadBudgets();
    notifyListeners();
  }

  Future<void> setBudgetMain(String budgetId) async {
    await _api.setBudgetMain(budgetId);
    await loadBudgets();
    notifyListeners();
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
    _filterDateFrom = null;
    _filterDateTo = null;
    _selectedPeriodId = 'month';
    _periodIncome = 0;
    _periodExpense = 0;
    _hasMoreTransactions = true;
    _viewAsHostId = null;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
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
