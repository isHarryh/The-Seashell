import 'package:flutter/foundation.dart';
import '/services/net/exceptions.dart';
import '/types/net.dart';

extension LoginRequirementsExtension on LoginRequirements {
  static final RegExp checkCodeRegex = RegExp(
    r'var\s*checkcode\s*=\s*"(\w+)"',
    caseSensitive: false,
  );
  static final RegExp tryTimesRegex = RegExp(
    r'var\s*trytimes\s*=\s*"(\w+|null)"',
    caseSensitive: false,
  );
  static final RegExp tryTimesThresholdRegex = RegExp(
    r'if\s*\(parseInt\(trytimes\)\s*>=\s*(\d+)\s*\)',
    caseSensitive: false,
  );

  static LoginRequirements parse(String html) {
    final checkCodeMatch = checkCodeRegex.firstMatch(html);
    final tryTimesMatch = tryTimesRegex.firstMatch(html);
    final tryTimesThresholdMatch = tryTimesThresholdRegex.firstMatch(html);

    final checkCode = checkCodeMatch?.group(1)?.trim();

    if (checkCode == null || checkCode.isEmpty) {
      throw const NetServiceException('Failed to parse default check code');
    }

    final tryTimesStr = tryTimesMatch?.group(1)?.trim() ?? '0';
    final tryTimesThresholdStr =
        tryTimesThresholdMatch?.group(1)?.trim() ?? '3';

    final tryTimes = int.tryParse(tryTimesStr) ?? 0;
    final tryTimesThreshold = int.tryParse(tryTimesThresholdStr) ?? 3;

    return LoginRequirements(
      checkCode: checkCode,
      tryTimes: tryTimes,
      tryTimesThreshold: tryTimesThreshold,
    );
  }
}

extension NetUserInfoExtension on NetUserInfo {
  static NetUserInfo parse(Map<String, dynamic> data) {
    return NetUserInfo(
      account: data['welcome'] ?? '',
      subscription: data['service'] ?? '',
      status: data['status'] ?? '',
      leftFlow: data['leftFlow'],
      leftTime: data['leftTime'],
      leftMoney: data['leftmoeny'],
      overDate: data['overdate'],
      onlineState: data['onlinestate'],
    );
  }
}

extension MacDeviceExtension on MacDevice {
  static final nameAndMacRegExp = RegExp(
    r'<input[^>]*type\s*=\s*"text"[^>]*value\s*=\s*"([^"]*)"',
    caseSensitive: false,
  );
  static final macRegExp = RegExp(
    r'<input[^>]*name\s*=\s*"macs"[^>]*value\s*=\s*"([^"]+)"',
    caseSensitive: false,
  );

  static List<MacDevice> parse(String html) {
    final deviceNames = <String>[];
    for (final match in nameAndMacRegExp.allMatches(html)) {
      final fullTag = match.group(0) ?? '';
      if (macRegExp.hasMatch(fullTag)) {
        continue;
      }
      deviceNames.add((match.group(1) ?? '').trim());
    }

    final devices = <MacDevice>[];
    var index = 0;
    for (final match in macRegExp.allMatches(html)) {
      final macValue = match.group(1) ?? '';
      final name = index < deviceNames.length ? deviceNames[index] : '';
      devices.add(MacDevice(name: name, mac: macValue));
      index++;
    }

    return devices;
  }
}

extension MonthlyBillExtension on MonthlyBill {
  static final tbodyRegExp = RegExp(
    r'<tbody[^>]*>(.*?)</tbody>',
    caseSensitive: false,
    dotAll: true,
  );
  static final rowRegExp = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  );
  static final cellRegExp = RegExp(
    r'<td[^>]*>(.*?)</td>',
    caseSensitive: false,
    dotAll: true,
  );

  static List<MonthlyBill> parse(String html, int year) {
    // Match tbody
    final tbodyMatch = tbodyRegExp.firstMatch(html);

    if (tbodyMatch == null) {
      return const [];
    }

    // Match table rows
    final tbodyContent = tbodyMatch.group(1) ?? '';
    final rowMatches = rowRegExp.allMatches(tbodyContent);

    final bills = <MonthlyBill>[];

    for (final row in rowMatches) {
      final cells = cellRegExp
          .allMatches(row.group(1) ?? '')
          .map((cell) => _normalizeCell(cell.group(1) ?? ''))
          .toList();

      if (cells.length != 8) {
        continue;
      }

      try {
        final startDate = DateTime.parse(cells[0]);
        final endDate = DateTime.parse(cells[1]);
        final packageName = cells[2];
        final monthlyFee = _parseNumeric(cells[3]);
        final usageFee = _parseNumeric(cells[4]);
        final durationMinutes = _parseNumeric(cells[5]);
        final flowMb = _parseNumeric(cells[6]);
        final createTime = DateTime.parse(cells[7]);

        bills.add(
          MonthlyBill(
            startDate: startDate,
            endDate: endDate,
            packageName: packageName,
            monthlyFee: monthlyFee,
            usageFee: usageFee,
            usageDurationMinutes: durationMinutes,
            usageFlowMb: flowMb,
            createTime: createTime,
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to parse monthly bill row: $e');
        }
      }
    }

    return bills;
  }

  static String _normalizeCell(String input) {
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutTags.replaceAll('&nbsp;', ' ').trim();
  }

  static double _parseNumeric(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9\.-]'), '');
    if (cleaned.isEmpty) {
      return 0;
    }
    return double.tryParse(cleaned) ?? 0;
  }
}

extension RealtimeUsageExtension on RealtimeUsage {
  static final v4Regex = RegExp(r'"v4"\s*:\s*([\d.]+)', caseSensitive: false);
  static final v6Regex = RegExp(r'"v6"\s*:\s*([\d.]+)', caseSensitive: false);

  static RealtimeUsage parse(String jsStr) {
    final v4Match = v4Regex.firstMatch(jsStr);
    final v6Match = v6Regex.firstMatch(jsStr);

    final v4Str = v4Match?.group(1)?.trim();
    final v6Str = v6Match?.group(1)?.trim();

    if (v4Str == null || v4Str.isEmpty) {
      throw const NetServiceException('Failed to parse v4 usage');
    }
    if (v6Str == null || v6Str.isEmpty) {
      throw const NetServiceException('Failed to parse v6 usage');
    }

    final v4 = double.tryParse(v4Str);
    final v6 = double.tryParse(v6Str);

    if (v4 == null || v6 == null) {
      throw const NetServiceException('Failed to parse usage values');
    }

    return RealtimeUsage(v4: v4, v6: v6, time: DateTime.now());
  }
}
