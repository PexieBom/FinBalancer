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
  String get stats => 'Statistika';

  @override
  String get wallets => 'Novčanici';

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
  String get addWalletFirst => 'Prvo dodajte novčanik';

  @override
  String get needWalletFirst =>
      'Potreban vam je barem jedan novčanik za dodavanje transakcija.';

  @override
  String get addWallet => 'Dodaj novčanik';

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
}
