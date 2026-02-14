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
  String get stats => 'Statistik';

  @override
  String get wallets => 'Geldbörsen';

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
  String get addWalletFirst => 'Zuerst Geldbörse hinzufügen';

  @override
  String get needWalletFirst =>
      'Sie benötigen mindestens eine Geldbörse für Transaktionen.';

  @override
  String get addWallet => 'Geldbörse hinzufügen';

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
}
