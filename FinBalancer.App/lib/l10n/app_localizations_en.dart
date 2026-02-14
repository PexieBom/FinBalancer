// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get allWallets => 'All Wallets';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get goals => 'Goals';

  @override
  String goalsSubtitle(int count) {
    return '$count goals · Track savings & progress';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsSubtitle => 'Charts, spending by category, trends';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get achievements => 'Achievements';

  @override
  String get exportData => 'Export data';

  @override
  String get categories => 'Categories';

  @override
  String get retry => 'Retry';

  @override
  String get cannotConnectApi => 'Cannot connect to API';

  @override
  String get ensureBackendRunning =>
      'Ensure the backend is running on localhost:5292';

  @override
  String get home => 'Home';

  @override
  String get add => 'Add';

  @override
  String get stats => 'Stats';

  @override
  String get wallets => 'Wallets';

  @override
  String get newGoal => 'New Goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get deadlineOptional => 'Deadline (optional)';

  @override
  String deadline(String date) {
    return 'Deadline: $date';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String addToGoal(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String get amount => 'Amount';

  @override
  String get deleteGoal => 'Delete Goal?';

  @override
  String removeGoal(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get createSavingsGoal =>
      'Create a savings goal and track your progress';

  @override
  String get createGoal => 'Create Goal';

  @override
  String due(String date) {
    return 'Due: $date';
  }

  @override
  String get addToGoalButton => 'Add to goal';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get addWalletFirst => 'Add a wallet first';

  @override
  String get needWalletFirst =>
      'You need at least one wallet to add transactions.';

  @override
  String get addWallet => 'Add Wallet';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get incomeLabel => 'Income';

  @override
  String get category => 'Category';

  @override
  String get subcategoryOptional => 'Subcategory (optional)';

  @override
  String get none => '— None —';

  @override
  String get wallet => 'Wallet';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get projectOptional => 'Project (optional)';

  @override
  String get projectHint => 'e.g. Vacation 2025';

  @override
  String get tagsOptional => 'Tags (optional)';

  @override
  String get tagHint => '+ tag';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get required => 'Required';

  @override
  String get enterValidAmount => 'Enter valid amount';

  @override
  String get pleaseSelectWallet => 'Please select a wallet';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get failedToLoadStatistics => 'Failed to load statistics';

  @override
  String get overview => 'Overview';

  @override
  String get balance => 'Balance';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get predictedSpendingNextMonth => 'Predicted Spending (Next Month)';

  @override
  String get basedOnLast3Months => 'Based on your last 3 months average +5%';

  @override
  String get totalPredicted => 'Total predicted';

  @override
  String get cashflowTrend => 'Cashflow Trend';

  @override
  String get incomeVsExpenseByMonth => 'Income vs expense by month';

  @override
  String get net => 'Net';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get noExpenseDataYet => 'No expense data yet';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get unknown => 'Unknown';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get hasAccount => 'Already have an account? Sign in';

  @override
  String get settings => 'Settings';

  @override
  String get premiumFeatures => 'Premium features';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get logout => 'Logout';

  @override
  String get csv => 'CSV';

  @override
  String get json => 'JSON';

  @override
  String get pdfHtml => 'PDF (HTML)';
}
