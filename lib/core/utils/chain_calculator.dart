import '../../models/check_record.dart';
import '../../models/habit.dart';

class ChainData {
  final int currentStreak;
  final int longestStreak;
  final int totalChecks;
  final double completionRate;
  final List<bool> chain66; // 66 days chain (true = checked, false = not checked)
  final int daysElapsed;

  ChainData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalChecks,
    required this.completionRate,
    required this.chain66,
    required this.daysElapsed,
  });
}

class ChainCalculator {
  /// Calculate current streak (consecutive days from today backwards)
  static int calculateCurrentStreak(List<CheckRecord> records) {
    if (records.isEmpty) return 0;

    // Sort by date descending
    final sortedRecords = List<CheckRecord>.from(records)
      ..sort((a, b) => b.checkDate.compareTo(a.checkDate));

    final today = CheckRecord.normalizeDate(DateTime.now());
    int streak = 0;
    DateTime checkDate = today;

    for (final record in sortedRecords) {
      final recordDate = CheckRecord.normalizeDate(record.checkDate);

      if (recordDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (recordDate.isBefore(checkDate)) {
        // Gap found, break
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak in history
  static int calculateLongestStreak(List<CheckRecord> records) {
    if (records.isEmpty) return 0;

    // Sort by date ascending
    final sortedRecords = List<CheckRecord>.from(records)
      ..sort((a, b) => a.checkDate.compareTo(b.checkDate));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final record in sortedRecords) {
      final recordDate = CheckRecord.normalizeDate(record.checkDate);

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = recordDate.difference(lastDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
        } else {
          longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
          currentStreak = 1;
        }
      }

      lastDate = recordDate;
    }

    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
    return longestStreak;
  }

  /// Calculate completion rate (checks / days elapsed)
  static double calculateCompletionRate(Habit habit, List<CheckRecord> records) {
    final daysElapsed = calculateDaysElapsed(habit);
    if (daysElapsed == 0) return 0.0;

    final totalChecks = records.length;
    return (totalChecks / daysElapsed).clamp(0.0, 1.0);
  }

  /// Calculate days elapsed since habit start
  static int calculateDaysElapsed(Habit habit) {
    final today = CheckRecord.normalizeDate(DateTime.now());
    final startDate = CheckRecord.normalizeDate(habit.startDate);
    final diff = today.difference(startDate).inDays + 1; // +1 to include start day
    return diff > 0 ? diff : 0;
  }

  /// Generate 66-day chain (true = checked, false = not checked)
  static List<bool> generate66DayChain(Habit habit, List<CheckRecord> records) {
    final chain = List<bool>.filled(66, false);
    final startDate = CheckRecord.normalizeDate(habit.startDate);

    // Create a set of checked dates for O(1) lookup
    final checkedDates = <String>{};
    for (final record in records) {
      final dateStr = _formatDate(record.checkDate);
      checkedDates.add(dateStr);
    }

    // Fill chain
    for (int i = 0; i < 66; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dateStr = _formatDate(currentDate);

      // Only mark as checked if the date is not in the future
      final today = CheckRecord.normalizeDate(DateTime.now());
      if (currentDate.isAfter(today)) {
        // Future date, leave as false
        chain[i] = false;
      } else {
        chain[i] = checkedDates.contains(dateStr);
      }
    }

    return chain;
  }

  /// Get comprehensive chain data
  static ChainData getChainData(Habit habit, List<CheckRecord> records) {
    return ChainData(
      currentStreak: calculateCurrentStreak(records),
      longestStreak: calculateLongestStreak(records),
      totalChecks: records.length,
      completionRate: calculateCompletionRate(habit, records),
      chain66: generate66DayChain(habit, records),
      daysElapsed: calculateDaysElapsed(habit),
    );
  }

  /// Check if a specific date is in the future
  static bool isFutureDate(DateTime date) {
    final today = CheckRecord.normalizeDate(DateTime.now());
    final checkDate = CheckRecord.normalizeDate(date);
    return checkDate.isAfter(today);
  }

  /// Check if today is checked
  static bool isCheckedToday(List<CheckRecord> records) {
    final today = CheckRecord.normalizeDate(DateTime.now());
    final todayStr = _formatDate(today);

    for (final record in records) {
      if (_formatDate(record.checkDate) == todayStr) {
        return true;
      }
    }
    return false;
  }

  /// Get milestone (3 days, 7 days, 21 days, 30 days, 66 days)
  static int? getReachedMilestone(int currentStreak) {
    const milestones = [3, 7, 21, 30, 66];

    for (final milestone in milestones.reversed) {
      if (currentStreak == milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
