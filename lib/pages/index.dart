import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '/services/provider.dart';
import '/services/base.dart';
import '/types/courses.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);
    _loadUserInfo();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      setState(() {
        _loadUserInfo();
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      if (mounted) {
        setState(() {
          _userInfo = null;
        });
      }
      return;
    }

    try {
      final userInfo = await _serviceProvider.coursesService.getUserInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWideScreen ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWideScreen ? 1.2 : 1.0,
                    children: [
                      _buildFeatureCard(
                        context,
                        '选课',
                        'WIP',
                        Icons.school,
                        Colors.blue,
                        () => context.router.pushPath('/courses/selection'),
                      ),
                      _buildFeatureCard(
                        context,
                        '课表',
                        'WIP',
                        Icons.calendar_today,
                        Colors.green,
                        () => context.router.pushPath('/courses/curriculum'),
                      ),
                      _buildFeatureCard(
                        context,
                        '成绩',
                        'WIP',
                        Icons.assessment,
                        Colors.orange,
                        () => context.router.pushPath('/courses/grade'),
                      ),
                      _buildAccountCard(context),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
      elevation: 4,
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
                        fontSize: 18,
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
      elevation: 4,
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
                      '账户',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final service = _serviceProvider.coursesService;

                  if (service.isOnline && _userInfo != null) {
                    return Text(
                      '已作为${_userInfo!.userName}登录',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
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
                        Text(
                          '处理中...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    );
                  } else if (service.hasError) {
                    return Text(
                      service.status == ServiceStatus.errorAuth
                          ? '认证错误'
                          : '网络错误',
                      style: TextStyle(fontSize: 12, color: Colors.red[600]),
                    );
                  } else {
                    return Text(
                      '请登录账户',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
