class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int studyTimeInMinutes; // Total study time in minutes
  final int completedActivities;
  final int totalActivities;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.studyTimeInMinutes,
    required this.completedActivities,
    required this.totalActivities,
    required this.createdAt,
    required this.lastLoginAt,
  });

  // Calculate completion rate percentage
  int get completionRate {
    if (totalActivities == 0) return 0;
    return ((completedActivities / totalActivities) * 100).round();
  }

  // Format study time as "70h23min"
  String getFormattedStudyTime() {
    final hours = studyTimeInMinutes ~/ 60;
    final minutes = studyTimeInMinutes % 60;
    return '${hours}h${minutes.toString().padLeft(2, '0')}min';
  }

  // Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      studyTimeInMinutes: json['studyTimeInMinutes'] ?? 0,
      completedActivities: json['completedActivities'] ?? 0,
      totalActivities: json['totalActivities'] ?? 0,
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
      'studyTimeInMinutes': studyTimeInMinutes,
      'completedActivities': completedActivities,
      'totalActivities': totalActivities,
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
      studyTimeInMinutes: studyTimeInMinutes ?? this.studyTimeInMinutes,
      completedActivities: completedActivities ?? this.completedActivities,
      totalActivities: totalActivities ?? this.totalActivities,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, studyTime: ${getFormattedStudyTime()}, completionRate: $completionRate%)';
  }
}