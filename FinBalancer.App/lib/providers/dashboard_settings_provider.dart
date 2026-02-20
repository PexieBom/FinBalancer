import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyShowPlan = 'dashboard_show_plan';
const _keyShowGoals = 'dashboard_show_goals';
const _keyShowAchievements = 'dashboard_show_achievements';
const _keyShowBudget = 'dashboard_show_budget';
const _keyShowStatistics = 'dashboard_show_statistics';
const _keyShowExpensesChart = 'dashboard_show_expenses_chart';
const _keyShowLinkedAccounts = 'dashboard_show_linked_accounts';

class DashboardSettingsProvider extends ChangeNotifier {
  bool _showPlan = true;
  bool _showGoals = true;
  bool _showAchievements = true;
  bool _showBudget = true;
  bool _showStatistics = true;
  bool _showExpensesChart = true;
  bool _showLinkedAccounts = true;

  bool get showPlan => _showPlan;
  bool get showGoals => _showGoals;
  bool get showAchievements => _showAchievements;
  bool get showBudget => _showBudget;
  bool get showStatistics => _showStatistics;
  bool get showExpensesChart => _showExpensesChart;
  bool get showLinkedAccounts => _showLinkedAccounts;

  DashboardSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _showPlan = prefs.getBool(_keyShowPlan) ?? true;
    _showGoals = prefs.getBool(_keyShowGoals) ?? true;
    _showAchievements = prefs.getBool(_keyShowAchievements) ?? true;
    _showBudget = prefs.getBool(_keyShowBudget) ?? true;
    _showStatistics = prefs.getBool(_keyShowStatistics) ?? true;
    _showExpensesChart = prefs.getBool(_keyShowExpensesChart) ?? true;
    _showLinkedAccounts = prefs.getBool(_keyShowLinkedAccounts) ?? true;
    notifyListeners();
  }

  Future<void> setShowPlan(bool v) async {
    _showPlan = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowPlan, v));
    notifyListeners();
  }

  Future<void> setShowGoals(bool v) async {
    _showGoals = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowGoals, v));
    notifyListeners();
  }

  Future<void> setShowAchievements(bool v) async {
    _showAchievements = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowAchievements, v));
    notifyListeners();
  }

  Future<void> setShowBudget(bool v) async {
    _showBudget = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowBudget, v));
    notifyListeners();
  }

  Future<void> setShowStatistics(bool v) async {
    _showStatistics = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowStatistics, v));
    notifyListeners();
  }

  Future<void> setShowExpensesChart(bool v) async {
    _showExpensesChart = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowExpensesChart, v));
    notifyListeners();
  }

  Future<void> setShowLinkedAccounts(bool v) async {
    _showLinkedAccounts = v;
    await SharedPreferences.getInstance().then((p) => p.setBool(_keyShowLinkedAccounts, v));
    notifyListeners();
  }
}
