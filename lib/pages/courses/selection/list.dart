import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';
import '/utils/app_bar.dart';
import 'detail.dart';
import 'submit.dart';
import 'common.dart';

class CourseListPage extends StatefulWidget {
  final TermInfo termInfo;
  final VoidCallback? onRetry;

  const CourseListPage({super.key, required this.termInfo, this.onRetry});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  List<CourseTab> _courseTabs = [];
  CourseTab? _selectedTab;
  List<CourseInfo> _courses = [];
  List<String> _selectedCourseIds = [];
  bool _isLoading = false;
  bool _isLoadingCourses = false;
  String? _errorMessage;
  String? _expandedCourseId; // Current expanded course ID

  @override
  void initState() {
    super.initState();
    _loadCourseTabs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure refreshed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadCourseTabs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tabs = await _serviceProvider.coursesService.getCourseTabs(
        widget.termInfo,
      );
      if (!mounted) return;

      setState(() {
        _courseTabs = tabs;
        if (tabs.isNotEmpty) {
          _selectedTab = tabs.first;
          _loadCourses(); // Load first tab
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCourses() async {
    if (_selectedTab == null || !mounted) return;

    setState(() {
      _isLoadingCourses = true;
      _errorMessage = null;
      _expandedCourseId = null;
    });

    try {
      // Get both selectable and selected courses
      final selectableCourses = await _serviceProvider.coursesService
          .getSelectableCourses(widget.termInfo, _selectedTab!.tabId);
      final selectedCourses = await _serviceProvider.coursesService
          .getSelectedCourses(widget.termInfo, _selectedTab!.tabId);

      if (!mounted) return;

      final selectedIds = selectedCourses
          .map((course) => course.courseId)
          .toSet();

      // Separate courses into selected and unselected
      final selectedInTab = selectableCourses
          .where((course) => selectedIds.contains(course.courseId))
          .toList();
      final unselectedInTab = selectableCourses
          .where((course) => !selectedIds.contains(course.courseId))
          .toList();

      // Combine
      final combinedCourses = [...selectedInTab, ...unselectedInTab];

      setState(() {
        _courses = combinedCourses;
        _selectedCourseIds = selectedIds.toList();
        _isLoadingCourses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoadingCourses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    final selectionState = _serviceProvider.coursesService
        .getCourseSelectionState();

    return Scaffold(
      appBar: PageAppBar(
        title: '选择课程',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [buildTermInfoDisplay(context, widget.termInfo)],
      ),
      body: content,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: selectionState.wantedCourses.isNotEmpty
            ? _buildFloatingActionButtons(selectionState)
            : const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_courseTabs.isEmpty) {
      return const Center(child: Text('暂无可选课程标签页'));
    }

    return _buildCourseContent();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _loadCourseTabs();
                    widget.onRetry?.call();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _courseTabs.map((tab) {
                final isSelected = _selectedTab?.tabId == tab.tabId;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(tab.tabName),
                    onSelected: (selected) {
                      if (selected &&
                          mounted &&
                          _selectedTab?.tabId != tab.tabId) {
                        setState(() {
                          _selectedTab = tab;
                        });
                        _loadCourses();
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: _selectedTab != null
              ? _buildTabContent(_selectedTab!)
              : const Center(child: Text('请选择标签页')),
        ),
      ],
    );
  }

  Widget _buildTabContent(CourseTab tab) {
    if (_isLoadingCourses) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载课程数据...'),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无课程数据',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return _buildResponsiveCourseTable();
  }

  Widget _buildResponsiveCourseTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final columnConfig = [
          {'name': '', 'minWidth': 80.0, 'flex': 0, 'isNumeric': false},
          {'name': '课程代码', 'minWidth': 80.0, 'flex': 2, 'isNumeric': false},
          {'name': '课程名称', 'minWidth': 120.0, 'flex': 4, 'isNumeric': false},
          {'name': '性质', 'minWidth': 60.0, 'flex': 1, 'isNumeric': false},
          {'name': '类别', 'minWidth': 60.0, 'flex': 1, 'isNumeric': false},
          {'name': '学分', 'minWidth': 60.0, 'flex': 1, 'isNumeric': true},
          {'name': '学时', 'minWidth': 60.0, 'flex': 1, 'isNumeric': true},
        ];

        final totalMinWidth = columnConfig.fold<double>(
          0,
          (sum, col) => sum + (col['minWidth'] as double),
        );
        final totalFlex = columnConfig.fold<int>(
          0,
          (sum, col) => sum + (col['flex'] as int),
        );

        final needsHorizontalScroll = availableWidth < totalMinWidth;

        List<double> columnWidths;
        double tableWidth;

        if (needsHorizontalScroll) {
          columnWidths = columnConfig
              .map((col) => col['minWidth'] as double)
              .toList();
          tableWidth = totalMinWidth;
        } else {
          final extraWidth = availableWidth - totalMinWidth;
          columnWidths = columnConfig.map((col) {
            final minWidth = col['minWidth'] as double;
            final flex = col['flex'] as int;
            final extraForThisColumn = extraWidth * (flex / totalFlex);
            return minWidth + extraForThisColumn;
          }).toList();
          tableWidth = availableWidth;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: _CourseTableHeader(
                    columnConfig: columnConfig,
                    columnWidths: columnWidths,
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      final isExpanded = _expandedCourseId == course.courseId;

                      return _CourseTableRow(
                        course: course,
                        termInfo: widget.termInfo,
                        isExpanded: isExpanded,
                        columnWidths: columnWidths,
                        onToggle: () {
                          setState(() {
                            _expandedCourseId = isExpanded
                                ? null
                                : course.courseId;
                          });
                        },
                        onSelectionChanged: () {
                          // Ensure refreshed
                          setState(() {});
                        },
                        selectedCourseIds: _selectedCourseIds,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(CourseSelectionState selectionState) {
    return Row(
      children: [
        // Clear button
        Container(
          height: 28,
          width: 28,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () async {
                // Pop dialog to confirm to clear
                if (await alertClearSelectedWarning(context) == true) {
                  setState(() {
                    for (final course
                        in selectionState.wantedCourses.toList()) {
                      _serviceProvider.coursesService.removeCourseFromSelection(
                        course.courseId,
                        course.classDetail?.classId,
                      );
                    }
                  });
                }
              },
              child: const Icon(Icons.clear, color: Colors.red, size: 16),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Submit button
        Expanded(
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseSubmitPage(termInfo: widget.termInfo),
                    ),
                  );

                  if (mounted) {
                    // Ensure refreshed
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${selectionState.wantedCourses.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '准备提交',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseTableHeader extends StatelessWidget {
  final List<Map<String, Object>> columnConfig;
  final List<double> columnWidths;

  const _CourseTableHeader({
    required this.columnConfig,
    required this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: columnConfig.asMap().entries.map((entry) {
          final index = entry.key;
          final column = entry.value;
          final columnName = column['name'] as String;
          final width = columnWidths[index];
          final isNumeric = column['isNumeric'] as bool;

          return _buildHeaderCell(columnName, width, isNumeric: isNumeric);
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, {bool isNumeric = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: isNumeric ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}

class _CourseTableRow extends StatefulWidget {
  final CourseInfo course;
  final TermInfo termInfo;
  final bool isExpanded;
  final List<double> columnWidths;
  final VoidCallback onToggle;
  final VoidCallback? onSelectionChanged;
  final List<String> selectedCourseIds;

  const _CourseTableRow({
    required this.course,
    required this.termInfo,
    required this.isExpanded,
    required this.columnWidths,
    required this.onToggle,
    this.onSelectionChanged,
    required this.selectedCourseIds,
  });

  @override
  State<_CourseTableRow> createState() => _CourseTableRowState();
}

class _CourseTableRowState extends State<_CourseTableRow>
    with TickerProviderStateMixin {
  late AnimationController _iconRotationController;
  late Animation<double> _iconRotationAnimation;

  int _getSelectedCountForCourse() {
    final serviceProvider = ServiceProvider.instance;
    final selectionState = serviceProvider.coursesService
        .getCourseSelectionState();
    return selectionState.wantedCourses
        .where((course) => course.courseId == widget.course.courseId)
        .length;
  }

  Widget _buildSelectionStatusIndicator() {
    final selectedCount = _getSelectedCountForCourse();
    final isAlreadySelected = widget.selectedCourseIds.contains(
      widget.course.courseId,
    );

    if (selectedCount == 0 && !isAlreadySelected) {
      return const SizedBox.shrink();
    }

    // For already selected courses
    if (isAlreadySelected && selectedCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '已选',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // For courses in current selection
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+ $selectedCount',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _iconRotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconRotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_CourseTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _iconRotationController.forward();
      } else {
        _iconRotationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _iconRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.onToggle,
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          highlightColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.05),
          borderRadius: widget.isExpanded
              ? const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                )
              : BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isExpanded
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.4)
                  : null,
              borderRadius: widget.isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    )
                  : null,
              border: widget.isExpanded
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
            ),
            child: Row(
              children: [
                _buildDataCell(
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: _iconRotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _iconRotationAnimation.value * 3.1415927,
                            child: Icon(
                              Icons.expand_more,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildSelectionStatusIndicator(),
                    ],
                  ),
                  widget.columnWidths[0],
                  needCenter: true,
                ),
                _buildDataCell(
                  Text(
                    widget.course.courseId,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  widget.columnWidths[1],
                ),
                _buildNameCell(
                  widget.course.courseName,
                  widget.course.courseNameAlt,
                  widget.columnWidths[2],
                ),
                _buildDataCell(
                  Text(
                    widget.course.courseType,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  widget.columnWidths[3],
                ),
                _buildDataCell(
                  Text(
                    widget.course.courseCategory,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  widget.columnWidths[4],
                ),
                _buildDataCell(
                  Text(
                    widget.course.credits.toString(),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  widget.columnWidths[5],
                  needCenter: true,
                ),
                _buildDataCell(
                  Text(
                    widget.course.hours.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  widget.columnWidths[6],
                  needCenter: true,
                ),
              ],
            ),
          ),
        ),

        CourseDetailCard(
          course: widget.course,
          termInfo: widget.termInfo,
          isExpanded: widget.isExpanded,
          onToggle: widget.onToggle,
          onSelectionChanged: widget.onSelectionChanged,
          selectedCourseIds: widget.selectedCourseIds,
        ),
      ],
    );
  }

  Widget _buildDataCell(Widget child, double width, {bool needCenter = false}) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: needCenter ? Alignment.center : Alignment.centerLeft,
        child: child,
      ),
    );
  }

  Widget _buildNameCell(String name, String? nameAlt, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          if (nameAlt?.isNotEmpty == true)
            Text(
              nameAlt!,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
