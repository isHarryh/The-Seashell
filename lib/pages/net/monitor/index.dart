// Copyright (c) 2025, Harry Huang

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import '/types/net.dart';
import '/utils/app_bar.dart';
import '/utils/page_mixins.dart';

class NetMonitorPage extends StatefulWidget {
  const NetMonitorPage({super.key});

  @override
  State<NetMonitorPage> createState() => _NetMonitorPageState();
}

class _NetMonitorPageState extends State<NetMonitorPage>
    with PageStateMixin, LoadingStateMixin {
  final List<RealtimeUsage> _usageHistory = [];
  static const int _maxHistorySize = 60;
  static const Duration _requestInterval = Duration(seconds: 2);

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  NetworkStatus _gatewayStatus = NetworkStatus.noData;

  RealtimeUsage? get _currentUsage =>
      _usageHistory.isNotEmpty ? _usageHistory.last : null;

  @override
  void onServiceInit() {
    _startAutoRefresh();
  }

  @override
  void onServiceStatusChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      if (serviceProvider.netService.isOnline) {
        _loadRealtimeUsage();
      } else {
        setState(() {
          _usageHistory.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _loadRealtimeUsage();

    _refreshTimer = Timer.periodic(_requestInterval, (timer) {
      if (mounted) {
        _loadRealtimeUsage();
      }
    });
  }

  Future<void> _loadRealtimeUsage() async {
    setState(() => _isRefreshing = true);
    try {
      // Get the cached credentials
      final cachedNetData = serviceProvider.storeService
          .getCache<NetUserIntegratedData>(
            "net_account_data",
            NetUserIntegratedData.fromJson,
          );

      // Check if credentials are cached and username is not empty
      if (cachedNetData.isEmpty ||
          (cachedNetData.value?.account.isEmpty ?? true)) {
        // No cached credentials
        clearError();
        setState(() {
          _usageHistory.clear();
        });
        return;
      }

      final username = cachedNetData.value!.account;
      // by default do not use VPN route
      final usage = await serviceProvider.netService.getRealtimeUsage(
        username,
        viaVpn: false,
      );
      if (!mounted) return;

      // Check for billing cycle reset
      if (_currentUsage != null) {
        if (usage.v4 < _currentUsage!.v4 || usage.v6 < _currentUsage!.v6) {
          // Billing cycle reset detected, clear all history
          _usageHistory.clear();
        }
      }

      // Maintain and trim usage history
      _usageHistory.add(usage);
      if (_usageHistory.length > _maxHistorySize) {
        _usageHistory.removeAt(0);
      }

      // Update gateway status
      _gatewayStatus = NetworkStatus.connected;

      setState(() {
        // History already updated
      });
      clearError();
    } catch (e) {
      if (!mounted) return;

      // Update gateway status
      _gatewayStatus = NetworkStatus.disconnected;
      setState(() {});
      setError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  double? _getV4Speed() {
    if (_usageHistory.length < 2) return null;
    final lastIndex = _usageHistory.length - 1;
    final current = _usageHistory[lastIndex];
    final previous = _usageHistory[lastIndex - 1];

    final timeDiffSeconds =
        current.time.difference(previous.time).inMilliseconds / 1000;
    if (timeDiffSeconds <= 0) return null;

    final speed = (current.v4 - previous.v4) / timeDiffSeconds;
    return speed > 0 ? speed : 0;
  }

  double? _getV6Speed() {
    if (_usageHistory.length < 2) return null;
    final lastIndex = _usageHistory.length - 1;
    final current = _usageHistory[lastIndex];
    final previous = _usageHistory[lastIndex - 1];

    final timeDiffSeconds =
        current.time.difference(previous.time).inMilliseconds / 1000;
    if (timeDiffSeconds <= 0) return null;

    final speed = (current.v6 - previous.v6) / timeDiffSeconds;
    return speed > 0 ? speed : 0;
  }

  LineChartData _buildChartData() {
    if (_usageHistory.isEmpty) {
      return LineChartData(lineBarsData: []);
    }

    // Generate spots
    List<FlSpot> v4Spots = [];
    List<FlSpot> v6Spots = [];

    for (int i = 0; i < _usageHistory.length; i++) {
      final current = _usageHistory[i];

      if (i == 0) {
        // For the first point, use 0 as placeholder (will be filled later)
        v4Spots.add(FlSpot(i.toDouble(), 0));
        v6Spots.add(FlSpot(i.toDouble(), 0));
      } else {
        final previous = _usageHistory[i - 1];
        final timeDiffSeconds =
            current.time.difference(previous.time).inMilliseconds / 1000.0;

        if (timeDiffSeconds > 0) {
          final v4Speed =
              ((current.v4 - previous.v4) / timeDiffSeconds).clamp(
                    0,
                    double.infinity,
                  )
                  as double;
          final v6Speed =
              ((current.v6 - previous.v6) / timeDiffSeconds).clamp(
                    0,
                    double.infinity,
                  )
                  as double;

          v4Spots.add(FlSpot(i.toDouble(), v4Speed));
          v6Spots.add(FlSpot(i.toDouble(), v6Speed));
        } else {
          v4Spots.add(FlSpot(i.toDouble(), v4Spots.last.y));
          v6Spots.add(FlSpot(i.toDouble(), v6Spots.last.y));
        }
      }
    }

    // Fill the first point with the second point's value if available
    if (v4Spots.length > 1) {
      v4Spots[0] = FlSpot(0, v4Spots[1].y);
      v6Spots[0] = FlSpot(0, v6Spots[1].y);
    }

    // Calculate max Y value for chart
    final allY = [...v4Spots.map((e) => e.y), ...v6Spots.map((e) => e.y)];
    final maxY = allY.isEmpty
        ? 1.0
        : (allY.reduce((a, b) => a > b ? a : b) * 1.1).clamp(
            1.0,
            double.infinity,
          );

    return LineChartData(
      minX: 0,
      maxX: (_usageHistory.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        // IPv4 line (blue)
        LineChartBarData(
          spots: v4Spots,
          isCurved: false,
          color: Colors.blue,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
        // IPv6 line (purple)
        LineChartBarData(
          spots: v6Spots,
          isCurved: false,
          color: Colors.purple,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.purple.withOpacity(0.1),
          ),
        ),
      ],
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: null,
      ),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBorder: BorderSide(color: Colors.grey[400]!, width: 0.5),
          tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          getTooltipColor: (_) =>
              Theme.of(context).colorScheme.surfaceContainerHighest,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              String label = spot.barIndex == 0 ? 'IPv4' : 'IPv6';
              return LineTooltipItem(
                '$label: ${spot.y.toStringAsFixed(2)} MB/s',
                TextStyle(
                  color: spot.barIndex == 0 ? Colors.blue : Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: '流量监视'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('网络状态', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildNetworkStatusCard(),
            const SizedBox(height: 24),
            _buildRealtimeUsageCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeUsageCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('流量情况', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (_currentUsage == null && _isRefreshing)
          buildLoadingIndicator()
        else if (_currentUsage != null)
          _buildUsageContent()
        else
          _buildNoCredentialsWidget(),
        if (_usageHistory.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text('流量图表', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildHistoryChart(),
        ],
      ],
    );
  }

  Widget _buildHistoryChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('IPv4', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('IPv6', style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                _buildChartData(),
                key: ValueKey(_usageHistory.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCredentialsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.vpn_key_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '未检测到校园网账户',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请前往"自助服务"页面登录校园网账户',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Navigate to dashboard
                context.router.pushPath('/net/dashboard');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('前往自助服务'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageContent() {
    final usage = _currentUsage!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 600; // Breakpoint for horizontal layout

    final v4Speed = _getV4Speed();
    final v6Speed = _getV6Speed();

    if (isWideScreen) {
      // Wide screen: horizontal layout
      return Row(
        children: [
          Expanded(
            flex: 6,
            child: _buildUsageItem(
              label: 'IPv4 下行流量',
              value: usage.v4,
              icon: Icons.public,
              color: Colors.blue,
              speed: v4Speed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _buildUsageItem(
              label: 'IPv6 下行流量',
              value: usage.v6,
              icon: Icons.public,
              color: Colors.purple,
              speed: v6Speed,
            ),
          ),
        ],
      );
    } else {
      // Narrow screen: vertical layout
      return Column(
        children: [
          _buildUsageItem(
            label: 'IPv4 下行流量',
            value: usage.v4,
            icon: Icons.public,
            color: Colors.blue,
            speed: v4Speed,
          ),
          const SizedBox(height: 12),
          _buildUsageItem(
            label: 'IPv6 下行流量',
            value: usage.v6,
            icon: Icons.public,
            color: Colors.purple,
            speed: v6Speed,
          ),
        ],
      );
    }
  }

  Widget _buildNetworkStatusCard() {
    final status = _gatewayStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Local machine
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: status.color, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.laptop, color: status.color, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  '本机',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            // Connection line
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 3, color: status.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Gateway
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: status.color, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.router, color: status.color, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  '校园网网关',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    double? speed,
  }) {
    final valueMB = value.toStringAsFixed(1);
    final valueGB = (value / 1024).toStringAsFixed(1);
    final speedStr = speed != null ? speed.toStringAsFixed(2) : '--';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$valueMB MB',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$valueGB GB',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // Speed display on the right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  speedStr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MB/s',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
