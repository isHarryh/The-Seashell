import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/utils/app_bar.dart';

class UstbByytMockLoginPage extends StatefulWidget {
  const UstbByytMockLoginPage({super.key});

  @override
  State<UstbByytMockLoginPage> createState() => _UstbByytMockLoginPageState();
}

class _UstbByytMockLoginPageState extends State<UstbByytMockLoginPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);

    // Switch to mock service when entering this page
    _serviceProvider.switchToMockService();
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

      await _serviceProvider.loginToService();

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
      appBar: const PageAppBar(title: 'Mock登录 (开发者)'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '开发者模式',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '此模式使用模拟数据进行测试，不会连接到真实的教务系统。\n'
                      '适用于开发者调试和功能演示。',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Login section
            Text('模拟登录', style: Theme.of(context).textTheme.titleMedium),
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
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? '正在模拟登录...' : '模拟登录'),
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
