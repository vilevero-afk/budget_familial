import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onOpenPremium,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;
  final VoidCallback onOpenPremium;
  final Future<void> Function(Locale? locale) onLocaleChanged;
  final Locale? currentLocale;

  String _languageCode(BuildContext context) {
    return currentLocale?.languageCode.toLowerCase() ??
        Localizations.localeOf(context).languageCode.toLowerCase();
  }

  Future<void> _changeLanguage(String? value) async {
    if (value == null) return;

    switch (value) {
      case 'fr':
        await onLocaleChanged(const Locale('fr'));
        break;
      case 'en':
        await onLocaleChanged(const Locale('en'));
        break;
      case 'nl':
        await onLocaleChanged(const Locale('nl'));
        break;
    }
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E0EE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _languageCode(context),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
          ),
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          items: const [
            DropdownMenuItem(
              value: 'fr',
              child: Text('FR'),
            ),
            DropdownMenuItem(
              value: 'en',
              child: Text('EN'),
            ),
            DropdownMenuItem(
              value: 'nl',
              child: Text('NL'),
            ),
          ],
          onChanged: (value) => _changeLanguage(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildLanguageDropdown(context),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x334F46E5),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeHeroDescription,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.welcomeTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.welcomeSubtitle,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _WelcomeFeatureTile(
                            icon: Icons.pie_chart_outline_rounded,
                            title: l10n.welcomeFeatureBudgetTitle,
                            description: l10n.welcomeFeatureBudgetDescription,
                          ),
                          const SizedBox(height: 12),
                          _WelcomeFeatureTile(
                            icon: Icons.insights_rounded,
                            title: l10n.welcomeFeatureAnalysisTitle,
                            description: l10n.welcomeFeatureAnalysisDescription,
                          ),
                          const SizedBox(height: 12),
                          _WelcomeFeatureTile(
                            icon: Icons.groups_rounded,
                            title: l10n.welcomeFeatureFamilyTitle,
                            description: l10n.welcomeFeatureFamilyDescription,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Color(0xFFD97706),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.welcomePremiumTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.welcomePremiumDescription,
                                  style: const TextStyle(
                                    color: Color(0xFF475467),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: OutlinedButton.icon(
                                    onPressed: onOpenPremium,
                                    icon: const Icon(
                                      Icons.workspace_premium_rounded,
                                    ),
                                    label: Text(l10n.welcomePremiumButton),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onCreateAccount,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(l10n.welcomeCreateAccount),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: onSignIn,
                            icon: const Icon(Icons.login_rounded),
                            label: Text(l10n.welcomeSignIn),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeFeatureTile extends StatelessWidget {
  const _WelcomeFeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}