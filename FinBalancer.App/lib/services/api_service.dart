import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart' as app_models;
import '../models/goal.dart';
import '../models/achievement.dart';
import '../models/subcategory.dart';
import '../models/project.dart';
import '../models/subscription.dart';
import '../models/wallet_budget.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5292/api';
  static String? _authToken;
  static set authToken(String? v) => _authToken = v;

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final m = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) m['Authorization'] = 'Bearer $_authToken';
    return m;
  }

  Future<List<Transaction>> getTransactions({String? tag, String? project, String? walletId, String? categoryId, DateTime? dateFrom, DateTime? dateTo}) async {
    var url = '$_baseUrl/transactions';
    final params = <String>[];
    if (tag != null) params.add('tag=$tag');
    if (project != null) params.add('project=$project');
    if (walletId != null) params.add('walletId=$walletId');
    if (categoryId != null && categoryId.isNotEmpty) params.add('categoryId=$categoryId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load transactions: ${response.statusCode}');
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: _headers,
      body: json.encode(transaction.toJsonForCreate()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Transaction.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add transaction: ${response.statusCode} - ${response.body}');
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/transactions/${transaction.id}'),
      headers: _headers,
      body: json.encode(transaction.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Transaction.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update transaction: ${response.statusCode} - ${response.body}');
  }

  Future<void> deleteTransaction(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/transactions/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
  }

  Future<List<Wallet>> getWallets() async {
    final response = await _client.get(Uri.parse('$_baseUrl/wallets'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Wallet.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load wallets: ${response.statusCode}');
  }

  Future<Wallet> addWallet(Wallet wallet) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/wallets'),
      headers: _headers,
      body: json.encode(wallet.toJsonForCreate()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Wallet.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add wallet: ${response.statusCode} - ${response.body}');
  }

  Future<Map<String, dynamic>> getSpendingByCategory({String? walletId, DateTime? dateFrom, DateTime? dateTo}) async {
    var url = '$_baseUrl/statistics/spending-by-category';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load statistics: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getIncomeExpenseSummary({String? walletId, DateTime? dateFrom, DateTime? dateTo}) async {
    var url = '$_baseUrl/statistics/income-expense-summary';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load statistics: ${response.statusCode}');
  }

  Future<List<Subcategory>> getSubcategories({String? categoryId}) async {
    var url = '$_baseUrl/subcategories';
    if (categoryId != null) url += '?categoryId=$categoryId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Subcategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load subcategories: ${response.statusCode}');
  }

  Future<Subcategory> addSubcategory(Subcategory subcategory) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/subcategories'),
      headers: _headers,
      body: json.encode(subcategory.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Subcategory.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add subcategory: ${response.statusCode}');
  }

  Future<List<Goal>> getGoals() async {
    final response = await _client.get(Uri.parse('$_baseUrl/goals'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load goals: ${response.statusCode}');
  }

  Future<Goal> addGoal(Goal goal) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/goals'),
      headers: _headers,
      body: json.encode(goal.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Goal.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add goal: ${response.statusCode}');
  }

  Future<void> addToGoal(String id, double amount) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/goals/$id/add'),
      headers: _headers,
      body: json.encode({'amount': amount}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update goal: ${response.statusCode}');
    }
  }

  Future<void> deleteGoal(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/goals/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete goal: ${response.statusCode}');
    }
  }

  Future<List<Achievement>> getAchievements() async {
    final response = await _client.get(Uri.parse('$_baseUrl/achievements'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load achievements: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getBudgetPrediction({String? walletId}) async {
    var url = '$_baseUrl/statistics/budget-prediction';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load budget prediction: ${response.statusCode}');
  }

  Future<List<dynamic>> getBudgetAlerts({String? walletId}) async {
    var url = '$_baseUrl/statistics/budget-alerts';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load budget alerts: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getCashflowTrend({String? walletId, int months = 6, DateTime? dateFrom, DateTime? dateTo}) async {
    var url = '$_baseUrl/statistics/cashflow-trend?months=$months';
    if (walletId != null) url += '&walletId=$walletId';
    if (dateFrom != null) url += '&dateFrom=${dateFrom.toIso8601String()}';
    if (dateTo != null) url += '&dateTo=${dateTo.toIso8601String()}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load cashflow trend: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    final response = await _client.get(Uri.parse('$_baseUrl/userpreferences'), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load preferences: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateUserPreferences(String locale, String currency, {String? theme}) async {
    final body = <String, dynamic>{'locale': locale, 'currency': currency};
    if (theme != null) body['theme'] = theme;
    final response = await _client.put(
      Uri.parse('$_baseUrl/userpreferences'),
      headers: _headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update preferences: ${response.statusCode}');
  }

  String getExportUrl(String format, {String? walletId}) {
    var url = '$_baseUrl/export/$format';
    if (walletId != null) url += '?walletId=$walletId';
    return url;
  }

  Future<List<app_models.TransactionCategory>> getCategories({String? locale}) async {
    var url = '$_baseUrl/categories';
    if (locale != null) url += '?locale=$locale';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => app_models.TransactionCategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  Future<app_models.TransactionCategory> addCustomCategory(String name, String type) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/categories/custom'),
      headers: _headers,
      body: json.encode({'name': name, 'type': type}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return app_models.TransactionCategory.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add category: ${response.statusCode} - ${response.body}');
  }

  Future<void> deleteCustomCategory(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/categories/custom/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/wallets/${wallet.id}'),
      headers: _headers,
      body: json.encode(wallet.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update wallet: ${response.statusCode}');
    }
  }

  Future<void> setMainWallet(String walletId) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/wallets/$walletId/main'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to set main wallet: ${response.statusCode}');
    }
  }

  Future<void> deleteWallet(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/wallets/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete wallet: ${response.statusCode}');
    }
  }

  Future<List<Project>> getProjects() async {
    final response = await _client.get(Uri.parse('$_baseUrl/projects'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load projects: ${response.statusCode}');
  }

  Future<Project> addProject(Project project) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/projects'),
      headers: _headers,
      body: json.encode(project.toJsonForCreate()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Project.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add project: ${response.statusCode} - ${response.body}');
  }

  Future<void> updateProject(Project project) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/projects/${project.id}'),
      headers: _headers,
      body: json.encode(project.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update project: ${response.statusCode}');
    }
  }

  Future<void> deleteProject(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/projects/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete project: ${response.statusCode}');
    }
  }

  Future<SubscriptionStatus> getSubscriptionStatus({String? userId}) async {
    final headers = Map<String, String>.from(_headers);
    if (userId != null && userId.isNotEmpty) {
      headers['X-User-Id'] = userId;
    }
    final response = await _client.get(
      Uri.parse('$_baseUrl/subscriptions/status'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return SubscriptionStatus.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 401) {
      return const SubscriptionStatus(isPremium: false);
    }
    throw Exception('Failed to load subscription: ${response.statusCode}');
  }

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final response = await _client.get(Uri.parse('$_baseUrl/subscriptions/plans'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load plans: ${response.statusCode}');
  }

  Future<SubscriptionStatus?> validatePurchase({
    required String userId,
    required String platform,
    required String productId,
    String? purchaseToken,
    String? receiptData,
    String? orderId,
  }) async {
    if (userId.isEmpty) return null;
    final response = await _client.post(
      Uri.parse('$_baseUrl/subscriptions/validate'),
      headers: {..._headers, 'X-User-Id': userId},
      body: json.encode({
        'platform': platform,
        'productId': productId,
        'purchaseToken': purchaseToken,
        'receiptData': receiptData,
        'orderId': orderId,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SubscriptionStatus.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<BudgetCurrent?> getWalletBudgetCurrent(String walletId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/wallets/$walletId/budget/current'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return BudgetCurrent.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to load budget: ${response.statusCode}');
  }

  Future<BudgetCurrent> createOrUpdateWalletBudget(
    String walletId, {
    required double budgetAmount,
    int periodStartDay = 1,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/wallets/$walletId/budget'),
      headers: _headers,
      body: json.encode({
        'budgetAmount': budgetAmount,
        'periodStartDay': periodStartDay,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BudgetCurrent.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to save budget: ${response.statusCode}');
  }

  Future<void> deleteWalletBudget(String walletId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/wallets/$walletId/budget'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete budget: ${response.statusCode}');
    }
  }

  Future<List<BudgetSummary>> getBudgetsCurrent() async {
    final response = await _client.get(Uri.parse('$_baseUrl/budgets/current'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((e) => BudgetSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load budgets: ${response.statusCode}');
  }

  static const String globalBudgetId = '00000000-0000-0000-0000-000000000000';

  Future<BudgetCurrent?> getGlobalBudgetCurrent() async {
    final response = await _client.get(Uri.parse('$_baseUrl/budgets/global/current'), headers: _headers);
    if (response.statusCode == 200) {
      return BudgetCurrent.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to load global budget: ${response.statusCode}');
  }

  Future<BudgetCurrent> createOrUpdateGlobalBudget({
    required double budgetAmount,
    int periodStartDay = 1,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/budgets/global'),
      headers: _headers,
      body: json.encode({
        'budgetAmount': budgetAmount,
        'periodStartDay': periodStartDay,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BudgetCurrent.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to save global budget: ${response.statusCode}');
  }

  Future<void> deleteGlobalBudget() async {
    final response = await _client.delete(Uri.parse('$_baseUrl/budgets/global'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete global budget: ${response.statusCode}');
    }
  }
}
