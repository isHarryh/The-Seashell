import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/utils/app_bar.dart';

class UstbByytCookieLoginPage extends StatefulWidget {
  const UstbByytCookieLoginPage({super.key});

  @override
  State<UstbByytCookieLoginPage> createState() =>
      _UstbByytCookieLoginPageState();
}

class _UstbByytCookieLoginPageState extends State<UstbByytCookieLoginPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  final TextEditingController _cookieController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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
    _cookieController.dispose();
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
    final cookie = _cookieController.text.trim();
    if (cookie.isEmpty) {
      setState(() {
        _errorMessage = '请输入有效的Cookie';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _serviceProvider.loginToCoursesServiceWithCookie(cookie);

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
    return Scaffold(
      appBar: const PageAppBar(title: 'Cookie登录 (高级用户)'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning card
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '高级用户模式',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '此模式需要您从浏览器中获取有效的会话Cookie并输入到下面的输入框中。\n'
                      '如果您不清楚您在做什么，请勿使用此功能。',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cookie input section
            Text('Cookie输入', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            TextField(
              controller: _cookieController,
              decoration: const InputDecoration(
                hintText: '请粘贴您的会话Cookie...\n例如：SESSION=xxxxxx; INCO=xxxxxx',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 4,
              minLines: 2,
            ),

            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Login button
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleLogin,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(_isLoading ? '正在登录...' : '使用Cookie登录'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
