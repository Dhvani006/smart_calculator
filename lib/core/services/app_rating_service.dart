import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRatingService {
  static final InAppReview _inAppReview = InAppReview.instance;
  
  static const String _keyLaunchCount = 'launch_count';
  static const String _keyFirstLaunchDate = 'first_launch_date';
  static const String _keyAlreadyRated = 'already_rated';

  /// Increments the app launch count and sets first launch date if not set.
  static Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if already rated
    if (prefs.getBool(_keyAlreadyRated) ?? false) return;

    // Increment launch count
    int count = prefs.getInt(_keyLaunchCount) ?? 0;
    await prefs.setInt(_keyLaunchCount, count + 1);

    // Set first launch date
    if (prefs.getString(_keyFirstLaunchDate) == null) {
      await prefs.setString(_keyFirstLaunchDate, DateTime.now().toIso8601String());
    }
  }

  /// Checks if the conditions for showing the rating prompt are met.
  static Future<bool> isRatingRequired() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.getBool(_keyAlreadyRated) ?? false) return false;

    int count = prefs.getInt(_keyLaunchCount) ?? 0;
    String? firstLaunchStr = prefs.getString(_keyFirstLaunchDate);

    if (firstLaunchStr == null) return false;

    DateTime firstLaunchDate = DateTime.parse(firstLaunchStr);
    int daysSinceFirstLaunch = DateTime.now().difference(firstLaunchDate).inDays;

    // Show after 5 launches AND 3 days
    return count >= 5 && daysSinceFirstLaunch >= 3;
  }

  /// Triggers the native in-app review dialog.
  static Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await _markAsRated();
    } else {
      // Fallback to opening store
      await openStore();
    }
  }

  /// Opens the app's store page.
  static Future<void> openStore() async {
    // Note: You should provide your app's package name/ID here if needed for some platforms,
    // but in_app_review usually handles it for the current app.
    await _inAppReview.openStoreListing();
    await _markAsRated();
  }

  static Future<void> _markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlreadyRated, true);
  }
}
