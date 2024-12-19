import 'dart:io';

class Adhelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9540719965446244/7982173661"; // Test banner ad unit ID for Android
    } else if (Platform.isIOS) {
      return "ca-app-pub-9540719965446244/7790338645"; // Test banner ad unit ID for iOS
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9540719965446244/1608073674"; // Test interstitial ad unit ID for Android
    } else if (Platform.isIOS) {
      return "ca-app-pub-9540719965446244/4815824973"; // Test interstitial ad unit ID for iOS
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9540719965446244/2302471573"; // Test rewarded ad unit ID for Android
    } else if (Platform.isIOS) {
      return "ca-app-pub-9540719965446244/1915458767"; // Test rewarded ad unit ID for iOS
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/2247696110"; // Test native ad unit ID for Android
    } else if (Platform.isIOS) {
      return "ca-app-pub-9540719965446244/1234567892"; // Test native ad unit ID for iOS
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}