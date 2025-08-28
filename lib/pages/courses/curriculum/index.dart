import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';
import '/types/preferences.dart';
import '/utils/app_bar.dart';

class MajorPeriodInfo {
  final int id;
  final String name;
  final String startTime;
  final String endTime;

  MajorPeriodInfo(this.id, this.name, this.startTime, this.endTime);
}

class CurriculumPage extends StatefulWidget {
  const CurriculumPage({super.key});

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  List<ClassItem>? _allClasses;
  List<ClassPeriod>? _allPeriods;
  List<TermInfo>? _availableTerms;
  TermInfo? _currentTerm;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentWeek = 1;
  CurriculumSettings _settings = CurriculumSettings.defaultSettings;

  // 课表配置
  static const int maxWeeks = 20;
  static const List<String> dayNames = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);
    _loadCurriculum();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      setState(() {
        _loadCurriculum();
      });
    }
  }

  Future<void> _loadCurriculum() async {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      if (mounted) {
        setState(() {
          _allClasses = null;
          _allPeriods = null;
          _availableTerms = null;
          _currentTerm = null;
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
      final terms = await service.getTerms();

      if (terms.isEmpty) {
        throw Exception('No terms available');
      }

      TermInfo? selectedTerm;
      List<ClassItem>? classes;
      List<ClassPeriod>? periods;

      // Find first non-empty term
      for (final term in terms) {
        try {
          final futures = await Future.wait([
            service.getCurriculum(term),
            service.getCoursePeriods(term),
          ]);

          final termClasses = futures[0] as List<ClassItem>;
          final termPeriods = futures[1] as List<ClassPeriod>;

          if (termClasses.isNotEmpty) {
            selectedTerm = term;
            classes = termClasses;
            periods = termPeriods;
            break;
          }
        } catch (e) {
          continue;
        }
      }

      // Fallback
      if (selectedTerm == null) {
        selectedTerm = terms.first;
        classes = [];
        periods = [];
      }

      if (mounted) {
        setState(() {
          _allClasses = classes;
          _allPeriods = periods;
          _availableTerms = terms;
          _currentTerm = selectedTerm;
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

  Future<void> _refreshCurriculum() async {
    await _loadCurriculum();
  }

  Future<void> _loadCurriculumForTerm(TermInfo termInfo) async {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final futures = await Future.wait([
        service.getCurriculum(termInfo),
        service.getCoursePeriods(termInfo),
      ]);

      final classes = futures[0] as List<ClassItem>;
      final periods = futures[1] as List<ClassPeriod>;

      if (mounted) {
        setState(() {
          _allClasses = classes;
          _allPeriods = periods;
          _currentTerm = termInfo;
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
      appBar: PageAppBar(
        title: '课程表',
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.settings),
              tooltip: '课程表设置',
            ),
          ),
        ],
      ),
      body: _buildBody(),
      endDrawer: _buildSettingsDrawer(),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败: $_errorMessage',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCurriculum,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_allClasses == null || _allClasses!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '暂无课程数据',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCurriculum,
              child: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildWeekSelector(),
          const SizedBox(height: 16),
          Expanded(child: _buildCurriculumTable()),
        ],
      ),
    );
  }

  Widget _buildTermSelectorInDrawer() {
    if (_availableTerms == null || _availableTerms!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  '学年学期',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TermInfo>(
              value: _currentTerm,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              isExpanded: true,
              items: _availableTerms!.map((term) {
                return DropdownMenuItem<TermInfo>(
                  value: term,
                  child: Text('${term.year}学年 第${term.season}学期'),
                );
              }).toList(),
              onChanged: (TermInfo? newTerm) {
                if (newTerm != null && newTerm != _currentTerm) {
                  _loadCurriculumForTerm(newTerm);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: _currentWeek > 1 ? () => _changeWeek(-1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '第 $_currentWeek 周',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          onPressed: _currentWeek < maxWeeks ? () => _changeWeek(1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _refreshCurriculum,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, size: 18),
          label: Text(_isLoading ? '刷新中...' : '刷新'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _changeWeek(int delta) {
    setState(() {
      _currentWeek = (_currentWeek + delta).clamp(1, maxWeeks);
    });
  }

  Widget _buildCurriculumTable() {
    // 检查课时数据是否可用
    if (_allPeriods == null || _allPeriods!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              '课时数据未加载',
              style: TextStyle(fontSize: 18, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            const Text(
              '无法显示课表时间信息',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCurriculum,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    // 获取当前周的课程
    final weekClasses = _allClasses!
        .where((classItem) => classItem.weeks.contains(_currentWeek))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _buildTable(weekClasses, constraints.maxWidth),
          );
        } catch (e) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '课表构建失败: $e',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCurriculum,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildTable(List<ClassItem> weekClasses, double availableWidth) {
    // 获取可用的课时数据并按大节分组
    final periods = _allPeriods ?? [];
    final majorPeriods = _getMajorPeriods(periods);

    // 根据设置和课程数据计算实际显示的天数
    final courseDays = weekClasses.map((c) => c.day).toSet().toList();
    final displayDays = _settings.calculateDisplayDays(courseDays);

    final dayColumnWidth = (availableWidth - 2) / (displayDays + 1);

    return Container(
      width: availableWidth,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Table(
        columnWidths: {
          for (int i = 0; i <= displayDays; i++)
            i: FixedColumnWidth(dayColumnWidth),
        },
        children: [
          // 表头
          TableRow(
            children: [
              _buildHeaderCell('时间'),
              for (int day = 1; day <= displayDays; day++)
                _buildHeaderCell('周${dayNames[day - 1]}'),
            ],
          ),
          // 数据行
          for (final majorPeriod in majorPeriods)
            TableRow(
              children: [
                _buildMajorTimeCell(majorPeriod),
                for (int day = 1; day <= displayDays; day++)
                  _buildMajorClassCell(weekClasses, day, majorPeriod),
              ],
            ),
        ],
      ),
    );
  }

  // 从课时数据中提取大节信息
  List<MajorPeriodInfo> _getMajorPeriods(List<ClassPeriod> periods) {
    if (periods.isEmpty) {
      throw StateError('课时数据为空，无法显示课表。请检查网络连接或联系管理员。');
    }

    final majorPeriodsMap = <int, List<ClassPeriod>>{};

    for (final period in periods) {
      final majorId = period.majorId;
      majorPeriodsMap.putIfAbsent(majorId, () => []).add(period);
    }

    final majorPeriodsList = <MajorPeriodInfo>[];

    for (final entry in majorPeriodsMap.entries) {
      final majorId = entry.key;
      final periodsInMajor = entry.value;

      if (periodsInMajor.isEmpty) continue;

      final majorName = periodsInMajor.first.majorName;

      String majorStartTime = '';
      String majorEndTime = '';

      for (final period in periodsInMajor) {
        if (period.majorStartTime != null &&
            period.majorStartTime!.isNotEmpty) {
          majorStartTime = period.majorStartTime!;
          break;
        }
      }

      for (final period in periodsInMajor) {
        if (period.majorEndTime != null && period.majorEndTime!.isNotEmpty) {
          majorEndTime = period.majorEndTime!;
          break;
        }
      }

      if (majorStartTime.isEmpty) {
        periodsInMajor.sort((a, b) => a.minorId.compareTo(b.minorId));
        majorStartTime = periodsInMajor.first.minorStartTime;
      }

      if (majorEndTime.isEmpty) {
        periodsInMajor.sort((a, b) => b.minorId.compareTo(a.minorId));
        majorEndTime = periodsInMajor.first.minorEndTime;
      }

      if (majorStartTime.isEmpty || majorEndTime.isEmpty) {
        throw StateError('大节 $majorId ($majorName) 的时间数据不完整');
      }

      majorPeriodsList.add(
        MajorPeriodInfo(majorId, majorName, majorStartTime, majorEndTime),
      );
    }

    majorPeriodsList.sort((a, b) => a.id.compareTo(b.id));

    if (majorPeriodsList.isEmpty) {
      throw StateError('未能从课时数据中提取到有效的大节信息');
    }

    return majorPeriodsList;
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMajorTimeCell(MajorPeriodInfo majorPeriod) {
    final cellHeight = _settings.tableSize.height;
    return Container(
      height: cellHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            majorPeriod.startTime,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            '${majorPeriod.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            majorPeriod.endTime,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMajorClassCell(
    List<ClassItem> weekClasses,
    int day,
    MajorPeriodInfo majorPeriod,
  ) {
    final classesInSlot = weekClasses.where((classItem) {
      return classItem.day == day && classItem.period == majorPeriod.id;
    }).toList();

    final cellHeight = _settings.tableSize.height;
    return Container(
      height: cellHeight,
      decoration: BoxDecoration(
        color: classesInSlot.isEmpty
            ? Colors.white
            : _getClassColor(classesInSlot.first),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: classesInSlot.isEmpty
          ? const SizedBox.expand() // 空单元格也填充满整个区域
          : _buildClassContent(classesInSlot),
    );
  }

  Widget _buildClassContent(List<ClassItem> classesInSlot) {
    final firstClass = classesInSlot.first;

    return InkWell(
      onTap: () => _showClassDetails(firstClass),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  firstClass.className,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (firstClass.teacherName.isNotEmpty)
              Text(
                firstClass.teacherName,
                style: const TextStyle(fontSize: 10, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            if (firstClass.locationName.isNotEmpty)
              Text(
                firstClass.locationName,
                style: const TextStyle(fontSize: 9, color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (classesInSlot.length > 1)
              Text(
                '+${classesInSlot.length - 1}',
                style: const TextStyle(fontSize: 9, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }

  Color _getClassColor(ClassItem classItem) {
    final hash = classItem.className.hashCode;
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.brown.shade400,
    ];
    return colors[hash.abs() % colors.length];
  }

  void _showClassDetails(ClassItem classItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(classItem.className),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('教师: ${classItem.teacherName}'),
            Text('地点: ${classItem.locationName}'),
            Text('周次: ${classItem.weeksText}'),
            Text('节次: 第${classItem.period}大节'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 构建设置抽屉
  Widget _buildSettingsDrawer() {
    return Drawer(
      child: Column(
        children: [
          // 抽屉头部
          DrawerHeader(
            child: const Row(
              children: [
                Icon(Icons.settings, size: 24),
                SizedBox(width: 8),
                Text(
                  '课程表设置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // 设置项
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTermSelectorInDrawer(),
                const SizedBox(height: 16),
                _buildWeekendDisplaySetting(),
                const SizedBox(height: 16),
                _buildTableSizeSetting(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建周末显示设置
  Widget _buildWeekendDisplaySetting() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '显示周末',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<WeekendDisplayMode>(
                initialValue: _settings.weekendMode,
                items: WeekendDisplayMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.displayName),
                  );
                }).toList(),
                onChanged: (WeekendDisplayMode? newMode) {
                  if (newMode != null) {
                    setState(() {
                      _settings = _settings.copyWith(weekendMode: newMode);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建表格尺寸设置
  Widget _buildTableSizeSetting() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '表格尺寸',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<TableSize>(
                initialValue: _settings.tableSize,
                items: TableSize.values.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size.displayName),
                  );
                }).toList(),
                onChanged: (TableSize? newSize) {
                  if (newSize != null) {
                    setState(() {
                      _settings = _settings.copyWith(tableSize: newSize);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
