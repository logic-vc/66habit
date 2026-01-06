import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/check_record.dart';
import '../core/database/database_helper.dart';
import '../core/utils/chain_calculator.dart';

class HabitWithData {
  final Habit habit;
  final ChainData chainData;
  final bool isCheckedToday;

  HabitWithData({
    required this.habit,
    required this.chainData,
    required this.isCheckedToday,
  });
}

class HabitProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Habit> _habits = [];
  Map<int, List<CheckRecord>> _checkRecords = {};
  bool _isLoading = false;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  /// Get habit with chain data
  HabitWithData? getHabitWithData(int habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final records = _checkRecords[habitId] ?? [];
    final chainData = ChainCalculator.getChainData(habit, records);
    final isChecked = ChainCalculator.isCheckedToday(records);

    return HabitWithData(
      habit: habit,
      chainData: chainData,
      isCheckedToday: isChecked,
    );
  }

  /// Get all habits with data
  List<HabitWithData> getAllHabitsWithData() {
    return _habits.map((habit) {
      final records = _checkRecords[habit.id] ?? [];
      final chainData = ChainCalculator.getChainData(habit, records);
      final isChecked = ChainCalculator.isCheckedToday(records);

      return HabitWithData(
        habit: habit,
        chainData: chainData,
        isCheckedToday: isChecked,
      );
    }).toList();
  }

  /// Load all habits and their check records
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _db.getAllHabits();

      // Load check records for each habit
      _checkRecords.clear();
      for (final habit in _habits) {
        if (habit.id != null) {
          final records = await _db.getCheckRecordsByHabit(habit.id!);
          _checkRecords[habit.id!] = records;
        }
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      final id = await _db.insertHabit(habit);
      final newHabit = habit.copyWith(id: id);
      _habits.add(newHabit);
      _checkRecords[id] = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding habit: $e');
      rethrow;
    }
  }

  /// Update a habit
  Future<void> updateHabit(Habit habit) async {
    try {
      await _db.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(int habitId) async {
    try {
      await _db.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      _checkRecords.remove(habitId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  /// Check a habit for today
  Future<int?> checkHabitToday(int habitId) async {
    try {
      final today = CheckRecord.normalizeDate(DateTime.now());
      final record = CheckRecord(
        habitId: habitId,
        checkDate: today,
      );

      final recordId = await _db.insertCheckRecord(record);
      final newRecord = record.copyWith(id: recordId);

      // Update local cache
      if (_checkRecords[habitId] == null) {
        _checkRecords[habitId] = [];
      }
      _checkRecords[habitId]!.add(newRecord);

      notifyListeners();

      // Check for milestone
      final records = _checkRecords[habitId]!;
      final currentStreak = ChainCalculator.calculateCurrentStreak(records);
      return ChainCalculator.getReachedMilestone(currentStreak);
    } catch (e) {
      debugPrint('Error checking habit: $e');
      rethrow;
    }
  }

  /// Uncheck a habit for a specific date
  Future<void> uncheckHabit(int habitId, DateTime date) async {
    try {
      await _db.deleteCheckRecordByDate(habitId, date);

      // Update local cache
      if (_checkRecords[habitId] != null) {
        _checkRecords[habitId]!.removeWhere((record) {
          final recordDate = CheckRecord.normalizeDate(record.checkDate);
          final targetDate = CheckRecord.normalizeDate(date);
          return recordDate == targetDate;
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error unchecking habit: $e');
      rethrow;
    }
  }

  /// Check if a habit is checked for a specific date
  bool isHabitChecked(int habitId, DateTime date) {
    final records = _checkRecords[habitId];
    if (records == null) return false;

    final targetDate = CheckRecord.normalizeDate(date);
    return records.any((record) {
      final recordDate = CheckRecord.normalizeDate(record.checkDate);
      return recordDate == targetDate;
    });
  }

  /// Get check records for a habit
  List<CheckRecord> getCheckRecords(int habitId) {
    return _checkRecords[habitId] ?? [];
  }
}
