import 'package:flutter/material.dart';

import '/types/net.dart';

class NetMonthlyBillSection extends StatelessWidget {
  const NetMonthlyBillSection({
    super.key,
    required this.year,
    required this.bills,
    required this.onYearChanged,
    required this.isLoading,
  });

  final int year;
  final List<MonthlyBill> bills;
  final ValueChanged<int> onYearChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text('月度账单', style: theme.textTheme.titleLarge),
                if (isLoading) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: isLoading ? null : () => onYearChanged(year - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$year 年', style: theme.textTheme.titleMedium),
                IconButton(
                  onPressed: isLoading ? null : () => onYearChanged(year + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (bills.isEmpty)
              SizedBox(
                height: 120,
                child: Center(
                  child: isLoading
                      ? Text('正在载入月度账单', style: theme.textTheme.bodyMedium)
                      : Text(
                          '未能载入账单\n或所选时间没有账单',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                ),
              )
            else ...[
              _buildBillTable(theme),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '移动端左右滑动即可查看\n桌面端使用 Shift + 鼠标滚轮查看',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillTable(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        columns: const [
          DataColumn(label: Text('开始日期')),
          DataColumn(label: Text('结束日期')),
          DataColumn(label: Text('套餐')),
          DataColumn(label: Text('基本月租(元)')),
          DataColumn(label: Text('时长/流量计费(元)')),
          DataColumn(label: Text('使用时长(分钟)')),
          DataColumn(label: Text('使用流量(MB)')),
          DataColumn(label: Text('出账时间')),
        ],
        rows: bills
            .map(
              (bill) => DataRow(
                cells: [
                  DataCell(Text(_formatDate(bill.startDate))),
                  DataCell(Text(_formatDate(bill.endDate))),
                  DataCell(
                    Text(bill.packageName.isEmpty ? '-' : bill.packageName),
                  ),
                  DataCell(Text(_formatCurrency(bill.monthlyFee))),
                  DataCell(Text(_formatCurrency(bill.usageFee))),
                  DataCell(Text(_formatNumber(bill.usageDurationMinutes, 0))),
                  DataCell(Text(_formatNumber(bill.usageFlowMb, 3))),
                  DataCell(Text(_formatDateTime(bill.createTime))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  String _formatNumber(double value, int fractionDigits) {
    return value.toStringAsFixed(fractionDigits);
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
