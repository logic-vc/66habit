import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../core/constants/haptic_patterns.dart';

enum HapticStrength {
  light,
  medium,
  heavy,
}

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;
  HapticStrength _strength = HapticStrength.medium;
  bool _canVibrate = false;

  Future<void> initialize() async {
    _canVibrate = await Vibrate.canVibrate;
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setStrength(HapticStrength strength) {
    _strength = strength;
  }

  bool get isEnabled => _isEnabled;
  HapticStrength get strength => _strength;

  Future<void> light() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    } else {
      await Vibrate.feedback(FeedbackType.light);
    }
  }

  Future<void> medium() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await Vibrate.feedback(FeedbackType.medium);
    }
  }

  Future<void> heavy() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
    } else {
      await Vibrate.feedback(FeedbackType.heavy);
    }
  }

  Future<void> success() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
    } else {
      await Vibrate.feedback(FeedbackType.success);
    }
  }

  Future<void> error() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await Vibrate.feedback(FeedbackType.error);
    }
  }

  Future<void> pressStart() async {
    if (!_isEnabled || !_canVibrate) return;
    await light();
  }

  Future<void> progress(double value) async {
    if (!_isEnabled || !_canVibrate) return;

    // Trigger at 25%, 50%, 75%
    if (value >= 0.24 && value < 0.26) {
      await light();
    } else if (value >= 0.49 && value < 0.51) {
      await medium();
    } else if (value >= 0.74 && value < 0.76) {
      await medium();
    }
  }

  Future<void> complete() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isAndroid && _canVibrate) {
      // Double tap vibration pattern
      Vibrate.vibrate(pattern: HapticPatterns.completePattern);
    } else {
      await heavy();
      await Future.delayed(const Duration(milliseconds: 100));
      await heavy();
    }
  }

  Future<void> milestone() async {
    if (!_isEnabled || !_canVibrate) return;

    if (Platform.isAndroid && _canVibrate) {
      Vibrate.vibrate(pattern: HapticPatterns.milestonePattern);
    } else {
      // Triple tap for iOS
      await heavy();
      await Future.delayed(const Duration(milliseconds: 100));
      await heavy();
      await Future.delayed(const Duration(milliseconds: 100));
      await heavy();
    }
  }
}
