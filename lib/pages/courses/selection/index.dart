import 'package:flutter/material.dart';
import '/services/provider.dart';
import '/types/courses.dart';
import 'list.dart';

class CourseSelectionPage extends StatefulWidget {
  const CourseSelectionPage({super.key});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage>
    with TickerProviderStateMixin {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  bool _showCourseList = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  List<TermInfo> _terms = [];
  TermInfo? _selectedTerm;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _loadTerms();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final terms = await _serviceProvider.coursesService.getTerms();
      if (!mounted) return;

      setState(() {
        _terms = terms;
        if (terms.isNotEmpty) {
          _selectedTerm = terms.first;
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

  Future<void> _loadCourseTabs() async {
    if (_selectedTerm == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _showCourseList = true;
      });

      _animationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _backToTermSelection() async {
    await _animationController.reverse();

    if (mounted) {
      setState(() {
        _showCourseList = false;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选课'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _showCourseList
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToTermSelection,
              )
            : null,
        actions: _showCourseList && _selectedTerm != null
            ? [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedTerm!.year}-${_selectedTerm!.season}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: _showCourseList
          ? _buildCourseListView()
          : _buildTermSelectionView(),
    );
  }

  Widget _buildTermSelectionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择学期',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '请选择您要进行选课的学期',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadTerms,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                '学期选择',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<TermInfo>(
                            initialValue: _selectedTerm,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: '选择学期',
                            ),
                            items: _terms.map((term) {
                              return DropdownMenuItem(
                                value: term,
                                child: Text(
                                  '${term.year}学年 第${term.season}学期',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (TermInfo? newTerm) {
                              if (mounted) {
                                setState(() {
                                  _selectedTerm = newTerm;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _selectedTerm != null
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _selectedTerm != null
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedTerm != null && !_isLoading
                          ? _loadCourseTabs
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '开始选课',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_selectedTerm == null)
                    Text(
                      '请先选择学期才能开始选课',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseListView() {
    return SlideTransition(
      position: _slideAnimation,
      child: _selectedTerm != null
          ? CourseListPage(
              termInfo: _selectedTerm!,
              showAppBar: false,
              onRetry: _loadCourseTabs,
            )
          : const Center(child: Text('未选择学期')),
    );
  }
}
