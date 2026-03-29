import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_localizations.dart';
import 'monetization_controller.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    required this.controller,
  });

  final MonetizationController controller;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String? _selectedPackageIdentifier;
  bool _isPurchasing = false;
  bool _isRestoring = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _selectDefaultPackage();
  }

  @override
  void didUpdateWidget(covariant PaywallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectDefaultPackage();
  }

  void _selectDefaultPackage() {
    final packages = _availablePackages;
    if (packages.isEmpty) {
      _selectedPackageIdentifier = null;
      return;
    }

    final stillExists = packages.any(
          (p) => p.identifier == _selectedPackageIdentifier,
    );
    if (stillExists) return;

    final annual = _findAnnualPackage(packages);
    final monthly = _findMonthlyPackage(packages);
    final family = _findFamilyPackage(packages);

    final defaultPackage = annual ?? monthly ?? family ?? packages.first;
    _selectedPackageIdentifier = defaultPackage.identifier;
  }

  List<Package> get _availablePackages {
    final currentOffering = widget.controller.offerings?.current;
    final packages = currentOffering?.availablePackages ?? const <Package>[];
    return _sortedPackages(packages);
  }

  Package? get _selectedPackage {
    if (_selectedPackageIdentifier == null) return null;

    for (final package in _availablePackages) {
      if (package.identifier == _selectedPackageIdentifier) {
        return package;
      }
    }
    return null;
  }

  List<Package> _sortedPackages(List<Package> packages) {
    final sorted = [...packages];
    sorted.sort((a, b) => _packagePriority(a).compareTo(_packagePriority(b)));
    return sorted;
  }

  int _packagePriority(Package package) {
    final id = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    if (_looksAnnual(id, productId)) return 0;
    if (_looksMonthly(id, productId)) return 1;
    if (_looksFamily(id, productId)) return 2;
    return 10;
  }

  Package? _findAnnualPackage(List<Package> packages) {
    for (final package in packages) {
      final id = package.identifier.toLowerCase();
      final productId = package.storeProduct.identifier.toLowerCase();
      if (_looksAnnual(id, productId)) return package;
    }
    return null;
  }

  Package? _findMonthlyPackage(List<Package> packages) {
    for (final package in packages) {
      final id = package.identifier.toLowerCase();
      final productId = package.storeProduct.identifier.toLowerCase();
      if (_looksMonthly(id, productId)) return package;
    }
    return null;
  }

  Package? _findFamilyPackage(List<Package> packages) {
    for (final package in packages) {
      final id = package.identifier.toLowerCase();
      final productId = package.storeProduct.identifier.toLowerCase();
      if (_looksFamily(id, productId)) return package;
    }
    return null;
  }

  bool _looksAnnual(String id, String productId) {
    return id.contains('annual') ||
        id.contains('year') ||
        id.contains('yearly') ||
        id.contains('annuel') ||
        productId.contains('annual') ||
        productId.contains('year') ||
        productId.contains('yearly') ||
        productId.contains('annuel');
  }

  bool _looksMonthly(String id, String productId) {
    return id.contains('month') ||
        id.contains('monthly') ||
        id.contains('mensuel') ||
        id.contains('mois') ||
        productId.contains('month') ||
        productId.contains('monthly') ||
        productId.contains('mensuel') ||
        productId.contains('mois');
  }

  bool _looksFamily(String id, String productId) {
    return id.contains('family') ||
        id.contains('famille') ||
        productId.contains('family') ||
        productId.contains('famille');
  }

  String _packageTitle(Package package) {
    final id = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    if (_looksAnnual(id, productId)) return l10n.paywallAnnualTitle;
    if (_looksMonthly(id, productId)) return l10n.paywallMonthlyTitle;
    if (_looksFamily(id, productId)) return l10n.paywallFamilyTitle;
    return package.storeProduct.title;
  }

  String _packageSubtitle(Package package) {
    final id = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    if (_looksAnnual(id, productId)) {
      return l10n.paywallAnnualSubtitle;
    }
    if (_looksMonthly(id, productId)) {
      return l10n.paywallMonthlySubtitle;
    }
    if (_looksFamily(id, productId)) {
      return l10n.paywallFamilySubtitle;
    }

    final description = package.storeProduct.description.trim();
    if (description.isNotEmpty) return description;

    return l10n.paywallDefaultPackageSubtitle;
  }

  String? _packageBadge(Package package) {
    final id = package.identifier.toLowerCase();
    final productId = package.storeProduct.identifier.toLowerCase();

    if (_looksAnnual(id, productId)) return l10n.paywallBadgeBestOffer;
    if (_looksFamily(id, productId)) return l10n.paywallBadgeFamily;
    if (_looksMonthly(id, productId)) return l10n.paywallBadgeFlexible;
    return null;
  }

  String _ctaLabel(Package? package) {
    if (package == null) return l10n.paywallChooseOfferButton;
    return l10n.paywallContinueWithPrice(package.storeProduct.priceString);
  }

  Future<void> _buySelectedPackage() async {
    final selectedPackage = _selectedPackage;
    if (selectedPackage == null || _isPurchasing) return;

    setState(() {
      _isPurchasing = true;
    });

    await widget.controller.purchasePackage(selectedPackage);

    if (!mounted) return;

    final controller = widget.controller;

    if (controller.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paywallPurchaseSuccess),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = controller.lastErrorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error != null
                ? l10n.paywallPurchaseError(error)
                : l10n.paywallPurchaseCanceled,
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _isPurchasing = false;
    });
  }

  Future<void> _restorePurchases() async {
    if (_isRestoring) return;

    setState(() {
      _isRestoring = true;
    });

    await widget.controller.restorePurchases();

    if (!mounted) return;

    final controller = widget.controller;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.isPremium
              ? l10n.paywallRestoreSuccess
              : l10n.paywallRestoreNoPurchaseFound,
        ),
        backgroundColor: controller.isPremium
            ? const Color(0xFF16A34A)
            : const Color(0xFF475467),
      ),
    );

    if (controller.isPremium) {
      Navigator.of(context).pop(true);
    }

    if (!mounted) return;

    setState(() {
      _isRestoring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final packages = _availablePackages;
        final selectedPackage = _selectedPackage;
        final isPremium = controller.isPremium;
        final isBusy = controller.isLoading || _isPurchasing || _isRestoring;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8FAFF),
                  Color(0xFFF4F1FF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isRestoring ? null : _restorePurchases,
                          child: Text(
                            _isRestoring
                                ? l10n.paywallRestoring
                                : l10n.paywallRestore,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        _HeroPremiumCard(isPremium: isPremium),
                        const SizedBox(height: 18),
                        Text(
                          l10n.paywallUnlockTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.paywallUnlockSubtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FeatureList(),
                        const SizedBox(height: 22),
                        if (isPremium)
                          const _PremiumActiveCard()
                        else if (packages.isEmpty)
                          const _OfferUnavailableCard()
                        else ...[
                            Text(
                              l10n.paywallChooseOfferTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...packages.map(
                                  (package) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PackageTile(
                                  package: package,
                                  title: _packageTitle(package),
                                  subtitle: _packageSubtitle(package),
                                  badge: _packageBadge(package),
                                  selected: package.identifier ==
                                      _selectedPackageIdentifier,
                                  onTap: () {
                                    setState(() {
                                      _selectedPackageIdentifier =
                                          package.identifier;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isBusy || selectedPackage == null
                                    ? null
                                    : _buySelectedPackage,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  isBusy
                                      ? l10n.paywallProcessing
                                      : _ctaLabel(selectedPackage),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                l10n.paywallStoreNotice,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.paywallImportantInfoTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.paywallImportantInfoBody,
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (controller.hasInitializationError &&
                            controller.lastErrorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(18),
                              border:
                              Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            child: Text(
                              l10n.paywallPartialUnavailable(
                                controller.lastErrorMessage!,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF9A3412),
                                height: 1.35,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroPremiumCard extends StatelessWidget {
  const _HeroPremiumCard({
    required this.isPremium,
  });

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(22),
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
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium
                      ? l10n.paywallHeroPremiumActiveTitle
                      : l10n.paywallHeroUpgradeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPremium
                      ? l10n.paywallHeroPremiumActiveSubtitle
                      : l10n.paywallHeroUpgradeSubtitle,
                  style: const TextStyle(
                    color: Colors.white70,
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

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _FeatureRow(
          icon: Icons.table_view_rounded,
          title: l10n.paywallFeatureExcelTitle,
          subtitle: l10n.paywallFeatureExcelSubtitle,
        ),
        const SizedBox(height: 10),
        _FeatureRow(
          icon: Icons.tips_and_updates_rounded,
          title: l10n.paywallFeatureAdviceTitle,
          subtitle: l10n.paywallFeatureAdviceSubtitle,
        ),
        const SizedBox(height: 10),
        _FeatureRow(
          icon: Icons.groups_rounded,
          title: l10n.paywallFeatureFamilyTitle,
          subtitle: l10n.paywallFeatureFamilySubtitle,
        ),
        const SizedBox(height: 10),
        _FeatureRow(
          icon: Icons.block_rounded,
          title: l10n.paywallFeatureNoAdsTitle,
          subtitle: l10n.paywallFeatureNoAdsSubtitle,
        ),
        const SizedBox(height: 10),
        _FeatureRow(
          icon: Icons.auto_awesome_rounded,
          title: l10n.paywallFeatureFutureTitle,
          subtitle: l10n.paywallFeatureFutureSubtitle,
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4338CA)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    height: 1.35,
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

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final Package package;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
    selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB);

    final backgroundColor =
    selected ? const Color(0xFFF5F3FF) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor,
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: selected
              ? const [
            BoxShadow(
              color: Color(0x144F46E5),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF98A2B3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Color(0xFF4338CA),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    package.storeProduct.priceString,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
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
}

class _PremiumActiveCard extends StatelessWidget {
  const _PremiumActiveCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA6F4C5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.paywallPremiumAlreadyActive,
              style: const TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferUnavailableCard extends StatelessWidget {
  const _OfferUnavailableCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paywallNoOfferTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.paywallNoOfferMessage,
            style: const TextStyle(
              color: Color(0xFFB45309),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}