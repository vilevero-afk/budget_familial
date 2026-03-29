import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_config.dart';

class ConsentService {
  bool _consentReady = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  bool get consentReady => _consentReady;
  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  bool get _isSupported {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initializeConsentFlow() async {
    if (!_isSupported) {
      _consentReady = true;
      _canRequestAds = false;
      _privacyOptionsRequired = false;
      return;
    }

    final completer = Completer<void>();

    try {
      final params = ConsentRequestParameters();

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
            () async {
          try {
            await _loadAndShowConsentFormIfRequired();
          } catch (e) {
            debugPrint('Consent flow error: $e');
          } finally {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
            (FormError error) {
          debugPrint(
            'ConsentInfoUpdate error: ${error.errorCode} - ${error.message}',
          );

          _consentReady = true;
          _canRequestAds = false;
          _privacyOptionsRequired = false;

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (e) {
      debugPrint('Consent init fatal error: $e');

      _consentReady = true;
      _canRequestAds = false;
      _privacyOptionsRequired = false;

      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() async {
    final completer = Completer<void>();

    try {
      ConsentForm.loadAndShowConsentFormIfRequired(
            (FormError? error) async {
          if (error != null) {
            debugPrint(
              'ConsentForm error: ${error.errorCode} - ${error.message}',
            );
          }

          try {
            _privacyOptionsRequired =
                await ConsentInformation.instance
                    .getPrivacyOptionsRequirementStatus() ==
                    PrivacyOptionsRequirementStatus.required;

            _canRequestAds =
            await ConsentInformation.instance.canRequestAds();

            if (_shouldRequestATT) {
              await _requestTrackingTransparencyIfNeeded();
            }
          } catch (e) {
            debugPrint('Consent processing error: $e');
          }

          _consentReady = true;

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (e) {
      debugPrint('ConsentForm fatal error: $e');

      _consentReady = true;
      _canRequestAds = false;
      _privacyOptionsRequired = false;

      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
  }

  bool get _shouldRequestATT {
    return defaultTargetPlatform == TargetPlatform.iOS &&
        MonetizationConfig.requestTrackingAuthorizationOnIOS;
  }

  Future<void> _requestTrackingTransparencyIfNeeded() async {
    try {
      final status =
      await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('ATT request error: $e');
    }
  }

  Future<void> showPrivacyOptionsForm() async {
    if (!_isSupported) return;

    final completer = Completer<void>();

    try {
      ConsentForm.showPrivacyOptionsForm(
            (FormError? error) async {
          if (error != null) {
            debugPrint(
              'PrivacyOptions error: ${error.errorCode} - ${error.message}',
            );
          }

          try {
            _privacyOptionsRequired =
                await ConsentInformation.instance
                    .getPrivacyOptionsRequirementStatus() ==
                    PrivacyOptionsRequirementStatus.required;

            _canRequestAds =
            await ConsentInformation.instance.canRequestAds();
          } catch (e) {
            debugPrint('PrivacyOptions processing error: $e');
          }

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (e) {
      debugPrint('PrivacyOptions fatal error: $e');

      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await completer.future;
  }
}