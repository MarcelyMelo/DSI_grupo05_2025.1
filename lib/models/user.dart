class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int studyTimeMinutes; // Total study time in minutes
  final int completedActivities;
  final int completionRate;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.studyTimeMinutes,
    required this.completedActivities,
    required this.completionRate,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Format study time as "70h23min"
  String getFormattedStudyTime() {
    int hours = studyTimeMinutes ~/ 60;
    int minutes = studyTimeMinutes % 60;
    return '${hours}h${minutes.toString().padLeft(2, '0')}min';
  }

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      studyTimeMinutes: json['studyTimeInMinutes'] ?? 0,
      completedActivities: json['completedActivities'] ?? 0,
      completionRate: json['completionRate'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'studyTimeInMinutes': studyTimeMinutes,
      'completedActivities': completedActivities,
      'completionRate': completionRate,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    int? studyTimeInMinutes,
    int? completedActivities,
    int? totalActivities,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      studyTimeMinutes: studyTimeInMinutes ?? this.studyTimeMinutes,
      completedActivities: completedActivities ?? this.completedActivities,
      completionRate: totalActivities ?? this.completionRate,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, studyTime: ${getFormattedStudyTime()}, completionRate: $completionRate%)';
  }
}