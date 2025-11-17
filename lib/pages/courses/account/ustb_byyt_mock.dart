import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/utils/login_dialog.dart';

Future<void> showMockLoginDialog(
  BuildContext context, {
  Function(String method, String? cookie)? onLoginSuccess,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _MockLoginDialog(onLoginSuccess: onLoginSuccess);
    },
  );
}

class _MockLoginDialog extends StatefulWidget {
  final Function(String method, String? cookie)? onLoginSuccess;

  const _MockLoginDialog({this.onLoginSuccess});

  @override
  State<_MockLoginDialog> createState() => _MockLoginDialogState();
}

class _MockLoginDialogState extends State<_MockLoginDialog> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);

    // Switch to mock service when entering this page
    _serviceProvider.switchCoursesService(ServiceType.mock);
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      final service = _serviceProvider.coursesService;
      if (service.isOnline) {
        // Navigate back to account page on successful login
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleLogin() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _serviceProvider.loginToCoursesService();

      // Notify success
      widget.onLoginSuccess?.call("mock", null);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginDialog(
      title: 'Mock登录',
      description: '本研一体教务管理系统',
      icon: Icons.build_circle_outlined,
      iconColor: Theme.of(context).colorScheme.secondary,
      headerColor: Theme.of(context).colorScheme.secondaryContainer,
      onHeaderColor: Theme.of(context).colorScheme.onSecondaryContainer,
      child: Column(
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '开发者模式',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '此模式将使用离线的模拟数据，不会进行实际的网络请求。\n'
                  '适用于开发和测试环境。',
                  style: TextStyle(height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('登录中...'),
                      ],
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '使用Mock登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
