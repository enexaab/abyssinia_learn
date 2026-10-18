import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../providers/auth_provider.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/dotted_pattern.dart';
import '../widgets/illustrations.dart';
import '../widgets/progress_bar.dart';
import '../widgets/state_views.dart';
import 'course_detail_screen.dart';
import 'player_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>();
    final progress = context.watch<ProgressProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => courses.load(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                name: user?.name ?? 'Learner',
                controller: _search,
                onChanged: courses.setQuery,
                onClear: () {
                  _search.clear();
                  courses.setQuery('');
                },
              ),
            ),
            ..._body(courses, progress),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(CourseProvider courses, ProgressProvider progress) {
    switch (courses.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: LoadingView(message: 'Loading courses...'),
          ),
        ];
      case LoadStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              message: courses.error ?? 'Unable to load courses.',
              onRetry: () => courses.load(force: true),
            ),
          ),
        ];
      case LoadStatus.loaded:
        break;
    }

    final list = courses.filtered;
    final resumeCourse = _resumeCourse(courses.courses, progress);
    final filtering = courses.query.trim().isNotEmpty || courses.category != 'All';

    return [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            scrollDirection: Axis.horizontal,
            itemCount: courses.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final category = courses.categories[i];
              final selected = category == courses.category;
              return GestureDetector(
                onTap: () => courses.setCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      if (resumeCourse != null && !filtering)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: _ResumeCard(
              course: resumeCourse,
              onResume: () {
                final lesson = progress.nextLesson(resumeCourse);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PlayerScreen(course: resumeCourse, lesson: lesson),
                  ),
                );
              },
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                filtering ? 'Results' : 'All courses',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${list.length} ${list.length == 1 ? 'course' : 'courses'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
      if (list.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView(
            kind: courses.courses.isEmpty ? EmptyKind.courses : EmptyKind.search,
            title: courses.courses.isEmpty
                ? 'No courses yet'
                : 'No matching courses',
            message: courses.courses.isEmpty
                ? 'Courses will appear here once they are available.'
                : 'Try a different keyword or clear the filters to see everything.',
            actionLabel: courses.courses.isEmpty ? null : 'Clear filters',
            actionIcon: Icons.filter_alt_off_rounded,
            onAction: () {
              _search.clear();
              courses.clearFilters();
            },
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, i) => CourseCard(
              course: list[i],
              onTap: () => _open(list[i]),
            ),
          ),
        ),
    ];
  }

  Course? _resumeCourse(List<Course> courses, ProgressProvider progress) {
    for (final course in courses) {
      if (progress.hasStarted(course) && progress.courseFraction(course) < 1) {
        return course;
      }
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  final String name;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _Header({
    required this.name,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
          children: [
            const Positioned.fill(child: DottedPattern(spacing: 9, seed: 3)),
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.greeting(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          Formatters.initials(name),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'What do you want to learn today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search courses, lessons, instructors',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.primary),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, _) => value.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: onClear,
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppColors.textMuted, size: 20),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final Course course;
  final VoidCallback onResume;

  const _ResumeCard({required this.course, required this.onResume});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final fraction = progress.courseFraction(course);
    final lesson = progress.nextLesson(course);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CourseArt(
              thumbnail: course.thumbnail,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONTINUE LEARNING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SoftProgressBar(value: fraction, height: 5),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onResume,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
