import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/provider.dart';
import '/types/net.dart';
import '/utils/app_bar.dart';
import '/utils/page_mixins.dart';
import 'bill.dart';
import 'login.dart';

class NetDashboardPage extends StatefulWidget {
  const NetDashboardPage({super.key});

  @override
  State<NetDashboardPage> createState() => _NetDashboardPageState();
}

class _NetDashboardPageState extends State<NetDashboardPage>
    with PageStateMixin, LoadingStateMixin {
  NetUserInfo? _userInfo;
  List<MacDevice>? _macDevices;
  List<MonthlyBill>? _monthlyBills;
  int _selectedYear = DateTime.now().year;

  bool _isLoggingOut = false;
  bool _isLoadingLogin = false;
  bool _isRefreshingDevices = false;
  bool _isLoadingBills = false;
  bool _isRefreshingUser = false;

  bool get _isOnline => serviceProvider.netService.isOnline;

  @override
  void onServiceInit() {
    _refreshData();
  }

  @override
  void onServiceStatusChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      if (_isOnline) {
        _refreshData();
      } else {
        setState(() {
          _userInfo = null;
          _macDevices = null;
          _monthlyBills = null;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    if (!_isOnline) {
      setState(() {
        _userInfo = null;
        _macDevices = null;
        _monthlyBills = null;
      });
      return;
    }

    setLoading(true);
    try {
      final results = await Future.wait([
        serviceProvider.netService.getUser(),
        serviceProvider.netService.getBoundedMac(),
        serviceProvider.netService.getMonthlyBill(year: _selectedYear),
      ]);
      final info = results[0] as NetUserInfo;
      final macDevices = results[1] as List<MacDevice>;
      final monthlyBills = results[2] as List<MonthlyBill>;
      final sortedBills = List<MonthlyBill>.from(monthlyBills)
        ..sort((a, b) => a.createTime.compareTo(b.createTime));
      if (!mounted) return;
      setState(() {
        _userInfo = info;
        _macDevices = macDevices;
        _monthlyBills = sortedBills;
      });
    } catch (e) {
      if (!mounted) return;
      setError(e.toString());
      // Force logout on error
      if (serviceProvider.netService.isOnline) {
        serviceProvider.netService.logout();
      }
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }

  Future<void> _refreshUserInfo() async {
    if (!_isOnline) return;
    setState(() => _isRefreshingUser = true);
    try {
      final info = await serviceProvider.netService.getUser();
      if (!mounted) return;
      setState(() => _userInfo = info);
    } catch (e) {
      if (!mounted) return;
      setError('刷新账户信息失败：$e');
    } finally {
      if (mounted) setState(() => _isRefreshingUser = false);
    }
  }

  Future<void> _refreshDevices() async {
    if (!_isOnline) return;
    setState(() {
      _isRefreshingDevices = true;
      _macDevices = null;
    });
    try {
      final macDevices = await serviceProvider.netService.getBoundedMac();
      if (!mounted) return;
      setState(() => _macDevices = macDevices);
    } catch (e) {
      if (!mounted) return;
      setError('刷新设备列表失败：$e');
    } finally {
      if (mounted) setState(() => _isRefreshingDevices = false);
    }
  }

  Future<void> _refreshBills() async {
    if (!_isOnline) return;
    setState(() {
      _isLoadingBills = true;
      _monthlyBills = null;
    });
    try {
      final monthlyBills = await serviceProvider.netService.getMonthlyBill(
        year: _selectedYear,
      );
      final sortedBills = List<MonthlyBill>.from(monthlyBills)
        ..sort((a, b) => a.createTime.compareTo(b.createTime));
      if (!mounted) return;
      setState(() => _monthlyBills = sortedBills);
    } catch (e) {
      if (!mounted) return;
      setError('刷新月度账单失败：$e');
    } finally {
      if (mounted) setState(() => _isLoadingBills = false);
    }
  }

  Future<void> _showLoginDialog(NetServiceType serviceType) async {
    setState(() => _isLoadingLogin = true);
    try {
      final result = await showDialog<NetUserIntegratedData>(
        context: context,
        builder: (context) => NetLoginDialog(serviceType: serviceType),
      );

      if (result != null) {
        await _refreshData();
      }
    } finally {
      if (mounted) setState(() => _isLoadingLogin = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    setState(() => _isLoggingOut = true);
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认登出'),
          content: const Text(
            '确定要退出校园网自助服务账号吗？'
            '\n\n'
            '这不会影响本机的校园网连接。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        try {
          await serviceProvider.logoutFromNetService();
          // Clear cached login data
          serviceProvider.storeService.removeCache("net_account_data");
          if (mounted) {
            setState(() {
              _userInfo = null;
              _macDevices = null;
              _monthlyBills = null;
            });
          }
        } catch (e) {
          if (mounted) setError('登出失败：$e');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _handleUnbindMac(MacDevice device) async {
    final normalizedMac = device.mac.toLowerCase();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解绑设备'),
        content: Text(
          '确定要解绑物理地址（MAC 地址）为 ${device.mac.toUpperCase()} 的设备吗？'
          '\n\n'
          '解绑后，该设备需要重新登录校园网。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await serviceProvider.netService.setMacUnbounded(normalizedMac);
      await _refreshDevices();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('解绑设备成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加设备失败：$e')));
      }
    }
  }

  // ignore: unused_element
  Future<void> _showAddDeviceDialog() async {
    final macController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加设备'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入设备的物理地址（MAC 地址）', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: macController,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 17,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(macController.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _handleAddDevice(result);
    }
  }

  Future<void> _handleAddDevice(String mac) async {
    final macRegex = RegExp(
      r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$|^[0-9A-Fa-f]{12}$',
    );
    if (!macRegex.hasMatch(mac)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MAC 地址格式不正确，应为 12 位十六进制数')),
        );
      }
      return;
    }

    try {
      final normalizedMac = mac.toLowerCase().replaceAll('-', ':');
      final formattedMac = normalizedMac.length == 12
          ? normalizedMac.replaceAllMapped(
              RegExp(r'(.{2})(?!$)'),
              (match) => '${match.group(0)}:',
            )
          : normalizedMac;

      await serviceProvider.netService.setMacBounded(formattedMac);
      await _refreshDevices();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('添加设备成功')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('添加设备失败：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const PageAppBar(title: '校园网自助服务'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasError)
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage ?? '未知错误',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: clearError,
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  if (_isOnline && _userInfo != null) ...[
                    _buildUserInfoCard(
                      theme,
                      _userInfo!,
                      onLogout: _showLogoutDialog,
                    ),
                    const SizedBox(height: 16),
                    _buildMacListCard(theme),
                    if (_monthlyBills != null || _isLoadingBills) ...[
                      const SizedBox(height: 16),
                      NetMonthlyBillSection(
                        year: _selectedYear,
                        bills: _monthlyBills ?? [],
                        onYearChanged: (newYear) {
                          if (newYear < 1970 || newYear > DateTime.now().year) {
                            return;
                          }
                          setState(() {
                            _selectedYear = newYear;
                          });
                          _refreshBills();
                        },
                        isLoading: _isLoadingBills,
                      ),
                    ],
                  ],

                  if (_userInfo == null && (!_isOnline || hasError))
                    _buildLoginPromptCard(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPromptCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_open,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text('管理校园网账户', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '登录后，您可以在此查看校园网的账户余额、已绑定的设备和月度账单情况。',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _isLoadingLogin
                      ? null
                      : () => _showLoginDialog(NetServiceType.production),
                  icon: _isLoadingLogin
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('登录'),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoadingLogin
                        ? null
                        : () => _showLoginDialog(NetServiceType.mock),
                    icon: _isLoadingLogin
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.build_circle_outlined),
                    label: const Text('Mock 测试登录'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
    ThemeData theme,
    NetUserInfo info, {
    required VoidCallback onLogout,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text('校园网账户', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: _isRefreshingUser ? null : _refreshUserInfo,
                  icon: _isRefreshingUser
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    info.account,
                    style: theme.textTheme.headlineSmall,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _showLogoutDialog,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.swap_horiz),
                  label: const Text('切换'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  theme,
                  icon: Icons.account_balance_wallet,
                  label: '余额',
                  value: info.leftMoney ?? 'NaN',
                ),
                if (info.subscription.isNotEmpty)
                  _buildInfoChip(
                    theme,
                    icon: Icons.wifi,
                    label: '套餐',
                    value: info.subscription,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    );
  }

  Widget _buildMacListCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices_other,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text('已绑定设备', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: _isRefreshingDevices ? null : _refreshDevices,
                  icon: _isRefreshingDevices
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_macDevices == null)
              SizedBox(
                height: 80,
                child: Center(
                  child: Text('正在载入设备列表', style: theme.textTheme.bodyMedium),
                ),
              )
            else if (_macDevices!.isEmpty)
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    '未能加载设备列表\n或没有已绑定的设备',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _macDevices!.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final device = _macDevices![index];
                  return _buildMacListTile(theme, context, device);
                },
              ),
            // const SizedBox(height: 16),
            // if (_macDevices != null && _macDevices!.length < 3)
            //   Center(
            //     child: OutlinedButton.icon(
            //       onPressed: _showAddDeviceDialog,
            //       icon: const Icon(Icons.add),
            //       label: const Text('手动添加设备'),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacListTile(
    ThemeData theme,
    BuildContext context,
    MacDevice device,
  ) {
    final deviceMac = device.mac.toUpperCase();
    final deviceName = device.name.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.memory),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      deviceMac,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      iconSize: 14,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: deviceMac));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('所选设备的物理地址（MAC 地址）已复制到剪贴板'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.content_copy),
                    ),
                  ],
                ),
                Text(
                  deviceName.isNotEmpty ? deviceName : '未命名设备',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 24,
            padding: EdgeInsets.zero,
            color: theme.colorScheme.error,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            onPressed: () => _handleUnbindMac(device),
            icon: const Icon(Icons.link_off),
          ),
        ],
      ),
    );
  }
}
