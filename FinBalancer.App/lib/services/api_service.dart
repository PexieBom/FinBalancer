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
import '../models/account_link.dart';
import '../models/in_app_notification.dart';
import '../config/app_config.dart';

class ApiService {
  static String get _baseUrl => AppConfig.apiBaseUrl;
  static String? _authToken;
  static set authToken(String? v) => _authToken = v;

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final m = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) m['Authorization'] = 'Bearer $_authToken';
    return m;
  }

  Future<List<Transaction>> getTransactions({
    String? tag,
    String? project,
    String? walletId,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? viewAsHostId,
    int? limit,
    int? offset,
  }) async {
    var url = '$_baseUrl/transactions';
    final params = <String>[];
    if (tag != null) params.add('tag=$tag');
    if (project != null) params.add('project=$project');
    if (walletId != null) params.add('walletId=$walletId');
    if (categoryId != null && categoryId.isNotEmpty) params.add('categoryId=$categoryId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) params.add('viewAsHostId=$viewAsHostId');
    if (limit != null && limit > 0) params.add('limit=$limit');
    if (offset != null && offset > 0) params.add('offset=$offset');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    }
    String errMsg = 'Failed to load transactions: ${response.statusCode}';
    try {
      final errJson = json.decode(response.body);
      if (errJson is Map && errJson.containsKey('message')) {
        errMsg += ' - ${errJson['message']}';
      } else if (errJson is Map && errJson.containsKey('error')) {
        errMsg += ' - ${errJson['error']}: ${errJson['message'] ?? ''}';
      } else {
        errMsg += ' - ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}';
      }
    } catch (_) {
      errMsg += ' - ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}';
    }
    throw Exception(errMsg);
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

  Future<List<Wallet>> getWallets({String? viewAsHostId}) async {
    var url = '$_baseUrl/wallets';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
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
    if (response.statusCode == 400) {
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final code = body['errorCode'] as String?;
        if (code == 'WalletLimitExceeded') throw ApiLimitException('WalletLimitExceeded');
      } catch (e) {
        if (e is ApiLimitException) rethrow;
      }
    }
    throw Exception('Failed to add wallet: ${response.statusCode} - ${response.body}');
  }

  Future<Map<String, dynamic>> getSpendingByCategory({String? walletId, DateTime? dateFrom, DateTime? dateTo, String? viewAsHostId}) async {
    var url = '$_baseUrl/statistics/spending-by-category';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) params.add('viewAsHostId=$viewAsHostId');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load statistics: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getIncomeExpenseSummary({String? walletId, DateTime? dateFrom, DateTime? dateTo, String? viewAsHostId}) async {
    var url = '$_baseUrl/statistics/income-expense-summary';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (dateFrom != null) params.add('dateFrom=${dateFrom.toIso8601String()}');
    if (dateTo != null) params.add('dateTo=${dateTo.toIso8601String()}');
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) params.add('viewAsHostId=$viewAsHostId');
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

  Future<List<Goal>> getGoals({String? viewAsHostId}) async {
    var url = '$_baseUrl/goals';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
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
    if (response.statusCode == 400) {
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final code = body['errorCode'] as String?;
        if (code == 'GoalLimitExceeded') throw ApiLimitException('GoalLimitExceeded');
      } catch (e) {
        if (e is ApiLimitException) rethrow;
      }
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

  Future<Map<String, dynamic>> getBudgetPrediction({String? walletId, String? viewAsHostId}) async {
    var url = '$_baseUrl/statistics/budget-prediction';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) params.add('viewAsHostId=$viewAsHostId');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load budget prediction: ${response.statusCode}');
  }

  Future<List<dynamic>> getBudgetAlerts({String? walletId, String? viewAsHostId}) async {
    var url = '$_baseUrl/statistics/budget-alerts';
    final params = <String>[];
    if (walletId != null) params.add('walletId=$walletId');
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) params.add('viewAsHostId=$viewAsHostId');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load budget alerts: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getCashflowTrend({String? walletId, int months = 6, DateTime? dateFrom, DateTime? dateTo, String? viewAsHostId}) async {
    var url = '$_baseUrl/statistics/cashflow-trend?months=$months';
    if (walletId != null) url += '&walletId=$walletId';
    if (dateFrom != null) url += '&dateFrom=${dateFrom.toIso8601String()}';
    if (dateTo != null) url += '&dateTo=${dateTo.toIso8601String()}';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '&viewAsHostId=$viewAsHostId';
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

  Future<List<Project>> getProjects({String? viewAsHostId}) async {
    var url = '$_baseUrl/projects';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
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

  /// Server-authoritative entitlement (preferred for premium gate).
  Future<SubscriptionStatus> getEntitlement() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/billing/entitlement'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final respJson = json.decode(response.body) as Map<String, dynamic>;
      return SubscriptionStatus(
        isPremium: respJson['isPremium'] as bool? ?? false,
        expiresAt: respJson['premiumUntil'] != null
            ? DateTime.tryParse(respJson['premiumUntil'] as String)
            : null,
        productId: null,
        platform: respJson['sourcePlatform'] as String?,
      );
    }
    if (response.statusCode == 401) {
      return const SubscriptionStatus(isPremium: false);
    }
    throw Exception('Failed to load entitlement: ${response.statusCode}');
  }

  /// Confirm mobile purchase (iOS/Android) - server verifies with store.
  Future<SubscriptionStatus?> confirmMobilePurchase({
    required String platform,
    required String productCode,
    String? storeProductId,
    String? purchaseToken,
    String? receiptData,
    String? orderId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/billing/mobile/confirm'),
      headers: _headers,
      body: json.encode({
        'platform': platform,
        'productCode': productCode,
        'storeProductId': storeProductId,
        'purchaseToken': purchaseToken,
        'receiptData': receiptData,
        'orderId': orderId,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final respJson = json.decode(response.body) as Map<String, dynamic>;
      return SubscriptionStatus(
        isPremium: respJson['isPremium'] as bool? ?? false,
        expiresAt: respJson['premiumUntil'] != null
            ? DateTime.tryParse(respJson['premiumUntil'] as String)
            : null,
        platform: respJson['sourcePlatform'] as String?,
      );
    }
    return null;
  }

  /// Create PayPal subscription for web. Returns approval URL.
  Future<({String? approvalUrl, String? subscriptionId})> createPayPalSubscription({
    required String productCode,
    String? paypalPlanId,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/billing/paypal/create-subscription'),
      headers: _headers,
      body: json.encode({
        'productCode': productCode,
        'paypalPlanId': paypalPlanId,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
      }),
    );
    if (response.statusCode == 200) {
      final respJson = json.decode(response.body) as Map<String, dynamic>;
      return (
        approvalUrl: respJson['approvalUrl'] as String?,
        subscriptionId: respJson['paypalSubscriptionId'] as String?,
      );
    }
    throw Exception('Failed to create PayPal subscription: ${response.statusCode}');
  }

  /// Confirm PayPal subscription after user approval.
  Future<SubscriptionStatus?> confirmPayPalSubscription({
    required String subscriptionId,
    required String productCode,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/billing/paypal/confirm'),
      headers: _headers,
      body: json.encode({
        'subscriptionId': subscriptionId,
        'productCode': productCode,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final respJson = json.decode(response.body) as Map<String, dynamic>;
      return SubscriptionStatus(
        isPremium: respJson['isPremium'] as bool? ?? false,
        expiresAt: respJson['premiumUntil'] != null
            ? DateTime.tryParse(respJson['premiumUntil'] as String)
            : null,
        platform: respJson['sourcePlatform'] as String?,
      );
    }
    return null;
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

  Future<BudgetCurrent?> getWalletBudgetCurrent(String walletId, {String? viewAsHostId}) async {
    var url = '$_baseUrl/wallets/$walletId/budget/current';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
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
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{
      'budgetAmount': budgetAmount,
      'periodStartDay': periodStartDay,
    };
    if (periodStartDate != null) body['periodStartDate'] = periodStartDate.toIso8601String();
    if (periodEndDate != null) body['periodEndDate'] = periodEndDate.toIso8601String();
    if (categoryId != null && categoryId.isNotEmpty) body['categoryId'] = categoryId;
    final response = await _client.post(
      Uri.parse('$_baseUrl/wallets/$walletId/budget'),
      headers: _headers,
      body: json.encode(body),
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

  Future<List<BudgetSummary>> getBudgetsCurrent({String? viewAsHostId}) async {
    var url = '$_baseUrl/budgets/current';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((e) => BudgetSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load budgets: ${response.statusCode}');
  }

  static const String globalBudgetId = '00000000-0000-0000-0000-000000000000';

  Future<BudgetCurrent?> getGlobalBudgetCurrent({String? viewAsHostId}) async {
    var url = '$_baseUrl/budgets/global/current';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
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
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{
      'budgetAmount': budgetAmount,
      'periodStartDay': periodStartDay,
    };
    if (periodStartDate != null) body['periodStartDate'] = periodStartDate.toIso8601String();
    if (periodEndDate != null) body['periodEndDate'] = periodEndDate.toIso8601String();
    if (categoryId != null && categoryId.isNotEmpty) body['categoryId'] = categoryId;
    final response = await _client.post(
      Uri.parse('$_baseUrl/budgets/global'),
      headers: _headers,
      body: json.encode(body),
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

  /// Creates a new budget. Free: 1 max. Premium: unlimited.
  Future<BudgetCurrent> createBudget({
    String? walletId,
    required double budgetAmount,
    int periodStartDay = 1,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
    String? viewAsHostId,
  }) async {
    final body = <String, dynamic>{
      'budgetAmount': budgetAmount,
      'periodStartDay': periodStartDay,
    };
    if (walletId != null && walletId.isNotEmpty) body['walletId'] = walletId;
    if (periodStartDate != null) body['periodStartDate'] = periodStartDate.toIso8601String();
    if (periodEndDate != null) body['periodEndDate'] = periodEndDate.toIso8601String();
    if (categoryId != null && categoryId.isNotEmpty) body['categoryId'] = categoryId;
    var url = '$_baseUrl/budgets';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.post(Uri.parse(url), headers: _headers, body: json.encode(body));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BudgetCurrent.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    if (response.statusCode == 400) {
      try {
        final j = json.decode(response.body) as Map<String, dynamic>;
        if (j['errorCode'] == 'BudgetLimitExceeded') throw ApiLimitException('BudgetLimitExceeded');
      } catch (e) {
        if (e is ApiLimitException) rethrow;
      }
    }
    throw Exception('Failed to create budget: ${response.statusCode}');
  }

  Future<BudgetCurrent?> getBudgetCurrentById(String budgetId, {String? viewAsHostId}) async {
    var url = '$_baseUrl/budgets/$budgetId/current';
    if (viewAsHostId != null && viewAsHostId.isNotEmpty) url += '?viewAsHostId=$viewAsHostId';
    final response = await _client.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      return BudgetCurrent.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to load budget: ${response.statusCode}');
  }

  Future<BudgetCurrent> updateBudget(
    String budgetId, {
    required double budgetAmount,
    int periodStartDay = 1,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{
      'budgetAmount': budgetAmount,
      'periodStartDay': periodStartDay,
    };
    if (periodStartDate != null) body['periodStartDate'] = periodStartDate.toIso8601String();
    if (periodEndDate != null) body['periodEndDate'] = periodEndDate.toIso8601String();
    if (categoryId != null && categoryId.isNotEmpty) body['categoryId'] = categoryId;
    final response = await _client.put(
      Uri.parse('$_baseUrl/budgets/$budgetId'),
      headers: _headers,
      body: json.encode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BudgetCurrent.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update budget: ${response.statusCode}');
  }

  Future<void> deleteBudget(String budgetId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/budgets/$budgetId'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete budget: ${response.statusCode}');
    }
  }

  Future<void> setBudgetMain(String budgetId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/budgets/$budgetId/main'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to set main budget: ${response.statusCode}');
    }
  }

  // --- Povezani računi (host/guest) ---

  Future<List<AccountLinkItem>> getAccountLinks() async {
    final response = await _client.get(Uri.parse('$_baseUrl/accountlinks'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => AccountLinkItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load account links: ${response.statusCode}');
  }

  Future<List<LinkedHost>> getLinkedHosts() async {
    final response = await _client.get(Uri.parse('$_baseUrl/accountlinks/linked-hosts'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => LinkedHost.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load linked hosts: ${response.statusCode}');
  }

  /// Host poziva gosta po emailu. Vraća errorCode ako ne uspije.
  Future<InviteResult> inviteAccountLink(String guestEmail) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/accountlinks/invite'),
      headers: _headers,
      body: json.encode({'guestEmail': guestEmail.trim()}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return InviteResult(success: true, guestDisplayName: map['guestDisplayName'] as String?);
    }
    if (response.statusCode == 404) return InviteResult(success: false, errorCode: 'GuestNotFound');
    try {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return InviteResult(success: false, errorCode: map['errorCode'] as String?);
    } catch (_) {
      return InviteResult(success: false, errorCode: 'Unknown');
    }
  }

  Future<void> acceptAccountLink(String linkId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/accountlinks/$linkId/accept'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to accept invite: ${response.statusCode}');
    }
  }

  Future<void> revokeAccountLink(String linkId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/accountlinks/$linkId/revoke'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to revoke link: ${response.statusCode}');
    }
  }

  // --- Obavijesti ---

  Future<List<InAppNotification>> getNotifications({int limit = 50}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/notifications?limit=$limit'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => InAppNotification.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load notifications: ${response.statusCode}');
  }

  Future<int> getNotificationsUnreadCount() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/notifications/unread-count'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as int;
    }
    return 0;
  }

  Future<void> markNotificationAsRead(String id) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/notifications/$id/read'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to mark as read: ${response.statusCode}');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/notifications/read-all'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to mark all as read: ${response.statusCode}');
    }
  }

  Future<void> registerDeviceToken({required String token, required String platform}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/devicetokens/register'),
      headers: _headers,
      body: json.encode({'token': token, 'platform': platform}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to register device token: ${response.statusCode}');
    }
  }

  Future<void> unregisterDeviceToken(String token) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/devicetokens/unregister'),
      headers: _headers,
      body: json.encode({'token': token}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unregister device token: ${response.statusCode}');
    }
  }
}

class InviteResult {
  final bool success;
  final String? guestDisplayName;
  final String? errorCode;
  InviteResult({required this.success, this.guestDisplayName, this.errorCode});
}

class ApiLimitException implements Exception {
  final String errorCode;
  ApiLimitException(this.errorCode);
}
