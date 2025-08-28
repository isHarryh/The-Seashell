import 'dart:convert';
import 'package:http/http.dart' as http;
import '/types/courses.dart';
import '/services/base.dart';
import '/services/courses/base.dart';

class _CourseSelectionSharedParams {
  final TermInfo? termInfo;
  final bool isForSubmission;
  final String? tabId;
  final String? classId;
  final String? courseId;

  const _CourseSelectionSharedParams({
    this.termInfo,
    this.isForSubmission = false,
    this.tabId,
    this.classId,
    this.courseId,
  });

  Map<String, String> toFormData() {
    final xnxq = termInfo != null
        ? '${termInfo!.year}${termInfo!.season}'
        : null;

    return {
      // Fixed
      'cxsfmt': '1',
      'p_pylx': '1',
      'mxpylx': '1',
      'p_sfgldjr': '0',
      'p_sfredis': '0',
      'p_sfsyxkgwc': '0',

      // Submit destination
      'p_xktjz': isForSubmission ? 'rwtjzyx' : '',

      // Reserved
      'p_chaxunxh': '',
      'p_gjz': '',
      'p_skjs': '',

      // Year and term
      'p_xn': termInfo?.year ?? '',
      'p_xq': termInfo?.season.toString() ?? '',
      'p_xnxq': xnxq ?? '',
      'p_dqxn': termInfo?.year ?? '',
      'p_dqxq': termInfo?.season.toString() ?? '',
      'p_dqxnxq': xnxq ?? '',

      // Course tab
      'p_xkfsdm': tabId ?? '',

      // Reserved
      'p_xiaoqu': '',
      'p_kkyx': '',
      'p_kclb': '',
      'p_xkxs': '',
      'p_dyc': '',
      'p_kkxnxq': '',

      // Class ID
      'p_id': classId ?? '',

      // Reserved
      'p_sfhlctkc': '0',
      'p_sfhllrlkc': '0',
      'p_kxsj_xqj': '',
      'p_kxsj_ksjc': '',
      'p_kxsj_jsjc': '',
      'p_kcdm_js': '',

      // Course ID
      'p_kcdm_cxrw': courseId ?? '',
      'p_kcdm_cxrw_zckc': courseId ?? '',

      // Reserved
      'p_kc_gjz': '',
      'p_xzcxtjz_nj': '',
      'p_xzcxtjz_yx': '',
      'p_xzcxtjz_zy': '',
      'p_xzcxtjz_zyfx': '',
      'p_xzcxtjz_bj': '',
      'p_sfxsgwckb': '1',
      'p_skyy': '',
      'p_sfmxzj': '',
      'p_chaxunxkfsdm': '',
    };
  }
}

class UstbByytProdService extends BaseCoursesService {
  String? _cookie;
  DateTime? _lastHeartbeatTime;
  CourseSelectionState _selectionState = const CourseSelectionState();

  static const String _baseUrl = 'https://byyt.ustb.edu.cn';

  @override
  Future<void> login() async {
    // Default login method - not implemented for prod service
    throw Exception('Use loginWithCookie() method for production service');
  }

  Future<void> loginWithCookie(String cookie) async {
    try {
      setPending();
      _cookie = cookie;

      // Validate cookie by trying to get user info
      await getUserInfo();

      setOnline();
    } catch (e) {
      _cookie = null;
      setNetworkError('Failed to login with cookie: $e');
      rethrow;
    }
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    };

    if (_cookie != null) {
      headers['Cookie'] = _cookie!;
    }

    return headers;
  }

  @override
  Future<void> logout() async {
    _cookie = null;
    _lastHeartbeatTime = null;
    _selectionState = const CourseSelectionState();
    setOffline();
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response contains user data
        if (data is Map<String, dynamic> && data.containsKey('xm')) {
          return UserInfo(
            userName: data['xm'] as String? ?? '',
            userNameAlt: data['xm_en'] as String? ?? '',
            userSchool: data['bmmc'] as String? ?? '',
            userSchoolAlt: data['bmmc_en'] as String? ?? '',
            userId: data['yhdm'] as String? ?? '',
          );
        } else {
          throw Exception('Invalid user data format');
        }
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        setNetworkError('Failed to get user info: HTTP ${response.statusCode}');
        throw Exception('Failed to get user info: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      setNetworkError('Failed to get user info: $e');
      throw Exception('Failed to get user info: $e');
    }
  }

  @override
  Future<List<CourseGradeItem>> getGrades() async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final requestBody = json.encode({
        'xn': null,
        'xq': null,
        'kcmc': null,
        'cxbj': '-1',
        'pylx': '1',
        'current': 1,
        'pageSize': 100,
        'sffx': null,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/cjgl/grcjcx/grcjcx'),
        headers: {
          ..._getHeaders(),
          'Content-Type': 'application/json', // This endpoint expects JSON
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 200 && data['content'] != null) {
          final List<dynamic> gradesList =
              data['content']['list'] as List<dynamic>? ?? [];

          return gradesList
              .map(
                (item) =>
                    CourseGradeItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'Failed to get grades: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        setNetworkError('Failed to get grades: HTTP ${response.statusCode}');
        throw Exception('Failed to get grades: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      setNetworkError('Failed to get grades: $e');
      throw Exception('Failed to get grades: $e');
    }
  }

  @override
  Future<List<ClassItem>> getCurriculum(TermInfo termInfo) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      return await _getCurriculumForTerm(termInfo);
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      setNetworkError('Failed to get curriculum: $e');
      throw Exception('Failed to get curriculum: $e');
    }
  }

  Future<List<ClassItem>> _getCurriculumForTerm(TermInfo term) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Xskbcx/queryXskbcxList'),
      headers: _getHeaders(),
      body: 'bs=2&xn=${term.year}&xq=${term.season}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Handle different response formats
      List<dynamic> curriculumList;

      if (data is List) {
        // Direct array response
        curriculumList = data;
      } else if (data is Map<String, dynamic>) {
        if (data['code'] == 200 && data['content'] != null) {
          curriculumList = data['content'] as List<dynamic>? ?? [];
        } else {
          throw Exception(
            'Failed to get curriculum: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Unexpected response format');
      }

      // Parse curriculum items
      final classList = <ClassItem>[];
      for (final item in curriculumList) {
        final classItem = ClassItem.fromJson(item as Map<String, dynamic>);
        if (classItem != null) {
          classList.add(classItem);
        }
      }

      return classList;
    } else if (response.statusCode == 401) {
      setAuthError('Authentication failed - invalid cookie');
      throw Exception('Authentication failed - invalid cookie');
    } else {
      throw Exception('Failed to get curriculum: HTTP ${response.statusCode}');
    }
  }

  @override
  Future<List<ClassPeriod>> getCoursePeriods(TermInfo termInfo) async {
    if (status == ServiceStatus.offline) {
      throw Exception('Not logged in');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/component/queryKbjg'),
        headers: _getHeaders(),
        body: {
          'xn': termInfo.year,
          'xq': termInfo.season.toString(),
          'nodataqx': '1',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> periodsList;
        if (data is Map<String, dynamic>) {
          if (data['code'] == 200 && data['content'] != null) {
            periodsList = data['content'] as List<dynamic>? ?? [];
          } else {
            throw Exception(
              'Failed to get course periods: ${data['msg'] ?? 'Unknown error'}',
            );
          }
        } else {
          throw Exception('Unexpected response format');
        }

        return periodsList
            .map((item) => ClassPeriod.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception(
          'Failed to get course periods: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      setNetworkError('Failed to get course periods: $e');
      throw Exception('Failed to get course periods: $e');
    }
  }

  @override
  Future<bool> sendHeartbeat() async {
    if (status == ServiceStatus.offline || _cookie == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/component/online'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if heartbeat was successful based on response code
        final success = data['code'] == 0;

        if (success) {
          _lastHeartbeatTime = DateTime.now();
        } else {
          // Heartbeat failed, might need to re-authenticate
          setAuthError('Heartbeat failed: ${data['msg'] ?? 'Unknown error'}');
        }

        return success;
      } else {
        setNetworkError(
          'Heartbeat request failed with status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      setNetworkError('Heartbeat failed: $e');
      return false;
    }
  }

  @override
  DateTime? getLastHeartbeatTime() {
    return _lastHeartbeatTime;
  }

  @override
  Future<List<CourseInfo>> getSelectedCourses(TermInfo termInfo) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final params = _CourseSelectionSharedParams(
        termInfo: termInfo,
        tabId: 'yixuan',
      );
      final formData = params.toFormData();

      final response = await http.post(
        Uri.parse('$_baseUrl/Xsxk/queryYxkc'),
        headers: _getHeaders(),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> coursesList;
        if (data is Map<String, dynamic>) {
          if (data['code'] == 200 && data['content'] != null) {
            coursesList = data['content'] as List<dynamic>? ?? [];
          } else {
            throw Exception(
              'Failed to get selected courses: ${data['msg'] ?? 'Unknown error'}',
            );
          }
        } else {
          throw Exception('Unexpected response format');
        }

        return coursesList
            .map((item) => CourseInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception(
          'Failed to get selected courses: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      setNetworkError('Failed to get selected courses: $e');
      throw Exception('Failed to get selected courses: $e');
    }
  }

  @override
  Future<List<CourseInfo>> getSelectableCourses(
    TermInfo termInfo,
    String tab,
  ) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final params = _CourseSelectionSharedParams(
        termInfo: termInfo,
        tabId: tab,
      );
      final formData = params.toFormData();

      formData['pageNum'] = '1';
      formData['pageSize'] = '100';

      final response = await http.post(
        Uri.parse('$_baseUrl/Xsxk/queryKxrw'),
        headers: _getHeaders(),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final Map<String, dynamic>? kxrwList =
            data['kxrwList'] as Map<String, dynamic>?;
        final List<dynamic> coursesList =
            kxrwList?['list'] as List<dynamic>? ?? [];

        return coursesList
            .map(
              (item) => CourseInfo.fromJson(
                item as Map<String, dynamic>,
                fromTabId: tab,
              ),
            )
            .toList();
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception(
          'Failed to get selectable courses: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      setNetworkError('Failed to get selectable courses: $e');
      throw Exception('Failed to get selectable courses: $e');
    }
  }

  @override
  Future<List<CourseTab>> getCourseTabs(TermInfo termInfo) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final params = _CourseSelectionSharedParams(
        termInfo: termInfo,
        tabId: 'yixuan',
      );
      final formData = params.toFormData();

      final response = await http.post(
        Uri.parse('$_baseUrl/Xsxk/queryYxkc'),
        headers: _getHeaders(),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> tabsList = data['xkgzszList'] as List<dynamic>? ?? [];

        return tabsList
            .map((item) => CourseTab.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception(
          'Failed to get course tabs: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      setNetworkError('Failed to get course tabs: $e');
      throw Exception('Failed to get course tabs: $e');
    }
  }

  @override
  Future<List<TermInfo>> getTerms() async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/component/queryXnxq'),
        headers: _getHeaders(),
        body: {'data': 'cTnrJ54+H2bKCT5c1Gq1+w=='},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 200 && data['content'] != null) {
          final List<dynamic> termsList = data['content'] as List<dynamic>;

          return termsList
              .map((item) => TermInfo.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Failed to get terms: ${data['msg'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        setNetworkError('Failed to get terms: HTTP ${response.statusCode}');
        throw Exception('Failed to get terms: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      setNetworkError('Failed to get terms: $e');
      throw Exception('Failed to get terms: $e');
    }
  }

  @override
  Future<List<CourseInfo>> getCourseDetail(
    TermInfo termInfo,
    CourseInfo courseInfo,
  ) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final params = _CourseSelectionSharedParams(
        termInfo: termInfo,
        tabId: courseInfo.fromTabId,
        courseId: courseInfo.courseId,
      );
      final formData = params.toFormData();

      formData['pageNum'] = '1';
      formData['pageSize'] = '100';

      final response = await http.post(
        Uri.parse('$_baseUrl/Xsxk/queryKxrw'),
        headers: _getHeaders(),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final Map<String, dynamic>? kxrwList =
            data['kxrwList'] as Map<String, dynamic>?;
        final List<dynamic> coursesList =
            kxrwList?['list'] as List<dynamic>? ?? [];

        // Filter
        List<CourseInfo> results = [];
        for (var courseJson in coursesList) {
          try {
            final courseDetail = CourseInfo.fromJson(
              courseJson as Map<String, dynamic>,
              fromTabId: courseInfo.fromTabId,
            );

            if (courseDetail.courseId == courseInfo.courseId &&
                courseDetail.classDetail != null) {
              results.add(courseDetail);
            }
          } catch (e) {
            continue;
          }
        }

        return results;
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception(
          'Failed to get course detail: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      setNetworkError('Failed to get course detail: $e');
      throw Exception('Failed to get course detail: $e');
    }
  }

  @override
  CourseSelectionState getCourseSelectionState() {
    return _selectionState;
  }

  @override
  void updateCourseSelectionState(CourseSelectionState state) {
    _selectionState = state;
  }

  @override
  void addCourseToSelection(CourseInfo course) {
    _selectionState = _selectionState.addCourse(course);
  }

  @override
  void removeCourseFromSelection(String courseId, [String? classId]) {
    _selectionState = _selectionState.removeCourse(courseId, classId);
  }

  @override
  void setSelectionTermInfo(TermInfo termInfo) {
    _selectionState = _selectionState.setTermInfo(termInfo);
  }

  @override
  void clearCourseSelection() {
    _selectionState = _selectionState.clear();
  }

  @override
  Future<bool> sendCourseSelection(
    TermInfo termInfo,
    CourseInfo courseInfo,
  ) async {
    if (status == ServiceStatus.offline || _cookie == null) {
      throw Exception('Not logged in');
    }

    try {
      final params = _CourseSelectionSharedParams(
        termInfo: termInfo,
        isForSubmission: true,
        tabId: courseInfo.fromTabId,
        classId: courseInfo.classDetail?.classId ?? '',
        courseId: courseInfo.courseId,
      );

      final formData = params.toFormData();

      // 添加分页参数
      formData['pageNum'] = '1';
      formData['pageSize'] = '100';

      final response = await http.post(
        Uri.parse('$_baseUrl/Xsxk/addGouwuche'),
        headers: _getHeaders(),
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['jg'] != 1) {
            throw Exception('${data['message'] ?? 'Unknown error'}');
          }
          return true;
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 401) {
        setAuthError('Authentication failed - invalid cookie');
        throw Exception('Authentication failed - invalid cookie');
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setNetworkError('$e');
      throw Exception('$e');
    }
  }
}
