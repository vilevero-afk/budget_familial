import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';
import 'monetization_controller.dart';

class PremiumBannerAd extends StatefulWidget {
  const PremiumBannerAd({
    super.key,
    required this.controller,
    required this.adsService,
  });

  final MonetizationController controller;
  final AdsService adsService;

  @override
  State<PremiumBannerAd> createState() => _PremiumBannerAdState();
}

class _PremiumBannerAdState extends State<PremiumBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryLoadAd();
  }

  @override
  void didUpdateWidget(covariant PremiumBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller.canShowAds != widget.controller.canShowAds) {
      if (widget.controller.canShowAds) {
        _tryLoadAd();
      } else {
        _disposeBanner();
      }
    }
  }

  void _tryLoadAd() {
    if (!widget.adsService.isSupported) return;
    if (!widget.controller.canShowAds) return;
    if (_bannerAd != null) return;

    _bannerAd = widget.adsService.createBannerAd(
      onLoaded: () {
        if (!mounted) return;
        setState(() {
          _isLoaded = true;
        });
      },
      onFailed: (error) {
        debugPrint('Banner load error: ${error.message}');
        if (!mounted) return;
        setState(() {
          _isLoaded = false;
        });
      },
    );
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.adsService.isSupported ||
        !widget.controller.canShowAds ||
        !_isLoaded ||
        _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}