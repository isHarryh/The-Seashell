class UserInfo {
  final String userName;
  final String userNameAlt;
  final String userSchool;
  final String userSchoolAlt;
  final String userId;

  const UserInfo({
    required this.userName,
    required this.userNameAlt,
    required this.userSchool,
    required this.userSchoolAlt,
    required this.userId,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] as String? ?? '',
      userNameAlt: json['userNameAlt'] as String? ?? '',
      userSchool: json['userSchool'] as String? ?? '',
      userSchoolAlt: json['userSchoolAlt'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userNameAlt': userNameAlt,
      'userSchool': userSchool,
      'userSchoolAlt': userSchoolAlt,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'UserInfo(userName: $userName, userNameAlt: $userNameAlt, userSchool: $userSchool, userSchoolAlt: $userSchoolAlt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.userName == userName &&
        other.userNameAlt == userNameAlt &&
        other.userSchool == userSchool &&
        other.userSchoolAlt == userSchoolAlt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        userNameAlt.hashCode ^
        userSchool.hashCode ^
        userSchoolAlt.hashCode ^
        userId.hashCode;
  }
}
