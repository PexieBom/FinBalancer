// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Painel';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get allWallets => 'Todas as carteiras';

  @override
  String get income => 'Receitas';

  @override
  String get expense => 'Despesas';

  @override
  String get goals => 'Objetivos';

  @override
  String goalsSubtitle(int count) {
    return '$count objetivos';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String get statisticsSubtitle => 'Gráficos e tendências';

  @override
  String get expensesByCategory => 'Despesas por categoria';

  @override
  String get recentTransactions => 'Transações recentes';

  @override
  String get addTransaction => 'Adicionar transação';

  @override
  String get noTransactionsYet => 'Ainda sem transações';

  @override
  String get achievements => 'Conquistas';

  @override
  String get exportData => 'Exportar dados';

  @override
  String get categories => 'Categorias';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cannotConnectApi => 'Sem conexão à API';

  @override
  String get ensureBackendRunning => 'Backend deve estar em localhost:5292';

  @override
  String get home => 'Início';

  @override
  String get add => 'Adicionar';

  @override
  String get loadMore => 'Load more';

  @override
  String get stats => 'Estatísticas';

  @override
  String get wallets => 'Carteiras';

  @override
  String get walletsBudgets => 'Wallets / Budgets';

  @override
  String get newGoal => 'Novo objetivo';

  @override
  String get goalName => 'Nome do objetivo';

  @override
  String get targetAmount => 'Valor alvo';

  @override
  String get deadlineOptional => 'Prazo (opcional)';

  @override
  String deadline(String date) {
    return 'Prazo: $date';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String addToGoal(String name) {
    return 'Adicionar a \"$name\"';
  }

  @override
  String get amount => 'Valor';

  @override
  String get deleteGoal => 'Excluir objetivo?';

  @override
  String removeGoal(String name) {
    return 'Remover \"$name\"?';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get deleteTransactionConfirm => 'Delete transaction?';

  @override
  String get deleteTransactionConfirmMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get noGoalsYet => 'Ainda sem objetivos';

  @override
  String get createSavingsGoal => 'Crie um objetivo de poupança';

  @override
  String get createGoal => 'Criar objetivo';

  @override
  String due(String date) {
    return 'Vencimento: $date';
  }

  @override
  String get addToGoalButton => 'Adicionar ao objetivo';

  @override
  String get addTransactionTitle => 'Adicionar transação';

  @override
  String get editTransaction => 'Editar transação';

  @override
  String get addWalletFirst => 'Adicione primeiro uma carteira';

  @override
  String get needWalletFirst => 'Precisa de uma carteira para transações.';

  @override
  String get addWallet => 'Adicionar carteira';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Despesa';

  @override
  String get incomeLabel => 'Receita';

  @override
  String get category => 'Categoria';

  @override
  String get subcategoryOptional => 'Subcategoria (opcional)';

  @override
  String get none => '— Nenhum —';

  @override
  String get wallet => 'Carteira';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get projectOptional => 'Projeto (opcional)';

  @override
  String get projectHint => 'ex. Férias 2025';

  @override
  String get tagsOptional => 'Tags (opcional)';

  @override
  String get tagHint => '+ tag';

  @override
  String get saveTransaction => 'Salvar transação';

  @override
  String get required => 'Obrigatório';

  @override
  String get enterValidAmount => 'Digite valor válido';

  @override
  String get pleaseSelectWallet => 'Selecione uma carteira';

  @override
  String get pleaseSelectCategory => 'Selecione uma categoria';

  @override
  String get pleaseEnterValidAmount => 'Digite um valor válido';

  @override
  String get statisticsTitle => 'Estatísticas';

  @override
  String get noDataAvailable => 'Nenhum dado disponível';

  @override
  String get failedToLoadStatistics => 'Falha ao carregar estatísticas';

  @override
  String get overview => 'Visão geral';

  @override
  String get balance => 'Saldo';

  @override
  String get budgetAlerts => 'Alertas de orçamento';

  @override
  String get predictedSpendingNextMonth => 'Despesas previstas (próximo mês)';

  @override
  String get basedOnLast3Months => 'Média últimos 3 meses +5%';

  @override
  String get totalPredicted => 'Total previsto';

  @override
  String get cashflowTrend => 'Tendência fluxo de caixa';

  @override
  String get incomeVsExpenseByMonth => 'Receitas vs despesas por mês';

  @override
  String get net => 'Líquido';

  @override
  String get spendingByCategory => 'Despesas por categoria';

  @override
  String get noExpenseDataYet => 'Ainda sem dados de despesas';

  @override
  String get monthlyOverview => 'Visão mensal';

  @override
  String get unknown => 'Desconhecido';

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
  String get login => 'Entrar';

  @override
  String get register => 'Registrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get orContinueWith => 'Ou continue com';

  @override
  String get noAccount => 'Não tem conta? Registre-se';

  @override
  String get hasAccount => 'Já tem conta? Entrar';

  @override
  String get settings => 'Configurações';

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
  String get language => 'Idioma';

  @override
  String get currency => 'Moeda';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get selectCurrency => 'Selecionar moeda';

  @override
  String get logout => 'Sair';

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
  String get filter => 'Filter';

  @override
  String get last1Month => 'Last 1 month';

  @override
  String get thisMonth => 'This month';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get last12Months => 'Last 12 months';

  @override
  String get thisYear => 'This year';

  @override
  String get allTime => 'All time';

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
  String get tracking => 'Tracking';

  @override
  String get trackingAll => 'all';

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
  String get periodStartDate => 'Period start date (custom period)';

  @override
  String get periodEndDate => 'Period end date (custom period)';

  @override
  String get trackCategory => 'Track category';

  @override
  String get allCategories => 'All categories';

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

  @override
  String get showLinkedAccounts => 'Linked accounts';
}
