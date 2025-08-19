// Copyright (c) 2025, Harry Huang

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'pages/index.dart';
import 'pages/courses/selection/index.dart';
import 'pages/courses/curriculum/index.dart';
import 'pages/courses/grade/index.dart';

// App router definition with auto_route package
// See: https://github.com/Milad-Akarie/auto_route_library
class AppRouter {
  static final router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'HomeRoute',
        path: '/',
        builder: (context, data) => const MainLayout(child: HomePage()),
      ),
      NamedRouteDef(
        name: 'CourseSelectionRoute',
        path: '/courses/selection',
        builder: (context, data) =>
            const MainLayout(child: CourseSelectionPage()),
      ),
      NamedRouteDef(
        name: 'CurriculumRoute',
        path: '/courses/curriculum',
        builder: (context, data) => const MainLayout(child: CurriculumPage()),
      ),
      NamedRouteDef(
        name: 'GradeRoute',
        path: '/courses/grade',
        builder: (context, data) => const MainLayout(child: GradePage()),
      ),
    ],
  );
}

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String get _currentPath {
    if (context.mounted) {
      final routeData = context.routeData;
      return routeData.path;
    }
    return '/';
  }

  void _navigateToPage(String path) {
    if (context.mounted) {
      context.router.pushPath(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        if (isWideScreen) {
          return _buildWideScreenLayout();
        } else {
          return _buildNarrowScreenLayout();
        }
      },
    );
  }

  Widget _buildWideScreenLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNavigation(false),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('大贝壳'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: Drawer(child: _buildSideNavigation(true)),
      body: widget.child,
    );
  }

  Widget _buildSideNavigation(bool isDrawer) {
    return Container(
      width: isDrawer ? null : 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: isDrawer
            ? null
            : Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          if (!isDrawer) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.waves,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '大贝壳',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
          ] else ...[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  Icon(Icons.waves, size: 32),
                  SizedBox(width: 12),
                  Text(
                    '大贝壳',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  title: '主页',
                  isSelected: _currentPath == '/',
                  onTap: () {
                    _navigateToPage('/');
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    '课程',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                _buildNavItem(
                  icon: Icons.school,
                  title: '选课',
                  isSelected: _currentPath == '/courses/selection',
                  onTap: () {
                    _navigateToPage('/courses/selection');
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  title: '课表',
                  isSelected: _currentPath == '/courses/curriculum',
                  onTap: () {
                    _navigateToPage('/courses/curriculum');
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                _buildNavItem(
                  icon: Icons.assessment,
                  title: '成绩',
                  isSelected: _currentPath == '/courses/grade',
                  onTap: () {
                    _navigateToPage('/courses/grade');
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(0.1),
        selectedColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
