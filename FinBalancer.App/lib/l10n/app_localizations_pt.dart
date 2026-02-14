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
  String get stats => 'Estatísticas';

  @override
  String get wallets => 'Carteiras';

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
  String get addWalletFirst => 'Adicione primeiro uma carteira';

  @override
  String get needWalletFirst => 'Precisa de uma carteira para transações.';

  @override
  String get addWallet => 'Adicionar carteira';

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
}
