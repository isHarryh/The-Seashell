import 'package:flutter/material.dart';
import '/types/courses.dart';

Future<bool?> alertWarning(BuildContext context, String content, String tip) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('选课警告'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: const TextStyle(fontSize: 16)),
            if (tip.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                tip,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('否'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('是'),
          ),
        ],
      );
    },
  );
}

Future<bool?> alertClassDuplicatedWarning(BuildContext context) {
  return alertWarning(context, '您真的要在同一课程下选择多个讲台吗？', '服务器很可能会拒绝你所选的多余的讲台。');
}

Future<bool?> alertClassFullWarning(BuildContext context) {
  return alertWarning(
    context,
    '您真的要选择容量已满的讲台吗？',
    '提交选课后，服务器很可能会拒绝您目前的请求，但采用特定的重试策略则有机会实现退课候补。',
  );
}

Future<bool?> alertClearSelectedWarning(BuildContext context) {
  return alertWarning(context, '您真的要清除备选课程列表吗？', '');
}

Widget buildStepIndicator(BuildContext context, int currentStep) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
      ),
    ),
    child: Row(
      children: [
        _buildStepItem(context, '选择学期', 1, currentStep == 1),
        _buildStepConnector(context),
        _buildStepItem(context, '选择课程', 2, currentStep == 2),
        _buildStepConnector(context),
        _buildStepItem(context, '提交选课', 3, currentStep == 3),
      ],
    ),
  );
}

Widget _buildStepItem(
  BuildContext context,
  String title,
  int stepNumber,
  bool isActive,
) {
  return Expanded(
    child: Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStepConnector(BuildContext context) {
  return Container(
    height: 2,
    width: 20,
    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
  );
}

Widget buildTermInfoDisplay(BuildContext context, TermInfo termInfo) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 2),
        Text(
          '${termInfo.year}-${termInfo.season}',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
