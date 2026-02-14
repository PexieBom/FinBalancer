// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Saldo totale';

  @override
  String get allWallets => 'Tutti i portafogli';

  @override
  String get income => 'Entrate';

  @override
  String get expense => 'Uscite';

  @override
  String get goals => 'Obiettivi';

  @override
  String goalsSubtitle(int count) {
    return '$count obiettivi · Segui risparmi e progressi';
  }

  @override
  String get statistics => 'Statistiche';

  @override
  String get statisticsSubtitle => 'Grafici, spese per categoria, tendenze';

  @override
  String get expensesByCategory => 'Spese per categoria';

  @override
  String get recentTransactions => 'Transazioni recenti';

  @override
  String get addTransaction => 'Aggiungi transazione';

  @override
  String get noTransactionsYet => 'Nessuna transazione ancora';

  @override
  String get achievements => 'Risultati';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get categories => 'Categorie';

  @override
  String get retry => 'Riprova';

  @override
  String get cannotConnectApi => 'Impossibile connettersi all\'API';

  @override
  String get ensureBackendRunning =>
      'Assicurati che il backend sia attivo su localhost:5292';

  @override
  String get home => 'Home';

  @override
  String get add => 'Aggiungi';

  @override
  String get stats => 'Statistiche';

  @override
  String get wallets => 'Portafogli';

  @override
  String get newGoal => 'Nuovo obiettivo';

  @override
  String get goalName => 'Nome obiettivo';

  @override
  String get targetAmount => 'Importo obiettivo';

  @override
  String get deadlineOptional => 'Scadenza (opzionale)';

  @override
  String deadline(String date) {
    return 'Scadenza: $date';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get create => 'Crea';

  @override
  String addToGoal(String name) {
    return 'Aggiungi a \"$name\"';
  }

  @override
  String get amount => 'Importo';

  @override
  String get deleteGoal => 'Eliminare obiettivo?';

  @override
  String removeGoal(String name) {
    return 'Rimuovere \"$name\"?';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get noGoalsYet => 'Nessun obiettivo ancora';

  @override
  String get createSavingsGoal =>
      'Crea un obiettivo di risparmio e segui i progressi';

  @override
  String get createGoal => 'Crea obiettivo';

  @override
  String due(String date) {
    return 'Scadenza: $date';
  }

  @override
  String get addToGoalButton => 'Aggiungi all\'obiettivo';

  @override
  String get addTransactionTitle => 'Aggiungi transazione';

  @override
  String get addWalletFirst => 'Aggiungi prima un portafoglio';

  @override
  String get needWalletFirst =>
      'Serve almeno un portafoglio per le transazioni.';

  @override
  String get addWallet => 'Aggiungi portafoglio';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Uscita';

  @override
  String get incomeLabel => 'Entrata';

  @override
  String get category => 'Categoria';

  @override
  String get subcategoryOptional => 'Sottocategoria (opzionale)';

  @override
  String get none => '— Nessuno —';

  @override
  String get wallet => 'Portafoglio';

  @override
  String get noteOptional => 'Nota (opzionale)';

  @override
  String get projectOptional => 'Progetto (opzionale)';

  @override
  String get projectHint => 'es. Vacanze 2025';

  @override
  String get tagsOptional => 'Tag (opzionale)';

  @override
  String get tagHint => '+ tag';

  @override
  String get saveTransaction => 'Salva transazione';

  @override
  String get required => 'Obbligatorio';

  @override
  String get enterValidAmount => 'Inserisci importo valido';

  @override
  String get pleaseSelectWallet => 'Seleziona un portafoglio';

  @override
  String get pleaseSelectCategory => 'Seleziona una categoria';

  @override
  String get pleaseEnterValidAmount => 'Inserisci un importo valido';

  @override
  String get statisticsTitle => 'Statistiche';

  @override
  String get noDataAvailable => 'Nessun dato disponibile';

  @override
  String get failedToLoadStatistics => 'Caricamento statistiche fallito';

  @override
  String get overview => 'Panoramica';

  @override
  String get balance => 'Saldo';

  @override
  String get budgetAlerts => 'Avvisi budget';

  @override
  String get predictedSpendingNextMonth => 'Spese previste (prossimo mese)';

  @override
  String get basedOnLast3Months => 'Basato sulla media degli ultimi 3 mesi +5%';

  @override
  String get totalPredicted => 'Totale previsto';

  @override
  String get cashflowTrend => 'Trend flusso di cassa';

  @override
  String get incomeVsExpenseByMonth => 'Entrate vs uscite per mese';

  @override
  String get net => 'Netto';

  @override
  String get spendingByCategory => 'Spese per categoria';

  @override
  String get noExpenseDataYet => 'Nessun dato spese ancora';

  @override
  String get monthlyOverview => 'Panoramica mensile';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Registrati';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Nome visualizzato';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get orContinueWith => 'Oppure continua con';

  @override
  String get noAccount => 'Non hai un account? Registrati';

  @override
  String get hasAccount => 'Hai già un account? Accedi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get premiumFeatures => 'Premium features';

  @override
  String get language => 'Lingua';

  @override
  String get currency => 'Valuta';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get selectCurrency => 'Seleziona valuta';

  @override
  String get logout => 'Esci';

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
}
