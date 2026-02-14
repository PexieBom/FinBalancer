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
  String get stats => 'Estadísticas';

  @override
  String get wallets => 'Carteras';

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
  String get addWalletFirst => 'Primero añada una cartera';

  @override
  String get needWalletFirst =>
      'Necesita al menos una cartera para transacciones.';

  @override
  String get addWallet => 'Añadir cartera';

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
}
