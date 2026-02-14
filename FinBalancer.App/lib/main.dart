import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/data_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/categories_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'FinBalancer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const _AppRouter(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/wallets': (context) => const WalletsScreen(),
          '/categories': (context) => const CategoriesScreen(),
        },
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
