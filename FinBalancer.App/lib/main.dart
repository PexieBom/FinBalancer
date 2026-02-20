import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/data_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'models/transaction.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_features_screen.dart';
import 'screens/achievements_list_screen.dart';
import 'screens/decision_engine_screen.dart';
import 'providers/subscription_provider.dart';
import 'providers/dashboard_settings_provider.dart';
import 'providers/app_lock_provider.dart';
import 'providers/linked_account_provider.dart';
import 'providers/notifications_provider.dart';
import 'screens/app_lock_screen.dart';
import 'screens/linked_accounts_screen.dart';
import 'screens/period_filter_screen.dart';

void main() {
  runApp(const FinBalancerApp());
}

class FinBalancerApp extends StatelessWidget {
  const FinBalancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DashboardSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppLockProvider()),
        ChangeNotifierProvider(create: (_) => LinkedAccountProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: '',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: localeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/add-transaction') {
            final t = settings.arguments;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => AddTransactionScreen(
                editingTransaction: t is Transaction ? t : null,
              ),
            );
          }
          return null;
        },
        routes: {
          '/': (context) => const _AppRouter(),
          '/dashboard': (context) => const DashboardScreen(),
          '/wallets': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final initialTab = args is int ? args.clamp(0, 1) : 0;
            return WalletsScreen(initialTabIndex: initialTab);
          },
          '/categories': (context) => const CategoriesScreen(),
          '/register': (context) => const RegisterScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/goals': (context) => const GoalsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/premium-features': (context) => const PremiumFeaturesScreen(),
          '/achievements-list': (context) => const AchievementsListScreen(),
          '/decision-engine': (context) => const DecisionEngineScreen(),
          '/app-lock': (context) => const AppLockScreen(),
          '/linked-accounts': (context) => const LinkedAccountsScreen(),
          '/period-filter': (context) => const PeriodFilterScreen(),
        },
        ),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, AppLockProvider>(
      builder: (context, app, lock, _) {
        if (!app.splashComplete) {
          return SplashScreen(
            onFinish: () => context.read<AppProvider>().completeSplash(),
          );
        }
        if (!app.isLoggedIn) {
          return const LoginScreen();
        }
        if (lock.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (lock.isMobile && lock.isEnabled && lock.isLocked) {
          return const AppLockScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
