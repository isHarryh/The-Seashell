import 'package:flutter/material.dart';
import 'package:ustb_sso/ustb_sso.dart';
import '/services/provider.dart';
import '/utils/app_bar.dart';
import '/utils/ustb_sso.dart';

class UstbByytSsoLoginPage extends StatefulWidget {
  const UstbByytSsoLoginPage({super.key});

  @override
  State<UstbByytSsoLoginPage> createState() => _UstbByytSsoLoginPageState();
}

class _UstbByytSsoLoginPageState extends State<UstbByytSsoLoginPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);

    // Switch to production service when entering this page
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
          // Navigate back to account page on successful login
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
    return Scaffold(
      appBar: const PageAppBar(title: '统一身份认证登录'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Info card
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'USTB SSO 统一认证',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '使用北京科技大学统一身份认证系统登录。\n'
                          '支持微信扫码和短信验证码两种方式。',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Authentication widget
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: UstbSsoAuthWidget(
                  applicationParam: Prefabs.byytUstbEduCn,
                  onSuccess: _handleAuthSuccess,
                ),
              ),
            ),

            // Login status overlay
            if (_isLoggingIn) ...[
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
