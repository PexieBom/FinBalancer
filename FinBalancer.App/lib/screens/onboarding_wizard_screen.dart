import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Kratki wizard za prvi put kad korisnik prijavi ili za ručno otvaranje iz menija.
class OnboardingWizardScreen extends StatefulWidget {
  /// Ako je true, ne postavlja flag kad se zatvori (otvaranje iz menija).
  final bool fromMenu;

  const OnboardingWizardScreen({
    super.key,
    this.fromMenu = false,
  });

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 4;

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _close(completed: true);
    }
  }

  void _skipOrCancel() {
    _close(completed: false);
  }

  Future<void> _close({required bool completed}) async {
    if (!widget.fromMenu) {
      await OnboardingStorage.setCompleted();
    }
    if (mounted) {
      Navigator.of(context).pop(completed);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header s Skip
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skipOrCancel,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Flexible(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(context, l10n, isDark),
                  _buildStepPage(
                    context,
                    l10n.onboardingStep1Title,
                    l10n.onboardingStep1Body,
                    Icons.dashboard_rounded,
                    isDark,
                  ),
                  _buildStepPage(
                    context,
                    l10n.onboardingStep2Title,
                    l10n.onboardingStep2Body,
                    Icons.add_circle_outline,
                    isDark,
                  ),
                  _buildStepPage(
                    context,
                    l10n.onboardingStep3Title,
                    l10n.onboardingStep3Body,
                    Icons.account_balance_wallet_rounded,
                    isDark,
                  ),
                ],
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppTheme.accent(context)
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _currentPage--);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _currentPage == _totalPages - 1 ? l10n.onboardingDone : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: AppTheme.accent(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPage(
    BuildContext context,
    String title,
    String body,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppTheme.accent(context)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Sprema i dohvaća flag radi prve prijave.
class OnboardingStorage {
  static const String _key = 'onboarding_completed';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
