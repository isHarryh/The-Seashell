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

  @override
  void onServiceInit() {
    _loadUserInfo();
  }

  @override
  void onServiceStatusChanged() {
    // Schedule the state update for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _loadUserInfo();
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
            Expanded(child: _buildFeatureGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal grid layout based on available space
        final double cardMinWidth = 200.0;
        final double spacing = 16.0;

        int crossAxisCount = 2;
        if (constraints.maxWidth > 768) {
          crossAxisCount = (constraints.maxWidth / (cardMinWidth + spacing))
              .floor()
              .clamp(2, 4);
        } else if (constraints.maxWidth < 480) {
          crossAxisCount = 1;
        }

        // Calculate aspect ratio based on available width
        final double cardWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        final double cardHeight = cardWidth.clamp(180.0, 220.0);
        final double aspectRatio = cardWidth / cardHeight;

        final List<Widget> cards = [
          _buildAccountCard(context),
          _buildFeatureCard(
            context,
            '选课',
            '查看和管理课程',
            Icons.school,
            Colors.blue,
            () => context.router.pushPath('/courses/selection'),
          ),
          _buildFeatureCard(
            context,
            '课表',
            '查看课程安排',
            Icons.calendar_today,
            Colors.green,
            () => context.router.pushPath('/courses/curriculum'),
          ),
          _buildFeatureCard(
            context,
            '成绩',
            '查看考试成绩',
            Icons.assessment,
            Colors.orange,
            () => context.router.pushPath('/courses/grade'),
          ),
        ];

        if (crossAxisCount == 1) {
          // For narrow screens, use a column layout
          return SingleChildScrollView(
            child: Column(
              children: cards
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(height: cardHeight, child: card),
                    ),
                  )
                  .toList(),
            ),
          );
        } else {
          // For wider screens, use grid layout
          return GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
            children: cards,
          );
        }
      },
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
