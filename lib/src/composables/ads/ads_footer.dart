import 'dart:io';

import 'package:flash_cards/src/data/repositories/reward_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsFooter extends StatefulWidget {
  /// The AdMob ad unit to show.
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-5775467929281127/6518558616'
      : 'ca-app-pub-5775467929281127/6518558616';

  AdsFooter({super.key});

  @override
  State<AdsFooter> createState() => _AdsFooterState();
}

class _AdsFooterState extends State<AdsFooter> {
  BannerAd? _bannerAd;
  bool _noAds = false;

  @override
  Widget build(BuildContext context) {
    _checkRewardStatus();

    if (_noAds) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: SizedBox(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        child: _bannerAd == null
            // Nothing to render yet.
            ? const SizedBox()
            // The actual ad.
            : AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _checkRewardStatus() async {
    bool rewarded = await RewardService().isRewarded();
    setState(() {
      _noAds = rewarded;
    });
  }

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    bannerAd.load();
  }
}
