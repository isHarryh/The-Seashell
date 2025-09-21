import 'package:flutter/material.dart';

class LoginDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? headerColor;
  final Color? onHeaderColor;
  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final bool scrollable;

  const LoginDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
    this.iconColor,
    this.headerColor,
    this.onHeaderColor,
    this.maxWidth = 900,
    this.maxHeight = 700,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveHeaderColor = headerColor ?? colorScheme.primaryContainer;
    final effectiveOnHeaderColor =
        onHeaderColor ?? colorScheme.onPrimaryContainer;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: effectiveHeaderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: effectiveIconColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: effectiveOnHeaderColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Dialog content
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: child,
                    )
                  : Padding(padding: const EdgeInsets.all(20), child: child),
            ),
          ],
        ),
      ),
    );
  }
}
