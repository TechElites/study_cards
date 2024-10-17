import 'dart:io';

import 'package:flash_cards/src/data/repositories/reward_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsSandman {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-5775467929281127/7879063124'
      : 'ca-app-pub-5775467929281127/8808382862';

  /// Loads the ad, needs to be called before showing the ad
  void loadAd() {
    if (!_isAdLoaded) {
      RewardedAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              _rewardedAd = ad;
              _isAdLoaded = true;
            },
            onAdFailedToLoad: (LoadAdError error) {
              _isAdLoaded = false;
            },
          ));
    }
  }

  /// Shows the fullscreen ad, calls the reward function when the user has watched the ad
  Future<bool> showAd(Function reward) async {
    final noAds = await RewardService().isRewarded();
    if (!noAds && _isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
        },
      );
      _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        reward();
      });
      _rewardedAd = null;
      _isAdLoaded = false;
      return true;
    }
    return false;
  }

  Future<bool> showAndReloadAd(Function reward) async {
    final shown = await showAd(reward);
    if (shown) {
      loadAd();
    }
    return shown;
  }
}
