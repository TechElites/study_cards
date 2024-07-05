import 'package:shared_preferences/shared_preferences.dart';

/// How long does the reward last
const _rewardTime = 5;

/// A service to manage the rewarded ad state
class RewardService {
  static final RewardService _instance = RewardService._internal();

  factory RewardService() {
    return _instance;
  }

  RewardService._internal();

  static const _rewardKey = 'no_ads';
  static const _timerStartKey = 'timer_start';

  /// Sets the rewarded ad state to [value]
  /// If [value] is true, it will start a timer to expire the reward in 5 minutes
  Future<void> setRewarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rewardKey, value);

    if (value) {
      await _startTimer();
    } else {
      await prefs.remove(_timerStartKey);
    }
  }

  /// Returns true if the user has been rewarded
  Future<bool> isRewarded() async {
    final prefs = await SharedPreferences.getInstance();
    final isRewarded = prefs.getBool(_rewardKey) ?? false;
    if (isRewarded) {
      await _checkAndExpireReward();
    }
    return isRewarded;
  }

  /// Starts a timer to expire the reward in 5 minutes
  Future<void> _startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final startTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_timerStartKey, startTime);
  }

  /// Checks if the reward has expired and sets the rewarded state to false
  Future<void> _checkAndExpireReward() async {
    final prefs = await SharedPreferences.getInstance();
    final startTime = prefs.getInt(_timerStartKey);
    if (startTime != null) {
      final elapsedTime = DateTime.now().millisecondsSinceEpoch - startTime;
      if (elapsedTime >= const Duration(minutes: _rewardTime).inMilliseconds) {
        await setRewarded(false);
      }
    }
  }
}
