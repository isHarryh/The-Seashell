import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';
import '/utils/app_bar.dart';

class CourseListPage extends StatefulWidget {
  final TermInfo termInfo;
  final bool showAppBar;
  final bool showTermInfo;
  final VoidCallback? onRetry;

  const CourseListPage({
    super.key,
    required this.termInfo,
    this.showAppBar = true,
    this.showTermInfo = false,
    this.onRetry,
  });

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  List<CourseTab> _courseTabs = [];
  CourseTab? _selectedTab;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCourseTabs();
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

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (widget.showAppBar) {
      return Scaffold(
        appBar: PageAppBar(
          title: '课程选择 - ${widget.termInfo.year} 第${widget.termInfo.season}学期',
        ),
        body: content,
      );
    } else {
      return content;
    }
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
        if (widget.showTermInfo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              '${widget.termInfo.year} 第${widget.termInfo.season}学期',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

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
                      if (selected && mounted) {
                        setState(() {
                          _selectedTab = tab;
                        });
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.list_alt,
                size: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                tab.tabName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (tab.selectionStartTime != null &&
                  tab.selectionEndTime != null)
                Text(
                  '选课时间：${tab.selectionStartTime} - ${tab.selectionEndTime}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  '课程数据表展示功能正在开发中',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
