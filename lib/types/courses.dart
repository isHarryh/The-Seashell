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

class CourseGradeItem {
  final String courseId;
  final String courseName;
  final String? courseNameAlt;
  final String termId;
  final String termName;
  final String termNameAlt;
  final String type;
  final String category;
  final String? schoolName;
  final String? schoolNameAlt;
  final String? makeupStatus;
  final String? makeupStatusAlt;
  final String? examType;
  final int hours;
  final int credit;
  final int score;

  const CourseGradeItem({
    required this.courseId,
    required this.courseName,
    this.courseNameAlt,
    required this.termId,
    required this.termName,
    required this.termNameAlt,
    required this.type,
    required this.category,
    this.schoolName,
    this.schoolNameAlt,
    this.makeupStatus,
    this.makeupStatusAlt,
    this.examType,
    required this.hours,
    required this.credit,
    required this.score,
  });

  factory CourseGradeItem.fromJson(Map<String, dynamic> json) {
    return CourseGradeItem(
      courseId: json['kcdm'] as String? ?? '',
      courseName: json['kcmc'] as String? ?? '',
      courseNameAlt: json['kcmc_en'] as String?,
      termId: json['xnxq'] as String? ?? '',
      termName: json['xnxqmc'] as String? ?? '',
      termNameAlt: json['xnxqmcen'] as String? ?? '',
      type: json['kcxz'] as String? ?? '',
      category: json['kclb'] as String? ?? '',
      schoolName: json['yxmc'] as String?,
      schoolNameAlt: json['yxmc_en'] as String?,
      makeupStatus: json['bkcx'] as String?,
      makeupStatusAlt: json['bkcx_en'] as String?,
      examType: json['khfs'] as String?,
      hours: int.tryParse(json['xs']?.toString() ?? '0') ?? 0,
      credit: json['xf'] as int? ?? 0,
      score: int.tryParse(json['zpcj']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseNameAlt': courseNameAlt,
      'termId': termId,
      'termName': termName,
      'termNameAlt': termNameAlt,
      'type': type,
      'category': category,
      'schoolName': schoolName,
      'schoolNameAlt': schoolNameAlt,
      'makeupStatus': makeupStatus,
      'makeupStatusAlt': makeupStatusAlt,
      'examType': examType,
      'hours': hours,
      'credit': credit,
      'score': score,
    };
  }

  @override
  String toString() {
    return 'CourseGradeItem(courseId: $courseId, courseName: $courseName, termName: $termName, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseGradeItem &&
        other.courseId == courseId &&
        other.termId == termId;
  }

  @override
  int get hashCode {
    return courseId.hashCode ^ termId.hashCode;
  }
}
