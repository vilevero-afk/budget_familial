import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'ads_service.dart';
import 'consent_service.dart';
import 'monetization_config.dart';
import 'subscription_service.dart';

class MonetizationController extends ChangeNotifier {
  MonetizationController({
    required SubscriptionService subscriptionService,
    required ConsentService consentService,
    required AdsService adsService,
  })  : _subscriptionService = subscriptionService,
        _consentService = consentService,
        _adsService = adsService;

  final SubscriptionService _subscriptionService;
  final ConsentService _consentService;
  final AdsService _adsService;

  bool _initialized = false;
  bool _isLoading = false;
  bool _isPremiumFromStore = false;
  bool _isDeveloperOverride = false;
  bool _hasInitializationError = false;
  String? _lastErrorMessage;

  Offerings? _offerings;
  CustomerInfo? _customerInfo;
  PremiumPlanType _premiumPlanType = PremiumPlanType.none;

  bool get initialized => _initialized;
  bool get isLoading => _isLoading;
  bool get isDeveloperOverride => _isDeveloperOverride;
  bool get hasInitializationError => _hasInitializationError;
  String? get lastErrorMessage => _lastErrorMessage;
  Offerings? get offerings => _offerings;
  CustomerInfo? get customerInfo => _customerInfo;
  PremiumPlanType get premiumPlanType => _premiumPlanType;

  bool get isPremium => _isDeveloperOverride || _isPremiumFromStore;

  bool get isFamilyPlan => _premiumPlanType == PremiumPlanType.family;
  bool get isAnnualPlan => _premiumPlanType == PremiumPlanType.annual;
  bool get isMonthlyPlan => _premiumPlanType == PremiumPlanType.monthly;

  String get premiumPlanLabel {
    if (_isDeveloperOverride) {
      return 'Premium développeur';
    }
    return _subscriptionService.premiumPlanLabel(_customerInfo);
  }

  bool get canShowAds =>
      !isPremium &&
      _consentService.consentReady &&
      _consentService.canRequestAds;

  bool get privacyOptionsRequired => _consentService.privacyOptionsRequired;

  bool _computeDeveloperOverride() {
    if (!MonetizationConfig.enableDeveloperPremiumOverride) {
      return false;
    }

    final userId = _subscriptionService.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      return false;
    }

    return MonetizationConfig.developerAppUserIds.contains(userId);
  }

  void _syncPremiumStateFromCustomerInfo(CustomerInfo? info) {
    _customerInfo = info;
    _isPremiumFromStore =
        info != null ? _subscriptionService.isPremium(info) : false;
    _premiumPlanType = _subscriptionService.resolvePremiumPlanType(info);
  }

  Future<void> initialize({String? appUserId}) async {
    if (_initialized || _isLoading) return;

    _isLoading = true;
    _hasInitializationError = false;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      await _subscriptionService.initialize(appUserId: appUserId);

      _isDeveloperOverride = _computeDeveloperOverride();

      try {
        await _consentService.initializeConsentFlow();
      } catch (e) {
        debugPrint('Consent init error: $e');
      }

      if (_consentService.canRequestAds) {
        try {
          await _adsService.initialize();
        } catch (e) {
          debugPrint('Ads init error: $e');
        }
      }

      final info = await _subscriptionService.getCustomerInfo();
      _syncPremiumStateFromCustomerInfo(info);

      _offerings = await _subscriptionService.getOfferings();

      _subscriptionService.addCustomerInfoListener((info) {
        _syncPremiumStateFromCustomerInfo(info);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Monetization initialize error: $e');

      _hasInitializationError = true;
      _lastErrorMessage = e.toString();

      _customerInfo = null;
      _offerings = null;
      _premiumPlanType = PremiumPlanType.none;
      _isPremiumFromStore = false;
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCustomerInfo() async {
    try {
      final info = await _subscriptionService.getCustomerInfo();
      _syncPremiumStateFromCustomerInfo(info);
      notifyListeners();
    } catch (e) {
      debugPrint('refreshCustomerInfo error: $e');
    }
  }

  Future<void> purchasePackage(Package package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final info = await _subscriptionService.purchasePackage(package);

      if (info != null) {
        _syncPremiumStateFromCustomerInfo(info);
      }

      _hasInitializationError = false;
      _lastErrorMessage = null;
    } catch (e) {
      debugPrint('purchasePackage error: $e');
      _lastErrorMessage = e.toString();
      // ❗ on NE rethrow PAS → évite crash UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final info = await _subscriptionService.restorePurchases();

      if (info != null) {
        _syncPremiumStateFromCustomerInfo(info);
      }

      _hasInitializationError = false;
      _lastErrorMessage = null;
    } catch (e) {
      debugPrint('restorePurchases error: $e');
      _lastErrorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openPrivacyOptions() async {
    try {
      await _consentService.showPrivacyOptionsForm();
    } catch (e) {
      debugPrint('openPrivacyOptions error: $e');
      _lastErrorMessage = e.toString();
    }
    notifyListeners();
  }

  bool canAccessAnalysis() => isPremium;
  bool canAccessExcelExport() => isPremium;
  bool shouldHideAds() => isPremium;
}
