class UserInterest {
  final int? id;
  final int userId;
  final String interestName;
  final String createdAt;

  UserInterest({
    this.id,
    required this.userId,
    required this.interestName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'interest_name': interestName,
      'created_at': createdAt,
    };
  }

  factory UserInterest.fromMap(Map<String, dynamic> map) {
    return UserInterest(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      interestName: map['interest_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
