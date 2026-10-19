class UserLearningGoal {
  final int? id;
  final int userId;
  final String goalName;
  final String createdAt;

  UserLearningGoal({
    this.id,
    required this.userId,
    required this.goalName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'goal_name': goalName,
      'created_at': createdAt,
    };
  }

  factory UserLearningGoal.fromMap(Map<String, dynamic> map) {
    return UserLearningGoal(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      goalName: map['goal_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
