import 'package:flutter/material.dart';

Future<bool?> alertWarning(BuildContext context, String content, String tip) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.deepOrange, size: 24),
            SizedBox(width: 8),
            Text('选课警告'),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
