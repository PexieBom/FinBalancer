import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart' as app_models;
import '../models/goal.dart';
import '../models/achievement.dart';
import '../models/subcategory.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5292/api';

  final http.Client _client = http.Client();

  Future<List<Transaction>> getTransactions({String? tag, String? project, String? walletId}) async {
    var url = '$_baseUrl/transactions';
    final params = <String>[];
    if (tag != null) params.add('tag=$tag');
    if (project != null) params.add('project=$project');
    if (walletId != null) params.add('walletId=$walletId');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load transactions: ${response.statusCode}');
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJsonForCreate()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Transaction.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add transaction: ${response.statusCode} - ${response.body}');
  }

  Future<void> deleteTransaction(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/transactions/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
  }

  Future<List<Wallet>> getWallets() async {
    final response = await _client.get(Uri.parse('$_baseUrl/wallets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Wallet.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load wallets: ${response.statusCode}');
  }

  Future<Wallet> addWallet(Wallet wallet) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/wallets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(wallet.toJsonForCreate()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Wallet.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add wallet: ${response.statusCode} - ${response.body}');
  }

  Future<Map<String, dynamic>> getSpendingByCategory({String? walletId}) async {
    var url = '$_baseUrl/statistics/spending-by-category';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load statistics: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getIncomeExpenseSummary({String? walletId}) async {
    var url = '$_baseUrl/statistics/income-expense-summary';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load statistics: ${response.statusCode}');
  }

  Future<List<Subcategory>> getSubcategories({String? categoryId}) async {
    var url = '$_baseUrl/subcategories';
    if (categoryId != null) url += '?categoryId=$categoryId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Subcategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load subcategories: ${response.statusCode}');
  }

  Future<Subcategory> addSubcategory(Subcategory subcategory) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/subcategories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(subcategory.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Subcategory.fromJson(json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add subcategory: ${response.statusCode}');
  }

  Future<List<Goal>> getGoals() async {
    final response = await _client.get(Uri.parse('$_baseUrl/goals'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load goals: ${response.statusCode}');
  }

  Future<Goal> addGoal(Goal goal) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/goals'),
      headers: {'Content-Type': 'application/json'},
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
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update goal: ${response.statusCode}');
    }
  }

  Future<void> deleteGoal(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/goals/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete goal: ${response.statusCode}');
    }
  }

  Future<List<Achievement>> getAchievements() async {
    final response = await _client.get(Uri.parse('$_baseUrl/achievements'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load achievements: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getBudgetPrediction({String? walletId}) async {
    var url = '$_baseUrl/statistics/budget-prediction';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load budget prediction: ${response.statusCode}');
  }

  Future<List<dynamic>> getBudgetAlerts({String? walletId}) async {
    var url = '$_baseUrl/statistics/budget-alerts';
    if (walletId != null) url += '?walletId=$walletId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load budget alerts: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getCashflowTrend({String? walletId, int months = 6}) async {
    var url = '$_baseUrl/statistics/cashflow-trend?months=$months';
    if (walletId != null) url += '&walletId=$walletId';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load cashflow trend: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    final response = await _client.get(Uri.parse('$_baseUrl/userpreferences'));
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
      headers: {'Content-Type': 'application/json'},
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

  Future<List<app_models.TransactionCategory>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => app_models.TransactionCategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }
}
