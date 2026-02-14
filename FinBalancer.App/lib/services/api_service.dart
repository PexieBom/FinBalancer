import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/category.dart' as app_models;

class ApiService {
  static const String _baseUrl = 'http://localhost:5292/api';

  final http.Client _client = http.Client();

  Future<List<Transaction>> getTransactions() async {
    final response = await _client.get(Uri.parse('$_baseUrl/transactions'));
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

  Future<List<app_models.TransactionCategory>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => app_models.TransactionCategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }
}
