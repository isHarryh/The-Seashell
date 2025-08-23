import 'package:flutter/material.dart';
import '/types/courses.dart';

class CourseDetailCard extends StatefulWidget {
  final CourseInfo course;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CourseDetailCard({
    super.key,
    required this.course,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<CourseDetailCard> createState() => _CourseDetailCardState();
}

class _CourseDetailCardState extends State<CourseDetailCard>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _titleController;
  late Animation<double> _expansionAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;

  // To locate the details widget in the list context
  final GlobalKey _detailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutQuint),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.15, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutQuint),
        );
  }

  @override
  void didUpdateWidget(CourseDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expansionController.forward();
        _titleController.forward();
        _expansionController.addStatusListener(_onExpansionStatusChanged);
      } else {
        _expansionController.reverse();
        _titleController.reset();
      }
    }
  }

  void _onExpansionStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.isExpanded) {
      _expansionController.removeStatusListener(_onExpansionStatusChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll the list to the details widget
        final context = _detailsKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.3,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _titleController.dispose();
    _expansionController.removeStatusListener(_onExpansionStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _expansionAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _expansionAnimation,
            child: SizeTransition(
              sizeFactor: _expansionAnimation,
              child: _buildExpandedContent(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseTitle(),
            const SizedBox(height: 20),
            _buildInfoGrid(),
            const SizedBox(height: 20),
            _buildNoticeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseTitle() {
    return SlideTransition(
      position: _titleSlideAnimation,
      child: FadeTransition(
        opacity: _titleOpacityAnimation,
        child: Row(
          key: _detailsKey,
          children: [
            Icon(
              Icons.school,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.courseName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (widget.course.courseNameAlt?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.course.courseNameAlt!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _CourseInfoChip(
          label: '课程性质',
          value: widget.course.courseType,
          icon: Icons.category,
          valueAlt: widget.course.courseTypeAlt,
        ),
        _CourseInfoChip(
          label: '课程类别',
          value: widget.course.courseCategory,
          icon: Icons.class_,
          valueAlt: widget.course.courseCategoryAlt,
        ),
        _CourseInfoChip(
          label: '开课院系',
          value: widget.course.schoolName,
          icon: Icons.domain,
          valueAlt: widget.course.schoolNameAlt,
        ),
        _CourseInfoChip(
          label: '校区',
          value: widget.course.districtName,
          icon: Icons.location_on,
          valueAlt: widget.course.districtNameAlt,
        ),
        _CourseInfoChip(
          label: '语言',
          value: widget.course.teachingLanguage,
          icon: Icons.language,
          valueAlt: widget.course.teachingLanguageAlt,
        ),
      ],
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选课功能开发中',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '讲台选择和课程选择功能将在后续版本中实现，敬请期待！',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? valueAlt;

  const _CourseInfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.valueAlt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (valueAlt?.isNotEmpty == true)
                Text(
                  valueAlt!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
