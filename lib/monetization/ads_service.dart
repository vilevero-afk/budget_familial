import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_config.dart';

class AdsService {
  bool _initialized = false;

  bool get isSupported {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (!isSupported || _initialized) return;

    await MobileAds.instance.initialize();
    _initialized = true;
  }

  String get bannerAdUnitId {
    if (MonetizationConfig.useTestAds) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return MonetizationConfig.iosBannerAdUnitId;
    }

    return MonetizationConfig.androidBannerAdUnitId;
  }

  BannerAd createBannerAd({
    required VoidCallback onLoaded,
    required void Function(LoadAdError error) onFailed,
  }) {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed(error);
        },
      ),
    );

    ad.load();
    return ad;
  }
}