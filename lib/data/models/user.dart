class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profileImagePath;
  final String educationLevel;
  final String? experienceLevel;
  final String createdAt;
  final String updatedAt;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profileImagePath,
    required this.educationLevel,
    this.experienceLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image_path': profileImagePath,
      'education_level': educationLevel,
      'experience_level': experienceLevel,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phone_number'] as String?,
      profileImagePath: map['profile_image_path'] as String?,
      educationLevel: map['education_level'] as String,
      experienceLevel: map['experience_level'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? educationLevel,
    String? experienceLevel,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      educationLevel: educationLevel ?? this.educationLevel,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
