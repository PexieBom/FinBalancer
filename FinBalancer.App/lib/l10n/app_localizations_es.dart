// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FinBalancer';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get totalBalance => 'Saldo total';

  @override
  String get allWallets => 'Todas las carteras';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get goals => 'Objetivos';

  @override
  String goalsSubtitle(int count) {
    return '$count objetivos · Seguimiento de ahorros y progreso';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String get statisticsSubtitle => 'Gráficos, gastos por categoría, tendencias';

  @override
  String get expensesByCategory => 'Gastos por categoría';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get achievements => 'Logros';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get categories => 'Categorías';

  @override
  String get retry => 'Reintentar';

  @override
  String get cannotConnectApi => 'No se puede conectar a la API';

  @override
  String get ensureBackendRunning =>
      'Asegúrese de que el backend esté en localhost:5292';

  @override
  String get home => 'Inicio';

  @override
  String get add => 'Añadir';

  @override
  String get loadMore => 'Load more';

  @override
  String get stats => 'Estadísticas';

  @override
  String get wallets => 'Carteras';

  @override
  String get walletsBudgets => 'Wallets / Budgets';

  @override
  String get newGoal => 'Nuevo objetivo';

  @override
  String get goalName => 'Nombre del objetivo';

  @override
  String get targetAmount => 'Cantidad objetivo';

  @override
  String get deadlineOptional => 'Fecha límite (opcional)';

  @override
  String deadline(String date) {
    return 'Fecha límite: $date';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String addToGoal(String name) {
    return 'Añadir a \"$name\"';
  }

  @override
  String get amount => 'Cantidad';

  @override
  String get deleteGoal => '¿Eliminar objetivo?';

  @override
  String removeGoal(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteTransactionConfirm => 'Delete transaction?';

  @override
  String get deleteTransactionConfirmMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get noGoalsYet => 'Aún no hay objetivos';

  @override
  String get createSavingsGoal =>
      'Cree un objetivo de ahorro y siga su progreso';

  @override
  String get createGoal => 'Crear objetivo';

  @override
  String due(String date) {
    return 'Vencimiento: $date';
  }

  @override
  String get addToGoalButton => 'Añadir al objetivo';

  @override
  String get addTransactionTitle => 'Añadir transacción';

  @override
  String get editTransaction => 'Editar transacción';

  @override
  String get addWalletFirst => 'Primero añada una cartera';

  @override
  String get needWalletFirst =>
      'Necesita al menos una cartera para transacciones.';

  @override
  String get addWallet => 'Añadir cartera';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get newWallet => 'New Wallet';

  @override
  String get expenseLabel => 'Gasto';

  @override
  String get incomeLabel => 'Ingreso';

  @override
  String get category => 'Categoría';

  @override
  String get subcategoryOptional => 'Subcategoría (opcional)';

  @override
  String get none => '— Ninguno —';

  @override
  String get wallet => 'Cartera';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get projectOptional => 'Proyecto (opcional)';

  @override
  String get projectHint => 'ej. Vacaciones 2025';

  @override
  String get tagsOptional => 'Etiquetas (opcional)';

  @override
  String get tagHint => '+ etiqueta';

  @override
  String get saveTransaction => 'Guardar transacción';

  @override
  String get required => 'Obligatorio';

  @override
  String get enterValidAmount => 'Introduzca cantidad válida';

  @override
  String get pleaseSelectWallet => 'Seleccione una cartera';

  @override
  String get pleaseSelectCategory => 'Seleccione una categoría';

  @override
  String get pleaseEnterValidAmount => 'Introduzca una cantidad válida';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get failedToLoadStatistics => 'Error al cargar estadísticas';

  @override
  String get overview => 'Resumen';

  @override
  String get balance => 'Saldo';

  @override
  String get budgetAlerts => 'Alertas de presupuesto';

  @override
  String get predictedSpendingNextMonth => 'Gastos previstos (próximo mes)';

  @override
  String get basedOnLast3Months =>
      'Basado en el promedio de los últimos 3 meses +5%';

  @override
  String get totalPredicted => 'Total previsto';

  @override
  String get cashflowTrend => 'Tendencia de flujo de caja';

  @override
  String get incomeVsExpenseByMonth => 'Ingresos vs gastos por mes';

  @override
  String get net => 'Neto';

  @override
  String get spendingByCategory => 'Gastos por categoría';

  @override
  String get noExpenseDataYet => 'Aún no hay datos de gastos';

  @override
  String get monthlyOverview => 'Resumen mensual';

  @override
  String get unknown => 'Desconocido';

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
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get forgotPassword => '¿Olvidó la contraseña?';

  @override
  String get orContinueWith => 'O continuar con';

  @override
  String get noAccount => '¿No tiene cuenta? Regístrese';

  @override
  String get hasAccount => '¿Ya tiene cuenta? Inicie sesión';

  @override
  String get settings => 'Configuración';

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
  String get currency => 'Moneda';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectCurrency => 'Seleccionar moneda';

  @override
  String get logout => 'Cerrar sesión';

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

  @override
  String get howToUseApp => 'How to use';

  @override
  String get onboardingWelcomeTitle => 'Welcome to FinBalancer!';

  @override
  String get onboardingWelcomeSubtitle => 'Quick guide to get started';

  @override
  String get onboardingStep1Title => 'Dashboard';

  @override
  String get onboardingStep1Body =>
      'See your total balance, income and expenses at a glance. Use the period filter to change the time range.';

  @override
  String get onboardingStep2Title => 'Add transactions';

  @override
  String get onboardingStep2Body =>
      'Tap the + button in the bottom bar to add income or expenses. First add a wallet if you don\'t have one.';

  @override
  String get onboardingStep3Title => 'Wallets, Goals & Stats';

  @override
  String get onboardingStep3Body =>
      'Manage wallets, set budgets, track savings goals and view statistics from the bottom navigation.';

  @override
  String get onboardingDone => 'Get started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';
}
