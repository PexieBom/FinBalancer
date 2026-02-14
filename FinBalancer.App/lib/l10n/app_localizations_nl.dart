// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Totaal saldo';

  @override
  String get allWallets => 'Alle portemonnees';

  @override
  String get income => 'Inkomsten';

  @override
  String get expense => 'Uitgaven';

  @override
  String get goals => 'Doelen';

  @override
  String goalsSubtitle(int count) {
    return '$count doelen · Volg sparen en voortgang';
  }

  @override
  String get statistics => 'Statistieken';

  @override
  String get statisticsSubtitle => 'Grafieken, uitgaven per categorie, trends';

  @override
  String get expensesByCategory => 'Uitgaven per categorie';

  @override
  String get recentTransactions => 'Recente transacties';

  @override
  String get addTransaction => 'Transactie toevoegen';

  @override
  String get noTransactionsYet => 'Nog geen transacties';

  @override
  String get achievements => 'Prestaties';

  @override
  String get exportData => 'Data exporteren';

  @override
  String get categories => 'Categorieën';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get cannotConnectApi => 'Geen verbinding met API';

  @override
  String get ensureBackendRunning =>
      'Controleer of de backend draait op localhost:5292';

  @override
  String get home => 'Home';

  @override
  String get add => 'Toevoegen';

  @override
  String get stats => 'Statistieken';

  @override
  String get wallets => 'Portemonnees';

  @override
  String get newGoal => 'Nieuw doel';

  @override
  String get goalName => 'Doelnaam';

  @override
  String get targetAmount => 'Doelbedrag';

  @override
  String get deadlineOptional => 'Deadline (optioneel)';

  @override
  String deadline(String date) {
    return 'Deadline: $date';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get create => 'Aanmaken';

  @override
  String addToGoal(String name) {
    return 'Toevoegen aan \"$name\"';
  }

  @override
  String get amount => 'Bedrag';

  @override
  String get deleteGoal => 'Doel verwijderen?';

  @override
  String removeGoal(String name) {
    return '\"$name\" verwijderen?';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String get noGoalsYet => 'Nog geen doelen';

  @override
  String get createSavingsGoal => 'Maak een spaardoel en volg je voortgang';

  @override
  String get createGoal => 'Doel aanmaken';

  @override
  String due(String date) {
    return 'Vervaldatum: $date';
  }

  @override
  String get addToGoalButton => 'Toevoegen aan doel';

  @override
  String get addTransactionTitle => 'Transactie toevoegen';

  @override
  String get addWalletFirst => 'Voeg eerst een portemonnee toe';

  @override
  String get needWalletFirst =>
      'Je hebt minimaal één portemonnee nodig voor transacties.';

  @override
  String get addWallet => 'Portemonnee toevoegen';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Uitgave';

  @override
  String get incomeLabel => 'Inkomsten';

  @override
  String get category => 'Categorie';

  @override
  String get subcategoryOptional => 'Subcategorie (optioneel)';

  @override
  String get none => '— Geen —';

  @override
  String get wallet => 'Portemonnee';

  @override
  String get noteOptional => 'Opmerking (optioneel)';

  @override
  String get projectOptional => 'Project (optioneel)';

  @override
  String get projectHint => 'bijv. Vakantie 2025';

  @override
  String get tagsOptional => 'Tags (optioneel)';

  @override
  String get tagHint => '+ tag';

  @override
  String get saveTransaction => 'Transactie opslaan';

  @override
  String get required => 'Verplicht';

  @override
  String get enterValidAmount => 'Voer een geldig bedrag in';

  @override
  String get pleaseSelectWallet => 'Selecteer een portemonnee';

  @override
  String get pleaseSelectCategory => 'Selecteer een categorie';

  @override
  String get pleaseEnterValidAmount => 'Voer een geldig bedrag in';

  @override
  String get statisticsTitle => 'Statistieken';

  @override
  String get noDataAvailable => 'Geen gegevens beschikbaar';

  @override
  String get failedToLoadStatistics => 'Statistieken laden mislukt';

  @override
  String get overview => 'Overzicht';

  @override
  String get balance => 'Saldo';

  @override
  String get budgetAlerts => 'Budgetwaarschuwingen';

  @override
  String get predictedSpendingNextMonth =>
      'Verwachte uitgaven (volgende maand)';

  @override
  String get basedOnLast3Months =>
      'Gebaseerd op gemiddelde laatste 3 maanden +5%';

  @override
  String get totalPredicted => 'Totaal verwacht';

  @override
  String get cashflowTrend => 'Kasstroomtrend';

  @override
  String get incomeVsExpenseByMonth => 'Inkomsten vs uitgaven per maand';

  @override
  String get net => 'Netto';

  @override
  String get spendingByCategory => 'Uitgaven per categorie';

  @override
  String get noExpenseDataYet => 'Nog geen uitgavengegevens';

  @override
  String get monthlyOverview => 'Maandelijks overzicht';

  @override
  String get unknown => 'Onbekend';

  @override
  String get login => 'Inloggen';

  @override
  String get register => 'Registreren';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get displayName => 'Weergavenaam';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get orContinueWith => 'Of ga verder met';

  @override
  String get noAccount => 'Geen account? Registreer';

  @override
  String get hasAccount => 'Al een account? Inloggen';

  @override
  String get settings => 'Instellingen';

  @override
  String get premiumFeatures => 'Premium features';

  @override
  String get language => 'Taal';

  @override
  String get currency => 'Valuta';

  @override
  String get selectLanguage => 'Selecteer taal';

  @override
  String get selectCurrency => 'Selecteer valuta';

  @override
  String get logout => 'Uitloggen';

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
