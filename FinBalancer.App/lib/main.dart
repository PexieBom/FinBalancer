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
import 'screens/add_transaction_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_features_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/achievements_list_screen.dart';

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
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'FinBalancer',
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
        routes: {
          '/': (context) => const _AppRouter(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/wallets': (context) => const WalletsScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/register': (context) => const RegisterScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/goals': (context) => const GoalsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/premium-features': (context) => const PremiumFeaturesScreen(),
          '/projects': (context) => const ProjectsScreen(),
          '/achievements-list': (context) => const AchievementsListScreen(),
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
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        if (!app.splashComplete) {
          return SplashScreen(
            onFinish: () => context.read<AppProvider>().completeSplash(),
          );
        }
        if (app.isLoggedIn) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
