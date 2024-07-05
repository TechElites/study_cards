import 'package:shared_preferences/shared_preferences.dart';

class RewardService {
  static final RewardService _instance = RewardService._internal();

  factory RewardService() {
    return _instance;
  }

  RewardService._internal();

  static const _rewardKey = 'no_ads';

  Future<void> setRewarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rewardKey, value);

    if (value) {
      _startTimer();
    }
  }

  Future<bool> isRewarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rewardKey) ?? false;
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 5), () async {
      await setRewarded(false);
    });
  }
}
