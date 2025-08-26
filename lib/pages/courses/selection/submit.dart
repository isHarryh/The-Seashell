import 'package:flutter/material.dart';
import '/types/courses.dart';
import '/utils/app_bar.dart';
import '/services/provider.dart';
import 'common.dart';

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

        actions: [buildTermInfoDisplay(context, widget.termInfo)],
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
          buildStepIndicator(context, 3),
          const SizedBox(height: 24),
          _buildSelectedCoursesList(),
          const Spacer(),
          _buildSubmitButton(),
        ],
      ),
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
