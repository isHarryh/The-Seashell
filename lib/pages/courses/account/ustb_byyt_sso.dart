import 'package:flutter/material.dart';
import 'package:ustb_sso/ustb_sso.dart';
import '/services/provider.dart';
import '/utils/login_dialog.dart';
import '/utils/ustb_sso.dart';

Future<void> showSsoLoginDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const _SsoLoginDialog();
    },
  );
}

class _SsoLoginDialog extends StatefulWidget {
  const _SsoLoginDialog();

  @override
  State<_SsoLoginDialog> createState() => _SsoLoginDialogState();
}

class _SsoLoginDialogState extends State<_SsoLoginDialog> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);

    // Switch to production service when opening dialog
    _serviceProvider.switchToProductionService();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() async {
    if (mounted) {
      final service = _serviceProvider.coursesService;
      if (service.isOnline) {
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          // Close dialog on successful login
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _handleAuthSuccess(dynamic response, HttpSession session) async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      // Extract BYYT-specific cookies from the session
      final cookie = _extractByytCookie(session);
      if (cookie == null) {
        throw Exception('Failed to extract BYYT cookies from session.');
      }

      // Login with extracted cookie
      await _serviceProvider.loginToCoursesServiceWithCookie(cookie);
    } catch (e) {
      // Error handling is done by the auth widget
      print('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  // Extract BYYT-specific cookies from session
  String? _extractByytCookie(HttpSession session) {
    final cookies = <String>[];

    // Extract relevant cookies for BYYT system
    if (session.cookies.has('INCO')) {
      final incoCookie = session.cookies.get('INCO');
      cookies.add('INCO=$incoCookie');
    }

    if (session.cookies.has('SESSION')) {
      final sessionCookie = session.cookies.get('SESSION');
      cookies.add('SESSION=$sessionCookie');
    }

    // Add other relevant cookies
    for (final cookieName in ['JSESSIONID', 'cookie_vjuid_login']) {
      if (session.cookies.has(cookieName)) {
        final cookieValue = session.cookies.get(cookieName);
        cookies.add('$cookieName=$cookieValue');
      }
    }

    return cookies.isNotEmpty ? cookies.join('; ') : null;
  }

  @override
  Widget build(BuildContext context) {
    return LoginDialog(
      title: '统一身份认证',
      description: '本研一体教务管理系统',
      icon: Icons.security,
      iconColor: Theme.of(context).colorScheme.primary,
      headerColor: Theme.of(context).colorScheme.primaryContainer,
      onHeaderColor: Theme.of(context).colorScheme.onPrimaryContainer,
      maxWidth: 900,
      maxHeight: 700,
      child: Column(
        children: [
          // Authentication widget
          UstbSsoAuthWidget(
            applicationParam: Prefabs.byytUstbEduCn,
            onSuccess: _handleAuthSuccess,
          ),

          // Login status overlay
          if (_isLoggingIn) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '正在登录到课程系统...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
