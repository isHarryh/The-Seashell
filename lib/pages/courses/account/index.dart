import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/services/base.dart';
import '/types/courses.dart';
import '/utils/app_bar.dart';
import 'ustb_byyt_mock.dart';
import 'ustb_byyt_cookie.dart';
import 'ustb_byyt_sso.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  UserInfo? _userInfo;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showLoginButton = true;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);

    final service = _serviceProvider.coursesService;
    _showLoginButton = !service.isOnline;

    if (service.isOnline && _userInfo == null) {
      _loadUserInfoSilently();
    }
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final service = _serviceProvider.coursesService;
          setState(() {
            if (service.isOnline) {
              _showLoginButton = false;
            } else if (service.isOffline || service.hasError) {
              _showLoginButton = true;
            }
            // else: pending
          });

          // Load user info asynchronously after state update
          _loadUserInfoIfOnlineSilently();
        }
      });
    }
  }

  Future<void> _loadUserInfoIfOnlineSilently() async {
    final service = _serviceProvider.coursesService;

    if (service.isOnline) {
      await _loadUserInfoSilently();
    } else {
      if (mounted) {
        // Use post-frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _userInfo = null;
              _errorMessage = null;
            });
          }
        });
      }
    }
  }

  Future<void> _loadUserInfoSilently() async {
    try {
      final userInfo = await _serviceProvider.coursesService.getUserInfo();

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      await _serviceProvider.logoutFromCoursesService();

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

  String _getStatusText() {
    final service = _serviceProvider.coursesService;
    switch (service.status) {
      case ServiceStatus.online:
        return '已登录';
      case ServiceStatus.offline:
        return '未登录';
      case ServiceStatus.pending:
        return '处理中';
      case ServiceStatus.errorAuth:
        return '认证错误';
      case ServiceStatus.errorNetwork:
        return '网络错误';
    }
  }

  Color _getStatusColor() {
    final service = _serviceProvider.coursesService;
    switch (service.status) {
      case ServiceStatus.online:
        return Colors.green;
      case ServiceStatus.offline:
        return Colors.grey;
      case ServiceStatus.pending:
        return Colors.blue;
      case ServiceStatus.errorAuth:
      case ServiceStatus.errorNetwork:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = _serviceProvider.coursesService;

    return Scaffold(
      appBar: const PageAppBar(title: '账户'),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card with login/logout button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      service.isOnline
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: _getStatusColor(),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '服务状态',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (service.errorMessage != null)
                            Text(
                              service.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          if (service.isOnline)
                            Text(
                              _getLastHeartbeatText()!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Logout button (only show when logged in)
                    if (!_showLoginButton)
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleLogout,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red,
                                  ),
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: Text(_isLoading ? '登出中' : '登出'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Login methods section (only show when not logged in)
            if (_showLoginButton) ...[
              Text('登录方式', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              // Login methods list
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.security,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      title: const Text('统一身份认证登录'),
                      subtitle: const Text('推荐方式，使用USTB SSO系统安全便捷登录'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showSsoLoginDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.build_circle_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      ),
                      title: const Text('使用Mock进行测试'),
                      subtitle: const Text('适用于开发者，将使用离线的模拟数据进行测试'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showMockLoginDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.cookie_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      ),
                      title: const Text('使用Cookie登录账户'),
                      subtitle: const Text('适用于高级用户，需要手动提供Cookie'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showCookieLoginDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

            // User information section
            if (service.isOnline && _userInfo != null) ...[
              Text('个人信息', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and name
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              _userInfo!.userName.isNotEmpty
                                  ? _userInfo!.userName[0]
                                  : '?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userInfo!.userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_userInfo!.userNameAlt.isNotEmpty)
                                  Text(
                                    _userInfo!.userNameAlt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // User ID
                      _buildDetailRow('学号', _userInfo!.userId, null),

                      const SizedBox(height: 12),

                      // School information
                      _buildDetailRow(
                        '学院',
                        _userInfo!.userSchool,
                        _userInfo!.userSchoolAlt.isNotEmpty
                            ? _userInfo!.userSchoolAlt
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (service.isOnline &&
                _userInfo == null &&
                !_isLoading) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('暂无用户信息')),
                ),
              ),
            ],

            // On error
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '错误信息',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String? altValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (altValue != null)
                Text(
                  altValue,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String? _getLastHeartbeatText() {
    final service = _serviceProvider.coursesService;
    final lastHeartbeat = service.getLastHeartbeatTime();

    if (lastHeartbeat == null) {
      return '上次心跳: 暂无';
    }

    // yyyy-MM-dd hh:mm
    final year = lastHeartbeat.year.toString();
    final month = lastHeartbeat.month.toString().padLeft(2, '0');
    final day = lastHeartbeat.day.toString().padLeft(2, '0');
    final hour = lastHeartbeat.hour.toString().padLeft(2, '0');
    final minute = lastHeartbeat.minute.toString().padLeft(2, '0');

    return '上次心跳：$year-$month-$day $hour:$minute';
  }
}
