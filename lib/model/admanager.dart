import 'package:flutter/foundation.dart';

class AdManager {
  static String get gameId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '5752412';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return '5752413';
    }
    return '';
  }

  static String get bannerAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Banner_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Banner_iOS';
    }
    return '';
  }

  static String get interstitialVideoAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Interstitial_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Interstitial_iOS';
    }
    return '';
  }

  static String get rewardedVideoAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Rewarded_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Rewarded_iOS';
    }
    return '';
  }
}