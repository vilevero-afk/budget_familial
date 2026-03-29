import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'monetization_config.dart';

enum PremiumPlanType {
  none,
  monthly,
  annual,
  family,
  unknown,
}

class SubscriptionService {
  bool _initialized = false;
  String? _appUserId;

  String? get currentUserId => _appUserId;

  Future<void> initialize({String? appUserId}) async {
    if (_initialized) return;

    final resolvedAppUserId =
        appUserId ?? MonetizationConfig.localAppUserIdOverride;

    _appUserId = resolvedAppUserId;

    final apiKey = _resolveApiKey();

    try {
      await Purchases.setLogLevel(LogLevel.info);

      final configuration = PurchasesConfiguration(apiKey);

      if (resolvedAppUserId != null &&
          resolvedAppUserId.trim().isNotEmpty) {
        configuration.appUserID = resolvedAppUserId;
      }

      await Purchases.configure(configuration);

      try {
        final actualUserId = await Purchases.appUserID;
        _appUserId = actualUserId;
      } catch (e) {
        debugPrint('RevenueCat appUserID read error: $e');
      }

      _initialized = true;
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');

      // ⚠️ on marque quand même comme initialisé pour éviter boucle infinie
      _initialized = true;
    }
  }

  String _resolveApiKey() {
    if (kIsWeb) return MonetizationConfig.revenueCatGoogleApiKey;

    if (Platform.isIOS || Platform.isMacOS) {
      return MonetizationConfig.revenueCatAppleApiKey;
    }

    return MonetizationConfig.revenueCatGoogleApiKey;
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('getCustomerInfo error: $e');
      return null;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('getOfferings error: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      return await Purchases.purchasePackage(package);
    } catch (e) {
      debugPrint('purchasePackage error: $e');
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('restorePurchases error: $e');
      return null;
    }
  }

  bool isPremium(CustomerInfo? info) {
    if (info == null) return false;

    return info.entitlements.active.containsKey(
      MonetizationConfig.premiumEntitlementId,
    );
  }

  PremiumPlanType resolvePremiumPlanType(CustomerInfo? info) {
    if (info == null) return PremiumPlanType.none;
    if (!isPremium(info)) return PremiumPlanType.none;

    final activeSubscriptions = info.activeSubscriptions
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (activeSubscriptions.isEmpty) {
      return PremiumPlanType.unknown;
    }

    if (_containsAnyHint(
      activeSubscriptions,
      MonetizationConfig.familyPlanHints,
    )) {
      return PremiumPlanType.family;
    }

    if (_containsAnyHint(
      activeSubscriptions,
      MonetizationConfig.annualPlanHints,
    )) {
      return PremiumPlanType.annual;
    }

    if (_containsAnyHint(
      activeSubscriptions,
      MonetizationConfig.monthlyPlanHints,
    )) {
      return PremiumPlanType.monthly;
    }

    return PremiumPlanType.unknown;
  }

  String premiumPlanLabel(CustomerInfo? info) {
    switch (resolvePremiumPlanType(info)) {
      case PremiumPlanType.none:
        return 'Aucun abonnement premium';
      case PremiumPlanType.monthly:
        return 'Premium mensuel';
      case PremiumPlanType.annual:
        return 'Premium annuel';
      case PremiumPlanType.family:
        return 'Premium famille';
      case PremiumPlanType.unknown:
        return 'Premium actif';
    }
  }

  bool _containsAnyHint(List<String> values, List<String> hints) {
    for (final value in values) {
      for (final hint in hints) {
        if (value.contains(hint.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    try {
      Purchases.addCustomerInfoUpdateListener(listener);
    } catch (e) {
      debugPrint('Listener error: $e');
    }
  }
}