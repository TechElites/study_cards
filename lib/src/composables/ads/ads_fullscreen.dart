import 'dart:io';

import 'package:study_cards/src/data/repositories/reward_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsFullscreen {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-5775467929281127/6449511517'
      : 'ca-app-pub-5775467929281127/9535458409';

  /// Loads the ad, needs to be called before showing the ad
  void loadAd() {
    if (!_isAdLoaded) {
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
  }

  /// Shows the fullscreen ad
  Future<bool> showAd(Function onDismiss) async {
    final noAds = await RewardService().isRewarded();
    if (!noAds && _isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          onDismiss();
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          onDismiss();
          ad.dispose();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
      return true;
    }
    onDismiss();
    return false;
  }

  Future<bool> showAndReloadAd(Function onDismiss) async {
    final shown = await showAd(onDismiss);
    if (shown) {
      loadAd();
    }
    return shown;
  }
}
