// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Gesamtguthaben';

  @override
  String get allWallets => 'Alle Geldbörsen';

  @override
  String get income => 'Einnahmen';

  @override
  String get expense => 'Ausgaben';

  @override
  String get goals => 'Ziele';

  @override
  String goalsSubtitle(int count) {
    return '$count Ziele · Sparen & Fortschritt verfolgen';
  }

  @override
  String get statistics => 'Statistik';

  @override
  String get statisticsSubtitle => 'Diagramme, Ausgaben nach Kategorie, Trends';

  @override
  String get expensesByCategory => 'Ausgaben nach Kategorie';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get addTransaction => 'Transaktion hinzufügen';

  @override
  String get noTransactionsYet => 'Noch keine Transaktionen';

  @override
  String get achievements => 'Erfolge';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get categories => 'Kategorien';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cannotConnectApi => 'Keine Verbindung zur API';

  @override
  String get ensureBackendRunning =>
      'Stellen Sie sicher, dass das Backend auf localhost:5292 läuft';

  @override
  String get home => 'Start';

  @override
  String get add => 'Hinzufügen';

  @override
  String get loadMore => 'Load more';

  @override
  String get stats => 'Statistik';

  @override
  String get wallets => 'Geldbörsen';

  @override
  String get walletsBudgets => 'Wallets / Budgets';

  @override
  String get newGoal => 'Neues Ziel';

  @override
  String get goalName => 'Zielname';

  @override
  String get targetAmount => 'Zielbetrag';

  @override
  String get deadlineOptional => 'Frist (optional)';

  @override
  String deadline(String date) {
    return 'Frist: $date';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String addToGoal(String name) {
    return 'Zu \"$name\" hinzufügen';
  }

  @override
  String get amount => 'Betrag';

  @override
  String get deleteGoal => 'Ziel löschen?';

  @override
  String removeGoal(String name) {
    return '\"$name\" entfernen?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get deleteTransactionConfirm => 'Delete transaction?';

  @override
  String get deleteTransactionConfirmMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get noGoalsYet => 'Noch keine Ziele';

  @override
  String get createSavingsGoal =>
      'Erstellen Sie ein Sparziel und verfolgen Sie den Fortschritt';

  @override
  String get createGoal => 'Ziel erstellen';

  @override
  String due(String date) {
    return 'Fällig: $date';
  }

  @override
  String get addToGoalButton => 'Zum Ziel hinzufügen';

  @override
  String get addTransactionTitle => 'Transaktion hinzufügen';

  @override
  String get editTransaction => 'Transaktion bearbeiten';

  @override
  String get addWalletFirst => 'Zuerst Geldbörse hinzufügen';

  @override
  String get needWalletFirst =>
      'Sie benötigen mindestens eine Geldbörse für Transaktionen.';

  @override
  String get addWallet => 'Geldbörse hinzufügen';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Ausgabe';

  @override
  String get incomeLabel => 'Einnahme';

  @override
  String get category => 'Kategorie';

  @override
  String get subcategoryOptional => 'Unterkategorie (optional)';

  @override
  String get none => '— Keine —';

  @override
  String get wallet => 'Geldbörse';

  @override
  String get noteOptional => 'Notiz (optional)';

  @override
  String get projectOptional => 'Projekt (optional)';

  @override
  String get projectHint => 'z.B. Urlaub 2025';

  @override
  String get tagsOptional => 'Tags (optional)';

  @override
  String get tagHint => '+ Tag';

  @override
  String get saveTransaction => 'Transaktion speichern';

  @override
  String get required => 'Erforderlich';

  @override
  String get enterValidAmount => 'Gültigen Betrag eingeben';

  @override
  String get pleaseSelectWallet => 'Bitte Geldbörse wählen';

  @override
  String get pleaseSelectCategory => 'Bitte Kategorie wählen';

  @override
  String get pleaseEnterValidAmount => 'Bitte gültigen Betrag eingeben';

  @override
  String get statisticsTitle => 'Statistik';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get failedToLoadStatistics => 'Statistik konnte nicht geladen werden';

  @override
  String get overview => 'Übersicht';

  @override
  String get balance => 'Guthaben';

  @override
  String get budgetAlerts => 'Budget-Warnungen';

  @override
  String get predictedSpendingNextMonth =>
      'Vorhergesagte Ausgaben (nächster Monat)';

  @override
  String get basedOnLast3Months =>
      'Basierend auf dem Durchschnitt der letzten 3 Monate +5%';

  @override
  String get totalPredicted => 'Gesamt vorhergesagt';

  @override
  String get cashflowTrend => 'Cashflow-Trend';

  @override
  String get incomeVsExpenseByMonth => 'Einnahmen vs. Ausgaben pro Monat';

  @override
  String get net => 'Netto';

  @override
  String get spendingByCategory => 'Ausgaben nach Kategorie';

  @override
  String get noExpenseDataYet => 'Noch keine Ausgabendaten';

  @override
  String get monthlyOverview => 'Monatliche Übersicht';

  @override
  String get unknown => 'Unbekannt';

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
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get orContinueWith => 'Oder fortfahren mit';

  @override
  String get noAccount => 'Kein Konto? Registrieren';

  @override
  String get hasAccount => 'Bereits Konto? Anmelden';

  @override
  String get settings => 'Einstellungen';

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
  String get language => 'Sprache';

  @override
  String get currency => 'Währung';

  @override
  String get selectLanguage => 'Sprache wählen';

  @override
  String get selectCurrency => 'Währung wählen';

  @override
  String get logout => 'Abmelden';

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
