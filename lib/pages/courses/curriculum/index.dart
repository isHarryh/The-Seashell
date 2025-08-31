import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';
import '/types/preferences.dart';
import '/utils/app_bar.dart';
import 'common.dart';

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

  CurriculumIntegratedData? _curriculumData;
  String? _errorMessage;
  int _currentWeek = 1;

  static const int maxWeeks = 50;
  static const List<String> dayNames = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  void initState() {
    super.initState();
    _serviceProvider.addListener(_onServiceStatusChanged);
    _loadCurriculumFromCacheOrService();
  }

  @override
  void dispose() {
    _serviceProvider.removeListener(_onServiceStatusChanged);
    super.dispose();
  }

  CurriculumSettings getSettings() {
    final cached = _serviceProvider.storeService.getPref<CurriculumSettings>(
      "curriculum",
      CurriculumSettings.fromJson,
    );
    return cached ?? CurriculumSettings.defaultSettings;
  }

  void saveSettings(CurriculumSettings settings) {
    _serviceProvider.storeService.putPref<CurriculumSettings>(
      "curriculum",
      settings,
    );
  }

  bool get isActivated => getSettings().activated;

  void setActivated(bool activated) {
    final settings = getSettings();
    final newSettings = CurriculumSettings(
      weekendMode: settings.weekendMode,
      tableSize: settings.tableSize,
      activated: activated,
    );
    saveSettings(newSettings);
  }

  void _onServiceStatusChanged() {
    if (mounted) {
      setState(() {
        _loadCurriculumFromCacheOrService();
      });
    }
  }

  Future<void> _loadCurriculumFromCacheOrService() async {
    final cachedData = _serviceProvider.storeService
        .getCache<CurriculumIntegratedData>(
          "curriculum_data",
          CurriculumIntegratedData.fromJson,
        );

    if (cachedData.isNotEmpty) {
      if (mounted) {
        setState(() {
          _curriculumData = cachedData.value;
          _errorMessage = null;
          _adjustCurrentWeek();
        });
      }
      return;
    }

    final service = _serviceProvider.coursesService;
    if (!service.isOnline) {
      if (mounted) {
        setState(() {
          _curriculumData = null;
          _errorMessage = null;
        });
      }
      return;
    }
  }

  Future<void> _loadCurriculumForTerm(TermInfo termInfo) async {
    final service = _serviceProvider.coursesService;

    if (!service.isOnline) {
      return;
    }

    try {
      final futures = await Future.wait([
        service.getCurriculum(termInfo),
        service.getCoursePeriods(termInfo),
        service.getCalendarDays(termInfo).catchError((e) => <CalendarDay>[]),
      ]);

      final classes = futures[0] as List<ClassItem>;
      final periods = futures[1] as List<ClassPeriod>;
      final calendarDays = futures[2] as List<CalendarDay>;

      final integratedData = CurriculumIntegratedData(
        currentTerm: termInfo,
        allClasses: classes,
        allPeriods: periods,
        calendarDays: calendarDays.isEmpty ? null : calendarDays,
      );

      _serviceProvider.storeService.putCache<CurriculumIntegratedData>(
        "curriculum_data",
        integratedData,
      );

      // Set activated to true when loading new data
      setActivated(true);

      if (mounted) {
        setState(() {
          _curriculumData = integratedData;
          _adjustCurrentWeek();
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
    // 如果有错误信息，显示错误页面
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
              onPressed: _refreshCurriculumData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final cachedData = _serviceProvider.storeService
        .getCache<CurriculumIntegratedData>(
          "curriculum_data",
          CurriculumIntegratedData.fromJson,
        );

    if (cachedData.isNotEmpty) {
      final data = cachedData.value!;
      // Check activated status from settings
      if (isActivated) {
        if (mounted && _curriculumData != data) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _curriculumData = data;
              _adjustCurrentWeek();
            });
          });
        }
        return _buildCurriculumView();
      } else {
        // not activated
        return _buildSelectionView(cachedData);
      }
    } else {
      if (!_serviceProvider.coursesService.isOnline) {
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

      return _buildSelectionView(null);
    }
  }

  Widget _buildSelectionView(cachedData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool shouldUseDoubleColumn = constraints.maxWidth > 1000;

          if (shouldUseDoubleColumn &&
              cachedData != null &&
              cachedData.isNotEmpty) {
            // Two column layout
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChooseLatestCard(
                        isLoggedIn: _serviceProvider.coursesService.isOnline,
                        getTerms: () =>
                            _serviceProvider.coursesService.getTerms(),
                        onTermSelected: _loadCurriculumForTerm,
                        useFlexLayout: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChooseCacheCard(
                        cachedData: cachedData,
                        onSubmit: _activateAndViewCachedData,
                        useFlexLayout: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Single column layout
            return Column(
              children: [
                ChooseLatestCard(
                  isLoggedIn: _serviceProvider.coursesService.isOnline,
                  getTerms: () => _serviceProvider.coursesService.getTerms(),
                  onTermSelected: _loadCurriculumForTerm,
                ),
                if (cachedData != null && cachedData.isNotEmpty)
                  ChooseCacheCard(
                    cachedData: cachedData,
                    onSubmit: _activateAndViewCachedData,
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  void _activateAndViewCachedData() {
    final cachedData = _serviceProvider.storeService
        .getCache<CurriculumIntegratedData>(
          "curriculum_data",
          CurriculumIntegratedData.fromJson,
        );

    if (cachedData.isNotEmpty) {
      final data = cachedData.value!;

      // Set activated to true in settings
      setActivated(true);

      if (mounted) {
        setState(() {
          _curriculumData = data;
          _adjustCurrentWeek();
        });
      }
    }
  }

  Widget _buildCurriculumView() {
    if (_curriculumData == null || _curriculumData!.allClasses.isEmpty) {
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
            const SizedBox(height: 8),
            if (_curriculumData != null)
              Text(
                '当前查看：${_curriculumData!.currentTerm.year}学年 第${_curriculumData!.currentTerm.season}学期',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearCacheAndSelectTerm,
              child: const Text('重新选择学期'),
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

  Future<void> _refreshCurriculumData() async {
    _serviceProvider.storeService.removeCache("curriculum_data");
    await _loadCurriculumFromCacheOrService();
  }

  Future<void> _clearCacheAndSelectTerm() async {
    _serviceProvider.storeService.removeCache("curriculum_data");
    if (mounted) {
      setState(() {
        _curriculumData = null;
        _errorMessage = null;
      });
    }
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
        Tooltip(
          message: _currentWeek >= _getMaxValidWeek() ? '已经到最大周次了~' : '',
          child: IconButton(
            onPressed: _currentWeek < _getMaxValidWeek()
                ? () => _changeWeek(1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }

  void _changeWeek(int delta) {
    final maxValidWeek = _getMaxValidWeek();
    setState(() {
      _currentWeek = (_currentWeek + delta).clamp(1, maxValidWeek);
    });
  }

  void _adjustCurrentWeek() {
    final maxValidWeek = _getMaxValidWeek();
    if (_currentWeek > maxValidWeek) {
      _currentWeek = maxValidWeek;
    }
  }

  int _getMaxValidWeek() {
    int maxWeekWithClasses = 0;

    if (_curriculumData != null && _curriculumData!.allClasses.isNotEmpty) {
      for (final classItem in _curriculumData!.allClasses) {
        if (classItem.weeks.isNotEmpty) {
          final maxWeekInClass = classItem.weeks.reduce(
            (a, b) => a > b ? a : b,
          );
          if (maxWeekInClass > maxWeekWithClasses) {
            maxWeekWithClasses = maxWeekInClass;
          }
        }
      }
    }

    int maxWeekFromCalendar = 0;
    if (_curriculumData?.calendarDays != null &&
        _curriculumData!.calendarDays!.isNotEmpty) {
      for (final calendarDay in _curriculumData!.calendarDays!) {
        if (calendarDay.weekIndex > 0 && calendarDay.weekIndex < 99) {
          if (calendarDay.weekIndex > maxWeekFromCalendar) {
            maxWeekFromCalendar = calendarDay.weekIndex;
          }
        }
      }
    }

    final combinedMax = maxWeekWithClasses > maxWeekFromCalendar
        ? maxWeekWithClasses
        : maxWeekFromCalendar;

    final validMax = combinedMax > 0 ? combinedMax : 1;
    return validMax > maxWeeks ? maxWeeks : validMax;
  }

  Map<int, int> _getWeekDates() {
    if (_curriculumData?.calendarDays == null ||
        _curriculumData!.calendarDays!.isEmpty) {
      return {};
    }

    final weekDays = <int, int>{};
    for (final calendarDay in _curriculumData!.calendarDays!) {
      if (calendarDay.weekIndex == _currentWeek) {
        weekDays[calendarDay.weekday] = calendarDay.day;
      }
    }
    return weekDays;
  }

  String? _getCurrentYear() {
    if (_curriculumData?.calendarDays == null ||
        _curriculumData!.calendarDays!.isEmpty) {
      return null;
    }

    for (final calendarDay in _curriculumData!.calendarDays!) {
      if (calendarDay.weekIndex == _currentWeek) {
        return '${calendarDay.year}年';
      }
    }

    return null;
  }

  String? _getCurrentMonth() {
    if (_curriculumData?.calendarDays == null ||
        _curriculumData!.calendarDays!.isEmpty) {
      return null;
    }

    for (final calendarDay in _curriculumData!.calendarDays!) {
      if (calendarDay.weekIndex == _currentWeek) {
        return '${calendarDay.month}月';
      }
    }
    return null;
  }

  Widget _buildCurriculumTable() {
    if (_curriculumData == null || _curriculumData!.allPeriods.isEmpty) {
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
              onPressed: _refreshCurriculumData,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    final weekClasses = _curriculumData!.allClasses
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
                  onPressed: _refreshCurriculumData,
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
    final periods = _curriculumData!.allPeriods;
    final majorPeriods = _getMajorPeriods(periods);

    final courseDays = weekClasses.map((c) => c.day).toSet().toList();

    final settings = getSettings();

    final displayDays = settings.calculateDisplayDays(courseDays);

    final dayColumnWidth = (availableWidth - 2) / (displayDays + 1);

    final weekDates = _getWeekDates();

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
          TableRow(
            children: [
              _buildHeaderCell(
                _getCurrentMonth() ?? '时间',
                subtitle: _getCurrentYear(),
              ),
              for (int day = 1; day <= displayDays; day++)
                _buildHeaderCell(
                  '周${dayNames[day - 1]}',
                  subtitle: weekDates[day]?.toString(),
                ),
            ],
          ),
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

  Widget _buildHeaderCell(String text, {String? subtitle}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: subtitle == null ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorTimeCell(MajorPeriodInfo majorPeriod) {
    final settings = getSettings();
    final cellHeight = settings.tableSize.height;

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

    final settings = getSettings();
    final cellHeight = settings.tableSize.height;

    return Container(
      height: cellHeight,
      decoration: BoxDecoration(
        color: classesInSlot.isEmpty
            ? Colors.white
            : _getClassColor(classesInSlot.first),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: classesInSlot.isEmpty
          ? const SizedBox.expand()
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
          // 学期信息
          if (_curriculumData != null) ...[
            _buildCurriculumInfo(),
            const Divider(),
          ],
          // 设置项
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                _buildWeekendDisplaySetting(),
                const SizedBox(height: 8),
                _buildTableSizeSetting(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumInfo() {
    final cachedData = _serviceProvider.storeService
        .getCache<CurriculumIntegratedData>(
          "curriculum_data",
          CurriculumIntegratedData.fromJson,
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 18),
              const SizedBox(width: 4),
              Text(
                '${_curriculumData!.currentTerm.year}学年 第${_curriculumData!.currentTerm.season}学期',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cachedData.isNotEmpty)
            Text(
              '缓存时间：${formatCacheTime(cachedData)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _deactivateCurrentData,
              icon: const Icon(Icons.cached),
              label: const Text('切换学期或更新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deactivateCurrentData() {
    if (_curriculumData != null) {
      // Set activated to false in settings
      setActivated(false);

      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }

      Navigator.of(context).pop();
    }
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
                initialValue: getSettings().weekendMode,
                items: WeekendDisplayMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.displayName),
                  );
                }).toList(),
                onChanged: (WeekendDisplayMode? newMode) {
                  if (newMode != null) {
                    final currentSettings = getSettings();
                    saveSettings(currentSettings..weekendMode = newMode);
                    setState(() {});
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
                initialValue: getSettings().tableSize,
                items: TableSize.values.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size.displayName),
                  );
                }).toList(),
                onChanged: (TableSize? newSize) {
                  if (newSize != null) {
                    final currentSettings = getSettings();
                    saveSettings(currentSettings..tableSize = newSize);
                    setState(() {});
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
