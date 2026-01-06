class Habit {
  final int? id;
  final String name;
  final String goal;
  final DateTime startDate;
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    this.id,
    required this.name,
    required this.goal,
    required this.startDate,
    DateTime? createdAt,
    this.isArchived = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'start_date': startDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  // Create from Map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      goal: map['goal'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: (map['is_archived'] as int) == 1,
    );
  }

  // Copy with method for updates
  Habit copyWith({
    int? id,
    String? name,
    String? goal,
    DateTime? startDate,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, goal: $goal, startDate: $startDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.goal == goal &&
        other.startDate == startDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, goal, startDate);
  }
}
