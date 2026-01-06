import 'package:flutter_vibrate/flutter_vibrate.dart';

class HapticPatterns {
  // Feedback types for different interactions
  static const FeedbackType pressStart = FeedbackType.light;
  static const FeedbackType progress25 = FeedbackType.light;
  static const FeedbackType progress50 = FeedbackType.medium;
  static const FeedbackType progress75 = FeedbackType.medium;
  static const FeedbackType complete = FeedbackType.heavy;
  static const FeedbackType success = FeedbackType.success;
  static const FeedbackType error = FeedbackType.error;

  // Vibration patterns (for Android)
  static const List<int> completePattern = [0, 50, 50, 100];
  static const List<int> milestonePattern = [0, 100, 50, 100, 50, 100];
}
