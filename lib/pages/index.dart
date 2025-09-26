import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '/utils/page_mixins.dart';
import '/types/courses.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with PageStateMixin, LoadingStateMixin {
  UserInfo? _userInfo;

  ClassItem? _ongoingClass;
  ClassItem? _upcomingClass;
  CurriculumIntegratedData? _curriculumData;
  Timer? _refreshTimer;

  @override
  void onServiceInit() {
    _loadUserInfo();
    _loadCurriculumData();
    _startRefreshTimer();
  }

  @override
  void onServiceStatusChanged() {
    // Schedule the state update for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _loadUserInfo();
        _loadCurriculumData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _loadCurriculumData();
      }
    });
  }

  Future<void> _loadUserInfo() async {
    final service = serviceProvider.coursesService;

    if (!service.isOnline) {
      if (mounted) {
        setState(() {
          _userInfo = null;
        });
      }
      return;
    }

    try {
      final userInfo = await serviceProvider.coursesService.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userInfo = null;
        });
      }
    }
  }

  Future<void> _loadCurriculumData() async {
    try {
      final curriculumData = await serviceProvider.getCurriculumData();

      if (mounted) {
        final newOngoingClass = curriculumData?.getClassOngoing();
        final newUpcomingClass = curriculumData?.getClassUpcoming();

        if (_ongoingClass != newOngoingClass ||
            _upcomingClass != newUpcomingClass ||
            _curriculumData != curriculumData) {
          setState(() {
            _curriculumData = curriculumData;
            _ongoingClass = newOngoingClass;
            _upcomingClass = newUpcomingClass;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _curriculumData = null;
          _ongoingClass = null;
          _upcomingClass = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16),
            const Text(
              '欢迎来到大贝壳~',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '北京科技大学校园助手',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildFeatureGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrowScreen = constraints.maxWidth < 600;
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '教务',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "本研一体教务管理系统",
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              if (isNarrowScreen) ...[
                _buildNarrowLayout(),
              ] else ...[
                _buildWideLayout(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        SizedBox(
          height: (_ongoingClass != null || _upcomingClass != null) ? 200 : 140,
          child: _buildCurriculumCard(context, isWideScreen: false),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 100, child: _buildAccountCard(context)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: _buildFeatureCard(
            context,
            '选课',
            '查看和管理课程',
            Icons.school,
            Colors.blue,
            () => context.router.pushPath('/courses/selection'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: _buildFeatureCard(
            context,
            '成绩',
            '查看考试成绩',
            Icons.assessment,
            Colors.orange,
            () => context.router.pushPath('/courses/grade'),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: _buildCurriculumCard(context, isWideScreen: true),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(child: _buildAccountCard(context)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  '选课',
                  '查看和管理课程',
                  Icons.school,
                  Colors.blue,
                  () => context.router.pushPath('/courses/selection'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  '成绩',
                  '查看考试成绩',
                  Icons.assessment,
                  Colors.orange,
                  () => context.router.pushPath('/courses/grade'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculumCard(
    BuildContext context, {
    required bool isWideScreen,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.router.pushPath('/courses/curriculum'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.8),
                primaryColor,
                primaryColor.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildCurriculumContent(isWideScreen: isWideScreen),
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculumContent({required bool isWideScreen}) {
    if (isWideScreen) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 36, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '课表',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '查看每周课程安排',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (_ongoingClass != null || _upcomingClass != null) ...[
            const SizedBox(width: 16),
            Container(
              constraints: BoxConstraints(maxWidth: 290),
              child: _buildMultipleClassPreviews(),
            ),
          ],
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 32, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '课表',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_ongoingClass != null || _upcomingClass != null) ...[
            const SizedBox(height: 16),
            _buildMultipleClassPreviews(),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              '查看每周课程安排',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildMultipleClassPreviews() {
    final classes = <ClassItem?>[];
    if (_ongoingClass != null) classes.add(_ongoingClass);
    if (_upcomingClass != null) classes.add(_upcomingClass);

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: classes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final classItem = classes[index]!;
          final isOngoing = classItem == _ongoingClass;
          return _buildSingleClassPreview(classItem, isOngoing);
        },
      ),
    );
  }

  Widget _buildSingleClassPreview(ClassItem classItem, bool isOngoing) {
    final startTime = classItem.getMinStartTime(
      _curriculumData?.allPeriods ?? [],
    );
    final endTime = classItem.getMaxEndTime(_curriculumData?.allPeriods ?? []);
    String? periodTimeRange = startTime != null && endTime != null
        ? '${startTime.format(context)} - ${endTime.format(context)}'
        : null;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isOngoing ? '进行中' : '接下来',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            classItem.className,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (periodTimeRange != null)
            Text(
              periodTimeRange,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          Text(
            classItem.locationName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.router.pushPath('/courses/account'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_circle, size: 32, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '教务账户',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final service = serviceProvider.coursesService;

                  if (service.isOnline && _userInfo != null) {
                    return Text(
                      '已作为${_userInfo!.userName}登录',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  } else if (service.isPending) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text('处理中', style: TextStyle(fontSize: 14)),
                      ],
                    );
                  } else if (service.hasError) {
                    return Text(
                      '教务账户登录失败',
                      style: TextStyle(fontSize: 14, color: Colors.red[700]),
                    );
                  } else {
                    return Text(
                      '尚未登录教务账户',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
