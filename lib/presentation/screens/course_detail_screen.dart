import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../providers/download_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/illustrations.dart';
import '../widgets/info_chip.dart';
import '../widgets/lesson_tile.dart';
import '../widgets/progress_bar.dart';
import 'player_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  void _play(BuildContext context, Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(course: course, lesson: lesson),
      ),
    );
  }

  Future<void> _downloadAll(BuildContext context) async {
    final downloads = context.read<DownloadProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final pending = course.allLessons
        .where((l) => l.downloadable && !downloads.isDownloaded(l.id))
        .toList();
    if (pending.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('All available lessons are downloaded.')),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Downloading ${pending.length} lessons...')),
    );
    for (final lesson in pending) {
      downloads.start(lesson, course.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final fraction = progress.courseFraction(course);
    final started = progress.hasStarted(course);
    final next = progress.nextLesson(course);
    int counter = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withOpacity(0.25),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'course-art-${course.id}',
                child: CourseArt(
                  thumbnail: course.thumbnail,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(
                        icon: Icons.category_rounded,
                        label: course.category,
                      ),
                      InfoChip(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: course.level,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          Formatters.initials(course.instructor),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.instructor,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Instructor',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _Stat(
                          value: '${course.chapterCount}',
                          label: 'Chapters',
                        ),
                        _Divider(),
                        _Stat(
                          value: '${course.lessonCount}',
                          label: 'Lessons',
                        ),
                        _Divider(),
                        _Stat(
                          value: Formatters.durationShort(course.totalSeconds),
                          label: 'Duration',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About this course',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (started) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your progress',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${progress.completedCount(course)}/${course.lessonCount} lessons',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SoftProgressBar(value: fraction, height: 8),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: started ? 'Continue learning' : 'Start course',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => _play(context, next),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Download all lessons',
                    icon: Icons.download_for_offline_outlined,
                    onPressed: () => _downloadAll(context),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Curriculum',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: course.chapters.length,
            itemBuilder: (context, index) {
              final chapter = course.chapters[index];
              final startNumber = counter;
              counter += chapter.lessons.length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _ChapterSection(
                  course: course,
                  chapter: chapter,
                  chapterNumber: index + 1,
                  startNumber: startNumber,
                  onPlay: (lesson) => _play(context, lesson),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ChapterSection extends StatelessWidget {
  final Course course;
  final Chapter chapter;
  final int chapterNumber;
  final int startNumber;
  final ValueChanged<Lesson> onPlay;

  const _ChapterSection({
    required this.course,
    required this.chapter,
    required this.chapterNumber,
    required this.startNumber,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final done = progress.chapterCompleted(chapter);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: chapterNumber == 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            'Chapter $chapterNumber',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.primaryDark,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done/${chapter.lessons.length} lessons  •  ${Formatters.durationShort(chapter.totalSeconds)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          children: [
            for (int i = 0; i < chapter.lessons.length; i++) ...[
              LessonTile(
                course: course,
                lesson: chapter.lessons[i],
                number: startNumber + i + 1,
                onTap: () => onPlay(chapter.lessons[i]),
              ),
              if (i != chapter.lessons.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.border);
  }
}
