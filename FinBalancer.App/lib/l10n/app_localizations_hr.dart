// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Nadzorna ploča';

  @override
  String get totalBalance => 'Ukupni saldo';

  @override
  String get allWallets => 'Svi novčanici';

  @override
  String get income => 'Prihodi';

  @override
  String get expense => 'Rashodi';

  @override
  String get goals => 'Ciljevi';

  @override
  String goalsSubtitle(int count) {
    return '$count ciljeva · Pratite štednju i napredak';
  }

  @override
  String get statistics => 'Statistika';

  @override
  String get statisticsSubtitle =>
      'Grafovi, troškovi po kategorijama, trendovi';

  @override
  String get expensesByCategory => 'Rashodi po kategorijama';

  @override
  String get recentTransactions => 'Nedavne transakcije';

  @override
  String get addTransaction => 'Dodaj transakciju';

  @override
  String get noTransactionsYet => 'Još nema transakcija';

  @override
  String get achievements => 'Postignuća';

  @override
  String get exportData => 'Izvezi podatke';

  @override
  String get categories => 'Kategorije';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get cannotConnectApi => 'Nema veze s API-jem';

  @override
  String get ensureBackendRunning =>
      'Provjerite da backend radi na localhost:5292';

  @override
  String get home => 'Početna';

  @override
  String get add => 'Dodaj';

  @override
  String get loadMore => 'Učitaj više';

  @override
  String get stats => 'Statistika';

  @override
  String get wallets => 'Novčanici';

  @override
  String get walletsBudgets => 'Novčanici / Budžeti';

  @override
  String get newGoal => 'Novi cilj';

  @override
  String get goalName => 'Naziv cilja';

  @override
  String get targetAmount => 'Ciljni iznos';

  @override
  String get deadlineOptional => 'Rok (opcionalno)';

  @override
  String deadline(String date) {
    return 'Rok: $date';
  }

  @override
  String get cancel => 'Odustani';

  @override
  String get create => 'Kreiraj';

  @override
  String addToGoal(String name) {
    return 'Dodaj u \"$name\"';
  }

  @override
  String get amount => 'Iznos';

  @override
  String get deleteGoal => 'Izbriši cilj?';

  @override
  String removeGoal(String name) {
    return 'Ukloniti \"$name\"?';
  }

  @override
  String get delete => 'Izbriši';

  @override
  String get deleteTransactionConfirm => 'Izbriši transakciju?';

  @override
  String get deleteTransactionConfirmMessage =>
      'Jeste li sigurni da želite izbrisati transakciju?';

  @override
  String get noGoalsYet => 'Još nema ciljeva';

  @override
  String get createSavingsGoal => 'Kreirajte cilj štednje i pratite napredak';

  @override
  String get createGoal => 'Kreiraj cilj';

  @override
  String due(String date) {
    return 'Rok: $date';
  }

  @override
  String get addToGoalButton => 'Dodaj u cilj';

  @override
  String get addTransactionTitle => 'Dodaj transakciju';

  @override
  String get editTransaction => 'Uredi transakciju';

  @override
  String get addWalletFirst => 'Prvo dodajte novčanik';

  @override
  String get needWalletFirst =>
      'Potreban vam je barem jedan novčanik za dodavanje transakcija.';

  @override
  String get addWallet => 'Dodaj novčanik';

  @override
  String get editWallet => 'Uredi novčanik';

  @override
  String get newWallet => 'Novi novčanik';

  @override
  String get expenseLabel => 'Rashod';

  @override
  String get incomeLabel => 'Prihod';

  @override
  String get category => 'Kategorija';

  @override
  String get subcategoryOptional => 'Podkategorija (opcionalno)';

  @override
  String get none => '— Ništa —';

  @override
  String get wallet => 'Novčanik';

  @override
  String get noteOptional => 'Napomena (opcionalno)';

  @override
  String get projectOptional => 'Projekt (opcionalno)';

  @override
  String get projectHint => 'npr. Odmor 2025';

  @override
  String get tagsOptional => 'Oznake (opcionalno)';

  @override
  String get tagHint => '+ oznaka';

  @override
  String get saveTransaction => 'Spremi transakciju';

  @override
  String get required => 'Obavezno';

  @override
  String get enterValidAmount => 'Unesite valjani iznos';

  @override
  String get pleaseSelectWallet => 'Odaberite novčanik';

  @override
  String get pleaseSelectCategory => 'Odaberite kategoriju';

  @override
  String get pleaseEnterValidAmount => 'Unesite valjani iznos';

  @override
  String get statisticsTitle => 'Statistika';

  @override
  String get noDataAvailable => 'Nema dostupnih podataka';

  @override
  String get failedToLoadStatistics => 'Učitavanje statistike nije uspjelo';

  @override
  String get overview => 'Pregled';

  @override
  String get balance => 'Saldo';

  @override
  String get budgetAlerts => 'Upozorenja budžeta';

  @override
  String get predictedSpendingNextMonth =>
      'Predviđeni rashodi (sljedeći mjesec)';

  @override
  String get basedOnLast3Months => 'Na temelju prosjeka zadnjih 3 mjeseca +5%';

  @override
  String get totalPredicted => 'Ukupno predviđeno';

  @override
  String get cashflowTrend => 'Trend gotovinskog toka';

  @override
  String get incomeVsExpenseByMonth => 'Prihodi naspram rashoda po mjesecu';

  @override
  String get net => 'Neto';

  @override
  String get spendingByCategory => 'Troškovi po kategorijama';

  @override
  String get noExpenseDataYet => 'Još nema podataka o rashodima';

  @override
  String get monthlyOverview => 'Mjesečni pregled';

  @override
  String get unknown => 'Nepoznato';

  @override
  String get decisionEngine => 'Decision Engine';

  @override
  String get decisionEngineSubtitle =>
      'Unesite iznos i opis da vidite kako se uspoređuje s mjesečnim prihodom.';

  @override
  String get decisionEngineDescription => 'Opis (opcionalno)';

  @override
  String get decisionEngineResult => 'Ocjena';

  @override
  String get decisionEnginePercentOfIncome => 'Postotak mjesečnog prihoda';

  @override
  String get decisionEngineScore => 'Ocjena (0-10)';

  @override
  String get evaluate => 'Ocijeni';

  @override
  String get yearlyExpenseFlag => 'Trošak jednom godišnje';

  @override
  String get yearlyExpenseFlagHint =>
      'Izuzeo iz predviđanja za idući mjesec (npr. osiguranje, godišnja naknada)';

  @override
  String get login => 'Prijava';

  @override
  String get register => 'Registracija';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Lozinka';

  @override
  String get displayName => 'Ime za prikaz';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get orContinueWith => 'Ili nastavite s';

  @override
  String get noAccount => 'Nemate račun? Registrirajte se';

  @override
  String get hasAccount => 'Već imate račun? Prijavite se';

  @override
  String get settings => 'Postavke';

  @override
  String get premiumFeatures => 'Premium značajke';

  @override
  String get freePlan => 'Besplatan plan';

  @override
  String get upgradeToPremium => 'Nadogradnja na Premium';

  @override
  String get plan => 'Plan';

  @override
  String get premiumMonthly => 'Premium mjesečno';

  @override
  String get premiumYearly => 'Premium godišnje';

  @override
  String get choosePlan => 'Odaberite plan';

  @override
  String get language => 'Jezik';

  @override
  String get currency => 'Valuta';

  @override
  String get selectLanguage => 'Odaberite jezik';

  @override
  String get selectCurrency => 'Odaberite valutu';

  @override
  String get logout => 'Odjava';

  @override
  String get csv => 'CSV';

  @override
  String get json => 'JSON';

  @override
  String get pdfHtml => 'PDF (HTML)';

  @override
  String get manageProjects => 'Upravljaj projektima';

  @override
  String get projects => 'Projekti';

  @override
  String get period => 'Razdoblje';

  @override
  String get last1Month => 'Zadnjih 1 mjesec';

  @override
  String get last3Months => 'Zadnjih 3 mjeseca';

  @override
  String get last6Months => 'Zadnjih 6 mjeseci';

  @override
  String get last12Months => 'Zadnjih 12 mjeseci';

  @override
  String get thisYear => 'Ova godina';

  @override
  String get customRange => 'Prilagođeni raspon';

  @override
  String get resetToDefault => 'Vrati na zadano';

  @override
  String get noCategoriesYet => 'Još nema kategorija';

  @override
  String get categoriesLoadFromApi => 'Kategorije se učitavaju s API-ja';

  @override
  String get newCustomCategory => 'Nova prilagođena kategorija';

  @override
  String get deleteCategoryQuestion => 'Izbrisati kategoriju?';

  @override
  String removeCategoryQuestion(String name) {
    return 'Ukloniti \"$name\"?';
  }

  @override
  String get nameLabel => 'Naziv';

  @override
  String get walletNameHint => 'npr. Glavni račun';

  @override
  String get initialBalance => 'Početni saldo';

  @override
  String get currencyHint => 'EUR';

  @override
  String get deleteWalletQuestion => 'Izbrisati novčanik?';

  @override
  String removeWalletQuestion(String name) {
    return 'Ukloniti \"$name\"?';
  }

  @override
  String get transactionsMayBeAffected =>
      'Transakcije povezane s ovim novčanikom mogu biti pogođene.';

  @override
  String get deleteProjectQuestion => 'Izbrisati projekt?';

  @override
  String removeProjectQuestion(String name) {
    return 'Ukloniti \"$name\"?';
  }

  @override
  String get projectsTitle => 'Projekti';

  @override
  String get noProjectsYet => 'Još nema projekata';

  @override
  String get projectsSubtitle => 'Dodajte projekt za grupiranje transakcija';

  @override
  String get descriptionOptional => 'Opis (opcionalno)';

  @override
  String get save => 'Spremi';

  @override
  String get projectNameHint => 'npr. Odmor 2025';

  @override
  String get noAchievementsYet => 'Još nema postignuća';

  @override
  String get achievementsSubtitle =>
      'Dodajte transakcije i postignite ciljeve za otključavanje postignuća';

  @override
  String get unlocked => 'Otključano';

  @override
  String get allAchievements => 'Sva postignuća';

  @override
  String unlockedOn(String date) {
    return 'Otključano: $date';
  }

  @override
  String get budgets => 'Budžeti';

  @override
  String get budget => 'Budžet';

  @override
  String get spent => 'Potrošeno';

  @override
  String get remaining => 'Preostalo';

  @override
  String get allowancePerDay => 'Dnevno dopušteno';

  @override
  String get onTrack => 'U planu';

  @override
  String get overPace => 'Prekoračeno';

  @override
  String get underPace => 'Ispod plana';

  @override
  String get setBudget => 'Postavi budžet';

  @override
  String get addBudget => 'Dodaj budžet';

  @override
  String get editBudget => 'Uredi budžet';

  @override
  String get budgetAmount => 'Iznos budžeta';

  @override
  String get periodStartDay => 'Početni dan razdoblja (1–28)';

  @override
  String get noBudgetsYet => 'Još nema budžeta';

  @override
  String get addBudgetForWallet => 'Dodaj mjesečni budžet za novčanik';

  @override
  String get deleteBudgetQuestion => 'Izbrisati budžet?';

  @override
  String get noWalletsForBudget =>
      'Prvo dodajte novčanik za postavljanje budžeta.';

  @override
  String get customizeDashboard => 'Prilagodi nadzornu ploču';

  @override
  String get showPlan => 'Plan';

  @override
  String get showGoals => 'Ciljevi';

  @override
  String get showAchievements => 'Postignuća';

  @override
  String get showBudget => 'Budžet';

  @override
  String get showStatistics => 'Statistika';

  @override
  String get showExpensesChart => 'Graf rashoda';
}
