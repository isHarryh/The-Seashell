// Copyright (c) 2025, Harry Huang

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'utils/app_bar.dart';
import 'pages/index.dart';
import 'pages/courses/selection/index.dart';
import 'pages/courses/curriculum/index.dart';
import 'pages/courses/grade/index.dart';
import 'pages/courses/account/index.dart';

// App constants
class _AppConstants {
  static const double wideScreenBreakpoint = 768.0;
  static const double sideNavigationWidth = 240.0;
  static const Duration navigationAnimationDuration = Duration(
    milliseconds: 200,
  );
  static const String appName = '大贝壳';
  static const IconData appIcon = Icons.waves;

  static const List<_NavigationItem> navigationItems = [
    _NavigationItem(icon: Icons.home, title: '主页', path: '/'),
    _NavigationItem(
      icon: Icons.account_circle,
      title: '教务账户',
      path: '/courses/account',
      category: '本研一体教务管理系统',
    ),
    _NavigationItem(
      icon: Icons.school,
      title: '选课',
      path: '/courses/selection',
      category: '本研一体教务管理系统',
    ),
    _NavigationItem(
      icon: Icons.calendar_today,
      title: '课表',
      path: '/courses/curriculum',
      category: '本研一体教务管理系统',
    ),
    _NavigationItem(
      icon: Icons.assessment,
      title: '成绩',
      path: '/courses/grade',
      category: '本研一体教务管理系统',
    ),
  ];
}

class _NavigationItem {
  final IconData icon;
  final String title;
  final String path;
  final String? category;

  const _NavigationItem({
    required this.icon,
    required this.title,
    required this.path,
    this.category,
  });
}

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
        name: 'AccountRoute',
        path: '/courses/account',
        builder: (context, data) => const MainLayout(child: AccountPage()),
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
  bool _isWideScreen = false;
  Widget? _cachedChild;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    final newIsWideScreen = size.width > _AppConstants.wideScreenBreakpoint;
    if (_isWideScreen != newIsWideScreen) {
      setState(() {
        _isWideScreen = newIsWideScreen;
      });
    }
  }

  String get _currentPath {
    if (context.mounted) {
      final routeData = context.routeData;
      return routeData.path;
    }
    return '/';
  }

  void _navigateToPage(String path, {bool isDrawer = false}) {
    if (context.mounted && _currentPath != path) {
      if (_isWideScreen) {
        // For wide screen, pop all and push new route to avoid history accumulation and smooth transition
        context.router.popUntilRoot();
        context.router.pushPath(path);
      } else {
        // For narrow screen, use normal navigation
        context.router.pushPath(path);
      }

      if (isDrawer) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cache the child to prevent unnecessary rebuilds when switching layouts
    _cachedChild ??= widget.child;
    if (_cachedChild != widget.child) {
      _cachedChild = widget.child;
    }

    if (_isWideScreen) {
      return _buildWideScreenLayout();
    } else {
      return _buildNarrowScreenLayout();
    }
  }

  Widget _buildWideScreenLayout() {
    return Scaffold(
      body: Row(
        children: [
          _SideNavigation(
            isDrawer: false,
            currentPath: _currentPath,
            onNavigate: _navigateToPage,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: _AppConstants.navigationAnimationDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                key: ValueKey(_currentPath),
                child: _cachedChild!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout() {
    return Scaffold(
      appBar: const TopAppBar(),
      drawer: Drawer(
        child: _SideNavigation(
          isDrawer: true,
          currentPath: _currentPath,
          onNavigate: (path) => _navigateToPage(path, isDrawer: true),
        ),
      ),
      body: _cachedChild!,
    );
  }
}

class _SideNavigation extends StatelessWidget {
  final bool isDrawer;
  final String currentPath;
  final void Function(String path) onNavigate;

  const _SideNavigation({
    required this.isDrawer,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDrawer ? null : _AppConstants.sideNavigationWidth,
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
                    _AppConstants.appIcon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    _AppConstants.appName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
          ] else ...[
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  Icon(
                    _AppConstants.appIcon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    _AppConstants.appName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavigationItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    final groupedItems = _getGroupedNavigationItems();
    final widgets = <Widget>[];

    for (final entry in groupedItems.entries) {
      final category = entry.key;
      final items = entry.value;

      // Add category header if not null and not the first category (main)
      if (category != null && widgets.isNotEmpty) {
        widgets.addAll([
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ]);
      }

      // Add navigation items
      for (final item in items) {
        widgets.add(
          _buildNavItem(
            context: context,
            icon: item.icon,
            title: item.title,
            isSelected: currentPath == item.path,
            onTap: () => onNavigate(item.path),
          ),
        );
      }
    }

    return widgets;
  }

  Map<String?, List<_NavigationItem>> _getGroupedNavigationItems() {
    final Map<String?, List<_NavigationItem>> grouped = {};
    for (final item in _AppConstants.navigationItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ),
    );
  }
}
