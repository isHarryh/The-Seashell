import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';

class GradePage extends StatefulWidget {
  const GradePage({super.key});

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;
  List<CourseGradeItem>? _grades;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);
    _loadGrades();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      setState(() {
        _loadGrades();
      });
    }
  }

  Future<void> _loadGrades() async {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      if (mounted) {
        setState(() {
          _grades = null;
          _errorMessage = null;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final grades = await service.getGrades();
      if (mounted) {
        setState(() {
          _grades = grades;
          _isLoading = false;
          _lastRefreshTime = DateTime.now();
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

  Future<void> _refreshGrades() async {
    await _loadGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成绩查询')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('请先登录', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载成绩...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refreshGrades, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_grades == null || _grades!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无成绩数据', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildActionBar(),
          const SizedBox(height: 16),
          Expanded(child: _buildResponsiveTable()),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    final service = _serviceProvider.coursesService;

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: (service.isOnline && !_isLoading) ? _refreshGrades : null,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 18),
          label: Text(_isLoading ? '刷新中...' : '刷新'),
        ),
        const SizedBox(width: 16),
        if (_lastRefreshTime != null)
          Text(
            '上次刷新: ${_formatTime(_lastRefreshTime!)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        const Spacer(),
        // 预留位置给未来的按钮组
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildResponsiveTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // 定义列的配置
        final columnConfig = [
          {'name': '学期', 'minWidth': 80.0, 'flex': 2, 'isNumeric': false},
          {'name': '开课院系', 'minWidth': 80.0, 'flex': 2, 'isNumeric': false},
          {'name': '课程代码', 'minWidth': 80.0, 'flex': 2, 'isNumeric': false},
          {'name': '课程名称', 'minWidth': 100.0, 'flex': 4, 'isNumeric': false},
          {'name': '课程性质', 'minWidth': 80.0, 'flex': 1, 'isNumeric': false},
          {'name': '课程类别', 'minWidth': 80.0, 'flex': 1, 'isNumeric': false},
          {'name': '补考标记', 'minWidth': 80.0, 'flex': 1, 'isNumeric': false},
          {'name': '考核方式', 'minWidth': 80.0, 'flex': 1, 'isNumeric': false},
          {'name': '学时', 'minWidth': 60.0, 'flex': 1, 'isNumeric': true},
          {'name': '学分', 'minWidth': 60.0, 'flex': 1, 'isNumeric': true},
          {'name': '成绩', 'minWidth': 60.0, 'flex': 1, 'isNumeric': true},
        ];

        // 计算总的最小宽度和权重
        final totalMinWidth = columnConfig.fold<double>(
          0,
          (sum, col) => sum + (col['minWidth'] as double),
        );
        final totalFlex = columnConfig.fold<int>(
          0,
          (sum, col) => sum + (col['flex'] as int),
        );

        // 决定是否需要水平滚动
        final needsHorizontalScroll = availableWidth < totalMinWidth;

        Widget table;
        if (needsHorizontalScroll) {
          // 使用最小宽度
          final columnWidths = columnConfig
              .map((col) => col['minWidth'] as double)
              .toList();
          table = _buildFixedWidthTable(
            columnConfig,
            columnWidths,
            totalMinWidth,
          );
        } else {
          // 按比例分配可用宽度
          final extraWidth = availableWidth - totalMinWidth;
          final columnWidths = columnConfig.map((col) {
            final minWidth = col['minWidth'] as double;
            final flex = col['flex'] as int;
            final extraForThisColumn = extraWidth * (flex / totalFlex);
            return minWidth + extraForThisColumn;
          }).toList();
          table = _buildFixedWidthTable(
            columnConfig,
            columnWidths,
            availableWidth,
          );
        }

        // 总是包装在水平滚动中，以防止溢出
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: table,
          ),
        );
      },
    );
  }

  Widget _buildFixedWidthTable(
    List<Map<String, Object>> columnConfig,
    List<double> columnWidths,
    double tableWidth,
  ) {
    return Container(
      width: tableWidth,
      child: Column(
        children: [
          // 表头
          Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: columnConfig.asMap().entries.map((entry) {
                final index = entry.key;
                final column = entry.value;
                return _buildHeaderCell(
                  column['name'] as String,
                  columnWidths[index],
                  isNumeric: column['isNumeric'] as bool,
                );
              }).toList(),
            ),
          ),
          // 数据行
          ..._grades!.asMap().entries.map((entry) {
            final index = entry.key;
            final grade = entry.value;
            final isEven = index % 2 == 0;

            return Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: isEven
                    ? null
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(children: _buildDataRow(grade, columnWidths)),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildDataRow(CourseGradeItem grade, List<double> columnWidths) {
    return [
      _buildDataCell(_buildTermCell(grade), columnWidths[0]),
      _buildDataCell(_buildSchoolCell(grade), columnWidths[1]),
      _buildDataCell(
        Text(grade.courseId, style: const TextStyle(fontSize: 14)),
        columnWidths[2],
      ),
      _buildDataCell(_buildCourseNameCell(grade), columnWidths[3]),
      _buildDataCell(
        Text(grade.type, style: const TextStyle(fontSize: 14)),
        columnWidths[4],
      ),
      _buildDataCell(
        Text(grade.category, style: const TextStyle(fontSize: 14)),
        columnWidths[5],
      ),
      _buildDataCell(_buildMakeupStatusCell(grade), columnWidths[6]),
      _buildDataCell(
        Text(grade.examType ?? '-', style: const TextStyle(fontSize: 14)),
        columnWidths[7],
      ),
      _buildDataCell(
        Text(grade.hours.toString()),
        columnWidths[8],
        isNumeric: true,
      ),
      _buildDataCell(
        Text(grade.credit.toString()),
        columnWidths[9],
        isNumeric: true,
      ),
      _buildDataCell(
        Text(
          grade.score.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: grade.score >= 60 ? Colors.green : Colors.red,
          ),
        ),
        columnWidths[10],
        isNumeric: true,
      ),
    ];
  }

  Widget _buildHeaderCell(String text, double width, {bool isNumeric = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: isNumeric ? TextAlign.center : TextAlign.left,
        maxLines: 2,
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width, {bool isNumeric = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isNumeric ? Alignment.center : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _buildTermCell(CourseGradeItem grade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          grade.termName,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (grade.termNameAlt.isNotEmpty)
          Text(
            grade.termNameAlt,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }

  Widget _buildSchoolCell(CourseGradeItem grade) {
    if (grade.schoolName == null && grade.schoolNameAlt == null) {
      return const Text('-');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (grade.schoolName != null)
          Text(
            grade.schoolName!,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        if (grade.schoolNameAlt != null && grade.schoolNameAlt!.isNotEmpty)
          Text(
            grade.schoolNameAlt!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }

  Widget _buildCourseNameCell(CourseGradeItem grade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          grade.courseName,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (grade.courseNameAlt != null && grade.courseNameAlt!.isNotEmpty)
          Text(
            grade.courseNameAlt!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }

  Widget _buildMakeupStatusCell(CourseGradeItem grade) {
    if (grade.makeupStatus == null && grade.makeupStatusAlt == null) {
      return const Text('-');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (grade.makeupStatus != null)
          Text(
            grade.makeupStatus!,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        if (grade.makeupStatusAlt != null && grade.makeupStatusAlt!.isNotEmpty)
          Text(
            grade.makeupStatusAlt!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
    );
  }
}
