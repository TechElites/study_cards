import 'dart:io';

import 'package:flash_cards/src/data/repositories/reward_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsFullscreen {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-5775467929281127/6449511517'
      : 'ca-app-pub-5775467929281127/9535458409';

  /// Loads the ad, needs to be called before showing the ad
  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Shows the fullscreen ad
  void showAd() {
    RewardService().isRewarded().then((noAds) {
      if (!noAds && _isAdLoaded && _interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
          },
        );
        _interstitialAd!.show();
        _interstitialAd = null;
        _isAdLoaded = false;
      }
    });
  }
}
