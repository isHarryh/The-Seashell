import 'package:flutter/material.dart';
import '/types/courses.dart';
import '/utils/app_bar.dart';
import '/services/provider.dart';

class CourseSubmitPage extends StatefulWidget {
  final TermInfo termInfo;

  const CourseSubmitPage({super.key, required this.termInfo});

  @override
  State<CourseSubmitPage> createState() => _CourseSubmitPageState();
}

class _CourseSubmitPageState extends State<CourseSubmitPage> {
  final ServiceProvider _serviceProvider = ServiceProvider.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(
        title: '提交选课',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 2),
                Text(
                  '${widget.termInfo.year}-${widget.termInfo.season}',
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
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 24),
          _buildSelectedCoursesList(),
          const Spacer(),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildStepItem('选择学期', 1, false),
          _buildStepConnector(),
          _buildStepItem('选择课程', 2, false),
          _buildStepConnector(),
          _buildStepItem('提交选课', 3, true),
        ],
      ),
    );
  }

  Widget _buildStepItem(String title, int stepNumber, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      width: 20,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
    );
  }

  Widget _buildSelectedCoursesList() {
    final selectionState = _serviceProvider.coursesService
        .getCourseSelectionState();
    final selectedCourses = selectionState.wantedCourses;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '待提交课程 (${selectedCourses.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无选择的课程',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedCourses.length,
                    itemBuilder: (context, index) {
                      final course = selectedCourses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.book,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          title: Text(
                            course.courseName +
                                (course.classDetail?.extraName != null
                                    ? ' ${course.classDetail?.extraName}'
                                    : ''),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '课程 ${course.courseId}',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _serviceProvider.coursesService
                                    .removeCourseFromSelection(
                                      course.courseId,
                                      course.classDetail?.classId,
                                    );
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final selectionState = _serviceProvider.coursesService
        .getCourseSelectionState();
    final selectedCourses = selectionState.wantedCourses;

    return Container(
      height: 52,
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
        color: selectedCourses.isEmpty
            ? Colors.grey.shade400
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: selectedCourses.isEmpty ? null : _handleSubmit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedCourses.isEmpty ? Icons.warning : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedCourses.isEmpty ? '请先选择课程' : '提交选课申请',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final selectionState = _serviceProvider.coursesService
        .getCourseSelectionState();
    final selectedCourses = selectionState.wantedCourses;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交选课'),
        content: Text('确认提交 ${selectedCourses.length} 门课程的选课申请？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSubmitResult();
            },
            child: const Text('确认提交'),
          ),
        ],
      ),
    );
  }

  void _showSubmitResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('提交成功'),
        content: const Text('选课申请已提交，请等待系统处理。'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
