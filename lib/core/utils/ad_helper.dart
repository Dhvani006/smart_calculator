import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Real Ad Unit IDs
  static String get nativeAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/2247696110' 
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3059035439640459/4484232263';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3059035439640459/4484232263';
    }
    return '';
  }

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/6300978111' 
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3059035439640459/2719832259';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3059035439640459/2719832259';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/1033173712' 
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3059035439640459/4568100544';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3059035439640459/4568100544';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid 
          ? 'ca-app-pub-3940256099942544/5224354917' 
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  static InterstitialAd? _interstitialAd;
  static int _calculationCount = 0;
  static const int interstitialThreshold = 10; // 10-15 calculations

  static void incrementCalculationCount() {
    _calculationCount++;
  }

  static bool shouldShowInterstitial() {
    return _calculationCount >= interstitialThreshold;
  }

  static void resetCalculationCount() {
    _calculationCount = 0;
  }

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        resetCalculationCount();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
    );
    _interstitialAd!.show();
  }

  static RewardedAd? _rewardedAd;

  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({required Function(RewardItem) onRewardEarned}) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onRewardEarned(reward);
    });
  }
}
