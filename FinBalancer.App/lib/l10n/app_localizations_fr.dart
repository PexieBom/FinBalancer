// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get allWallets => 'Tous les portefeuilles';

  @override
  String get income => 'Revenus';

  @override
  String get expense => 'Dépenses';

  @override
  String get goals => 'Objectifs';

  @override
  String goalsSubtitle(int count) {
    return '$count objectifs · Suivi épargne et progrès';
  }

  @override
  String get statistics => 'Statistiques';

  @override
  String get statisticsSubtitle =>
      'Graphiques, dépenses par catégorie, tendances';

  @override
  String get expensesByCategory => 'Dépenses par catégorie';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get addTransaction => 'Ajouter une transaction';

  @override
  String get noTransactionsYet => 'Aucune transaction pour l\'instant';

  @override
  String get achievements => 'Réalisations';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get categories => 'Catégories';

  @override
  String get retry => 'Réessayer';

  @override
  String get cannotConnectApi => 'Impossible de se connecter à l\'API';

  @override
  String get ensureBackendRunning =>
      'Vérifiez que le backend fonctionne sur localhost:5292';

  @override
  String get home => 'Accueil';

  @override
  String get add => 'Ajouter';

  @override
  String get stats => 'Stats';

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get newGoal => 'Nouvel objectif';

  @override
  String get goalName => 'Nom de l\'objectif';

  @override
  String get targetAmount => 'Montant cible';

  @override
  String get deadlineOptional => 'Date limite (optionnel)';

  @override
  String deadline(String date) {
    return 'Date limite : $date';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String addToGoal(String name) {
    return 'Ajouter à \"$name\"';
  }

  @override
  String get amount => 'Montant';

  @override
  String get deleteGoal => 'Supprimer l\'objectif ?';

  @override
  String removeGoal(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get noGoalsYet => 'Aucun objectif pour l\'instant';

  @override
  String get createSavingsGoal =>
      'Créez un objectif d\'épargne et suivez vos progrès';

  @override
  String get createGoal => 'Créer un objectif';

  @override
  String due(String date) {
    return 'Échéance : $date';
  }

  @override
  String get addToGoalButton => 'Ajouter à l\'objectif';

  @override
  String get addTransactionTitle => 'Ajouter une transaction';

  @override
  String get addWalletFirst => 'Ajoutez d\'abord un portefeuille';

  @override
  String get needWalletFirst =>
      'Vous avez besoin d\'au moins un portefeuille pour les transactions.';

  @override
  String get addWallet => 'Ajouter un portefeuille';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Dépense';

  @override
  String get incomeLabel => 'Revenu';

  @override
  String get category => 'Catégorie';

  @override
  String get subcategoryOptional => 'Sous-catégorie (optionnel)';

  @override
  String get none => '— Aucun —';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String get projectOptional => 'Projet (optionnel)';

  @override
  String get projectHint => 'ex. Vacances 2025';

  @override
  String get tagsOptional => 'Tags (optionnel)';

  @override
  String get tagHint => '+ tag';

  @override
  String get saveTransaction => 'Enregistrer la transaction';

  @override
  String get required => 'Requis';

  @override
  String get enterValidAmount => 'Entrez un montant valide';

  @override
  String get pleaseSelectWallet => 'Veuillez sélectionner un portefeuille';

  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String get pleaseEnterValidAmount => 'Veuillez entrer un montant valide';

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get noDataAvailable => 'Aucune donnée disponible';

  @override
  String get failedToLoadStatistics => 'Échec du chargement des statistiques';

  @override
  String get overview => 'Aperçu';

  @override
  String get balance => 'Solde';

  @override
  String get budgetAlerts => 'Alertes budgétaires';

  @override
  String get predictedSpendingNextMonth => 'Dépenses prévues (mois prochain)';

  @override
  String get basedOnLast3Months =>
      'Basé sur la moyenne des 3 derniers mois +5%';

  @override
  String get totalPredicted => 'Total prévu';

  @override
  String get cashflowTrend => 'Tendance de trésorerie';

  @override
  String get incomeVsExpenseByMonth => 'Revenus vs dépenses par mois';

  @override
  String get net => 'Net';

  @override
  String get spendingByCategory => 'Dépenses par catégorie';

  @override
  String get noExpenseDataYet => 'Pas encore de données de dépenses';

  @override
  String get monthlyOverview => 'Aperçu mensuel';

  @override
  String get unknown => 'Inconnu';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get noAccount => 'Pas de compte ? Inscrivez-vous';

  @override
  String get hasAccount => 'Déjà un compte ? Connectez-vous';

  @override
  String get settings => 'Paramètres';

  @override
  String get premiumFeatures => 'Premium features';

  @override
  String get language => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String get logout => 'Déconnexion';

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
