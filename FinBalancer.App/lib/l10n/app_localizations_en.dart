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
  String get loadMore => 'Load more';

  @override
  String get stats => 'Stats';

  @override
  String get wallets => 'Wallets';

  @override
  String get walletsBudgets => 'Wallets / Budgets';

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
  String get deleteTransactionConfirm => 'Delete transaction?';

  @override
  String get deleteTransactionConfirmMessage =>
      'Are you sure you want to delete this transaction?';

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
  String get editTransaction => 'Edit Transaction';

  @override
  String get addWalletFirst => 'Add a wallet first';

  @override
  String get needWalletFirst =>
      'You need at least one wallet to add transactions.';

  @override
  String get addWallet => 'Add Wallet';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

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
  String get decisionEngine => 'Decision Engine';

  @override
  String get decisionEngineSubtitle =>
      'Enter an amount and description to see how it compares to your monthly income.';

  @override
  String get decisionEngineDescription => 'Description (optional)';

  @override
  String get decisionEngineResult => 'Evaluation';

  @override
  String get decisionEnginePercentOfIncome => 'Percent of monthly income';

  @override
  String get decisionEngineScore => 'Score (0-10)';

  @override
  String get evaluate => 'Evaluate';

  @override
  String get yearlyExpenseFlag => 'Yearly expense (once per year)';

  @override
  String get yearlyExpenseFlagHint =>
      'Excluded from next month prediction (e.g. insurance, annual fee)';

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
  String get freePlan => 'Free plan';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get plan => 'Plan';

  @override
  String get premiumMonthly => 'Premium Monthly';

  @override
  String get premiumYearly => 'Premium Yearly';

  @override
  String get choosePlan => 'Choose your plan';

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

  @override
  String get manageProjects => 'Manage projects';

  @override
  String get projects => 'Projects';

  @override
  String get period => 'Period';

  @override
  String get last1Month => 'Last 1 month';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get last12Months => 'Last 12 months';

  @override
  String get thisYear => 'This year';

  @override
  String get customRange => 'Custom range';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get categoriesLoadFromApi => 'Categories are loaded from the API';

  @override
  String get newCustomCategory => 'New custom category';

  @override
  String get deleteCategoryQuestion => 'Delete category?';

  @override
  String removeCategoryQuestion(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get nameLabel => 'Name';

  @override
  String get walletNameHint => 'e.g. Main Account';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get currencyHint => 'EUR';

  @override
  String get deleteWalletQuestion => 'Delete wallet?';

  @override
  String removeWalletQuestion(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get transactionsMayBeAffected =>
      'Transactions linked to this wallet may be affected.';

  @override
  String get deleteProjectQuestion => 'Delete Project?';

  @override
  String removeProjectQuestion(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get projectsTitle => 'Projects';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get projectsSubtitle => 'Add a project to group transactions';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get save => 'Save';

  @override
  String get projectNameHint => 'e.g. Vacation 2025';

  @override
  String get noAchievementsYet => 'No achievements yet';

  @override
  String get achievementsSubtitle =>
      'Add transactions and reach goals to unlock achievements';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get allAchievements => 'All Achievements';

  @override
  String unlockedOn(String date) {
    return 'Unlocked: $date';
  }

  @override
  String get budgets => 'Budgets';

  @override
  String get budget => 'Budget';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get allowancePerDay => 'Allowance/day';

  @override
  String get onTrack => 'On track';

  @override
  String get overPace => 'Over pace';

  @override
  String get underPace => 'Under pace';

  @override
  String get setBudget => 'Set a budget';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get periodStartDay => 'Period start day (1–28)';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get addBudgetForWallet => 'Add a monthly budget for a wallet';

  @override
  String get deleteBudgetQuestion => 'Delete budget?';

  @override
  String get noWalletsForBudget => 'Add a wallet first to set budgets.';

  @override
  String get customizeDashboard => 'Customize dashboard';

  @override
  String get showPlan => 'Plan';

  @override
  String get showGoals => 'Goals';

  @override
  String get showAchievements => 'Achievements';

  @override
  String get showBudget => 'Budget';

  @override
  String get showStatistics => 'Statistics';

  @override
  String get showExpensesChart => 'Expenses chart';
}
