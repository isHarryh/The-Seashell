// Copyright (c) 2025, Harry Huang

import 'package:flutter/material.dart';

abstract class UnifiedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool autoImplyLeading;

  const UnifiedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.autoImplyLeading = true,
  });

  Color getBackgroundColor(BuildContext context);
  Color getForegroundColor(BuildContext context);
  double getElevation();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      titleSpacing: 8.0,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: autoImplyLeading,
      backgroundColor: getBackgroundColor(context),
      foregroundColor: getForegroundColor(context),
      elevation: getElevation(),
      scrolledUnderElevation: getElevation() + 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 8);
}

class TopAppBar extends UnifiedAppBar {
  const TopAppBar({super.key, super.actions}) : super(title: '大贝壳');

  @override
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Color getForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  @override
  double getElevation() => 2.0;
}

class PageAppBar extends UnifiedAppBar {
  const PageAppBar({
    super.key,
    required super.title,
    super.actions,
    super.leading,
    super.autoImplyLeading = true,
  }) : super();

  @override
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  @override
  Color getForegroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  double getElevation() => 1.0;
}
