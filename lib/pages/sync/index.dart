import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/services/sync/exceptions.dart';
import '/types/sync.dart';
import '/utils/app_bar.dart';
import 'pairing.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  SyncDeviceData? _syncData;
  String? _errorMessage;
  ButtonStyleButton? _errorAction;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceProviderChanged);
    _ensureRegisterDevice();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceProviderChanged);
    super.dispose();
  }

  void _onServiceProviderChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _errorMessage = null;
            _errorAction = null;
            _syncData = null;
          });
          _ensureRegisterDevice();
        }
      });
    }
  }

  void _handleError(dynamic error) {
    if (!mounted) return;

    String message;
    ButtonStyleButton? action;

    if (error is SyncServiceException) {
      if (error.errorCode != null) {
        message = getSyncErrorMessage(error.errorCode);
        final code = error.errorCode!;

        if (code >= 10101 && code <= 10104) {
          // Reset device ID
          action = _createErrorActionButton(
            label: '重置设备',
            onPressed: () async {
              final isMock =
                  _serviceProvider.currentSyncServiceType ==
                  SyncServiceType.mock;
              final cacheKey = isMock ? 'sync_device_mock' : 'sync_device';
              _serviceProvider.storeService.delStore(cacheKey);
              await _ensureRegisterDevice();

              setState(() {
                _errorMessage = null;
                _errorAction = null;
                _syncData = null;
              });
            },
          );
        } else if (code >= 10111 && code <= 10115 || code == 10117) {
          // Reset group ID
          action = _createErrorActionButton(
            label: '重置同步组',
            onPressed: () async {
              if (_syncData != null) {
                final resetData = SyncDeviceData(
                  deviceId: _syncData!.deviceId,
                  deviceOs: _syncData!.deviceOs,
                  deviceName: _syncData!.deviceName,
                  groupId: null,
                );
                await _saveSyncData(resetData);

                setState(() {
                  _errorMessage = null;
                  _errorAction = null;
                });
              }
            },
          );
        } else if (code == 10202) {
          // Retry login
          action = _createErrorActionButton(
            label: '重新登录',
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _errorAction = null;
              });
              context.router.pushPath('/courses/account');
            },
          );
        }
      } else {
        message = error.message;
      }
    } else {
      message = error.toString();
    }

    setState(() {
      _errorMessage = message;
      _errorAction = action;
    });
  }

  ButtonStyleButton _createErrorActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.build_outlined, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  Future<void> _saveSyncData(SyncDeviceData data) async {
    final isMock =
        _serviceProvider.currentSyncServiceType == SyncServiceType.mock;
    final cacheKey = isMock ? 'sync_device_mock' : 'sync_device';

    _serviceProvider.storeService.putStore<SyncDeviceData>(cacheKey, data);
    if (mounted) {
      setState(() => _syncData = data);
    }
  }

  Future<void> _ensureRegisterDevice() async {
    final isMock =
        _serviceProvider.currentSyncServiceType == SyncServiceType.mock;
    final cacheKey = isMock ? 'sync_device_mock' : 'sync_device';

    // Check if device data exists in cache
    final cachedData = _serviceProvider.storeService.getStore<SyncDeviceData>(
      cacheKey,
      SyncDeviceData.fromJson,
    );

    if (cachedData != null) {
      // Device already registered, load the data
      if (mounted) {
        setState(() => _syncData = cachedData);
      }
      return;
    }

    // Device not registered, register automatically
    try {
      final deviceOs = _getCurrentDeviceOs();
      final deviceName = await _getDeviceName();

      final deviceId = await _serviceProvider.syncService.registerDevice(
        deviceOs: deviceOs,
        deviceName: deviceName,
      );

      final deviceData = SyncDeviceData(
        deviceId: deviceId,
        deviceOs: deviceOs,
        deviceName: deviceName,
      );

      await _saveSyncData(deviceData);
    } catch (e) {
      _handleError(e);
    }
  }

  String _getCurrentDeviceOs() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'mac';
    if (Platform.isLinux) return 'linux';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  Future<String> _getDeviceName() async {
    // Simple device name, can be enhanced later
    final os = _getCurrentDeviceOs();
    return '$os-device-${DateTime.now().millisecondsSinceEpoch % 10000}';
  }

  String _getDeviceOsIcon(String os) {
    switch (os.toLowerCase()) {
      case 'windows':
        return '🪟';
      case 'mac':
        return '🍎';
      case 'linux':
        return '🐧';
      case 'ios':
        return '📱';
      case 'android':
        return '🤖';
      default:
        return '💻';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: '跨设备同步'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            _buildErrorCard(),
            const SizedBox(height: 16),
          ],
          if (_syncData?.deviceId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '将你的多个设备加入到一个同步组内，即可跨设备同步账号和数据，省去繁琐重复的操作！',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SyncPairingCard(
              serviceProvider: _serviceProvider,
              onSyncDataChanged: _saveSyncData,
              onSuccess: () => {
                if (mounted)
                  setState(() {
                    _errorMessage = null;
                    _errorAction = null;
                  }),
              },
              onError: _handleError,
            ),
          ],
          if (kDebugMode) ...[const SizedBox(height: 16), _buildDebugSection()],
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return AnimatedOpacity(
      opacity: _errorMessage != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: _errorMessage != null ? Offset.zero : const Offset(0, -0.1),
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.errorContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.15),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '出现错误',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
                                      .withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_errorAction != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorActionButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorActionButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onError.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '找到了一个也许可以修复此问题的办法：',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onErrorContainer.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _errorAction!,
        ],
      ),
    );
  }

  Widget _buildDebugSection() {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '调试信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: null),
            Row(
              children: [
                Text(
                  '服务环境',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<SyncServiceType>(
                    segments: const [
                      ButtonSegment(
                        value: SyncServiceType.mock,
                        label: Text('Mock'),
                        icon: Icon(Icons.code, size: 16),
                      ),
                      ButtonSegment(
                        value: SyncServiceType.production,
                        label: Text('Production'),
                        icon: Icon(Icons.cloud, size: 16),
                      ),
                    ],
                    selected: {_serviceProvider.currentSyncServiceType},
                    onSelectionChanged: (Set<SyncServiceType> selected) {
                      _serviceProvider.switchSyncService(selected.first);
                    },
                  ),
                ),
              ],
            ),
            if (_syncData?.deviceId != null) ...[
              const SizedBox(height: 16),
              _buildDebugInfoRow(
                '设备类型',
                '${_getDeviceOsIcon(_syncData!.deviceOs!)} ${_syncData!.deviceOs}',
                icon: Icons.computer,
              ),
              _buildDebugInfoRow(
                '设备名称',
                _syncData!.deviceName ?? '未知',
                icon: Icons.label,
              ),
              _buildDebugInfoRow(
                '设备ID',
                _syncData!.deviceId!,
                icon: Icons.fingerprint,
                monospace: true,
              ),
            ],
            if (_syncData?.groupId != null) ...[
              _buildDebugInfoRow(
                '组ID',
                _syncData!.groupId!,
                icon: Icons.groups,
                monospace: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfoRow(
    String label,
    String value, {
    IconData? icon,
    bool monospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon != null ? 60 : 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontSize: monospace ? 11 : null,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
