class CheckRecord {
  final int? id;
  final int habitId;
  final DateTime checkDate; // Date only (normalized to midnight)
  final DateTime checkedAt; // Full timestamp

  CheckRecord({
    this.id,
    required this.habitId,
    required this.checkDate,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  // Normalize date to midnight for comparison
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'check_date': _formatDate(checkDate),
      'checked_at': checkedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory CheckRecord.fromMap(Map<String, dynamic> map) {
    return CheckRecord(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      checkDate: _parseDate(map['check_date'] as String),
      checkedAt: DateTime.parse(map['checked_at'] as String),
    );
  }

  // Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Parse YYYY-MM-DD to DateTime
  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // Copy with method
  CheckRecord copyWith({
    int? id,
    int? habitId,
    DateTime? checkDate,
    DateTime? checkedAt,
  }) {
    return CheckRecord(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      checkDate: checkDate ?? this.checkDate,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  String toString() {
    return 'CheckRecord{id: $id, habitId: $habitId, checkDate: $checkDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckRecord &&
        other.id == id &&
        other.habitId == habitId &&
        other.checkDate == checkDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, habitId, checkDate);
  }
}
