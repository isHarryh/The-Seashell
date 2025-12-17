import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/provider.dart';
import '../../services/sync/sync_service.dart';
import '../../types/sync.dart';
import '../../utils/app_bar.dart';
import '../../utils/meta_info.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _isLoading = false;
  String? _error;
  ReleaseInfo? _releaseInfo;
  bool _expandOtherPlatforms = false;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _releaseInfo = null;
    });

    try {
      final info = await ServiceProvider.instance.syncService.getRelease();
      if (mounted) {
        setState(() {
          _releaseInfo = info;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatVersion(String version) {
    if (!version.startsWith('v')) {
      return 'v$version';
    }
    return version;
  }

  bool get _hasUpdate {
    if (_releaseInfo == null) return false;
    final currentVersion = MetaInfo.instance.appVersion;
    final latestVersion = _releaseInfo!.stableVersion;

    try {
      // Parse versions like "1.0.0" or "v1.0.0"
      final currentStr = currentVersion.split('+')[0].replaceFirst('v', '');
      final latestStr = latestVersion.replaceFirst('v', '');

      final currentParts = currentStr.split('.').map(int.parse).toList();
      final latestParts = latestStr.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final current = i < currentParts.length ? currentParts[i] : 0;
        final latest = i < latestParts.length ? latestParts[i] : 0;
        if (latest > current) return true;
        if (latest < current) return false;
      }
      return false;
    } catch (e) {
      return false; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(
        title: '更新',
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _isLoading ? null : _checkUpdate,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkUpdate,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildVersionInfo(),
            const SizedBox(height: 24),
            if (_hasUpdate) _buildDownloadLinks(),
            if (!_hasUpdate && _releaseInfo != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('当前已是最新版本'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '版本信息',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.devices, size: 18),
                    const SizedBox(width: 8),
                    const Text('当前版本：'),
                  ],
                ),
                Text(
                  _formatVersion(MetaInfo.instance.appVersion),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('最新版本：'),
                    ],
                  ),
                  Text(
                    '获取更新失败',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              )
            else if (_releaseInfo != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('最新版本：'),
                    ],
                  ),
                  Text(
                    _formatVersion(_releaseInfo!.stableVersion),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else if (_isLoading)
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_queue_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('最新版本：'),
                    ],
                  ),
                  Text('正在检查更新...'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadLinks() {
    if (_releaseInfo == null || _releaseInfo!.stableDownloads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('暂无可用下载源')),
      );
    }

    final currentPlatform = MetaInfo.instance.platformName.toLowerCase();
    final downloads = _releaseInfo!.stableDownloads;

    // Separate current platform from others
    final currentPlatformEntries = downloads.entries.where(
      (entry) => entry.key.toLowerCase() == currentPlatform,
    );
    final currentPlatformEntry = currentPlatformEntries.isNotEmpty
        ? currentPlatformEntries.first
        : null;
    final otherPlatforms = downloads.entries
        .where((entry) => entry.key.toLowerCase() != currentPlatform)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_for_offline,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              '可下载软件更新！',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Current platform (if available)
        if (currentPlatformEntry != null)
          ..._buildPlatformSection(
            currentPlatformEntry.key,
            currentPlatformEntry.value,
          ),
        // Other platforms in expandable section
        if (otherPlatforms.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 12.0),
            child: ExpansionTile(
              title: const Text('其他操作系统'),
              initiallyExpanded: _expandOtherPlatforms,
              onExpansionChanged: (expanded) {
                setState(() => _expandOtherPlatforms = expanded);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...otherPlatforms.expand<Widget>((platformEntry) {
                        final platform = platformEntry.key;
                        final sources = platformEntry.value;
                        final displayPlatformName = _releaseInfo!
                            .getDisplayPlatformName(platform);

                        return [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              displayPlatformName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ..._buildSourceCards(sources),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildPlatformSection(
    String platform,
    Map<String, String> sources,
  ) {
    final displayPlatformName = _releaseInfo!.getDisplayPlatformName(platform);

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          displayPlatformName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      ..._buildSourceCards(sources),
    ];
  }

  List<Widget> _buildSourceCards(Map<String, String> sources) {
    return sources.entries.map((sourceEntry) {
      final sourceName = sourceEntry.key;
      final downloadUrl = sourceEntry.value;
      final displayChannelName = _releaseInfo!.getDisplayDownloadChannelName(
        sourceName,
      );
      final displayChannelTip = _releaseInfo!.getDisplayDownloadChannelTip(
        sourceName,
      );

      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Icon(Icons.cloud_download_outlined, size: 28)],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayChannelName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_releaseInfo!.getIsRecommendedChannel(
                              sourceName,
                            )) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '推荐',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (displayChannelTip.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            displayChannelTip,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        tooltip: '复制链接',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: downloadUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('下载链接已复制')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, size: 20),
                        tooltip: '前往下载',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          final uri = Uri.parse(downloadUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('无法打开下载链接')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
