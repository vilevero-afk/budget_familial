class MonetizationConfig {
  // RevenueCat
  static const String revenueCatAppleApiKey = 'appl_xxxxxxxxxxxxxxxxx';
  static const String revenueCatGoogleApiKey = 'goog_xxxxxxxxxxxxxxxxx';

  // Entitlement RevenueCat
  static const String premiumEntitlementId = 'premium';

  // Offering RevenueCat
  static const String defaultOfferingId = 'default';

  // Hints de détection des produits / plans
  // Ces listes servent uniquement à reconnaître le type d’offre active
  // sans casser l’architecture actuelle basée sur un seul entitlement.
  static const List<String> familyPlanHints = [
    'family',
    'famille',
  ];

  static const List<String> annualPlanHints = [
    'annual',
    'year',
    'yearly',
    'annuel',
    'an',
  ];

  static const List<String> monthlyPlanHints = [
    'month',
    'monthly',
    'mensuel',
    'mois',
  ];

  // AdMob App IDs
  static const String androidAdmobAppId =
      'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';
  static const String iosAdmobAppId =
      'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';

  // Banner Ad Units
  static const String androidBannerAdUnitId =
      'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz';
  static const String iosBannerAdUnitId =
      'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz';

  // iOS ATT
  static const bool requestTrackingAuthorizationOnIOS = true;
  static const String iosTrackingUsageDescription =
      'Nous demandons cette autorisation afin de proposer des publicités plus pertinentes et mesurer leur performance.';

  // Développement
  static const bool enableDeveloperPremiumOverride = false;
  static const String developerAppUserId = 'vincent_dev';
  static const List<String> developerAppUserIds = [
    developerAppUserId,
  ];
  static const String? localAppUserIdOverride = null;

  // Debug pub
  static const bool useTestAds = true;
}