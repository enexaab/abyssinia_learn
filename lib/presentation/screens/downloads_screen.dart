import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../../data/models/download_record.dart';
import '../providers/course_provider.dart';
import '../providers/download_provider.dart';
import '../widgets/download_action.dart';
import '../widgets/illustrations.dart';
import '../widgets/progress_bar.dart';
import '../widgets/state_views.dart';
import 'player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final downloads = context.read<DownloadProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete all downloads?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All offline lessons will be removed from this device.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (ok == true) await downloads.removeAll();
  }

  void _play(BuildContext context, LessonRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(course: ref.course, lesson: ref.lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final downloads = context.watch<DownloadProvider>();
    final courses = context.watch<CourseProvider>();
    final active = downloads.activeLessonIds;
    final records = downloads.records;
    final failed = <LessonRef>[];

    if (courses.status == LoadStatus.loaded) {
      for (final course in courses.courses) {
        for (final chapter in course.chapters) {
          for (final lesson in chapter.lessons) {
            if (downloads.stateOf(lesson.id).status == DownloadStatus.failed) {
              failed.add(
                LessonRef(course: course, chapter: chapter, lesson: lesson),
              );
            }
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (records.isNotEmpty)
            IconButton(
              tooltip: 'Delete all',
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (!downloads.isLoaded) {
            return const LoadingView(message: 'Loading downloads...');
          }
          if (records.isEmpty && active.isEmpty && failed.isEmpty) {
            return const MessageView(
              kind: EmptyKind.downloads,
              title: 'No downloads yet',
              message:
                  'Download lessons from any course and watch them anytime, even without internet.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _StorageSummary(
                count: records.length,
                bytes: downloads.totalBytes,
              ),
              if (active.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle('In progress'),
                const SizedBox(height: 10),
                for (final id in active)
                  if (courses.refForLesson(id) != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ActiveTile(ref: courses.refForLesson(id)!),
                    ),
              ],
              if (failed.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle('Failed'),
                const SizedBox(height: 10),
                for (final ref in failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FailedTile(ref: ref),
                  ),
              ],
              if (records.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle('Available offline'),
                const SizedBox(height: 10),
                for (final record in records)
                  if (courses.refForLesson(record.lessonId) != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CompletedTile(
                        ref: courses.refForLesson(record.lessonId)!,
                        record: record,
                        onTap: () =>
                            _play(context, courses.refForLesson(record.lessonId)!),
                      ),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _StorageSummary extends StatelessWidget {
  final int count;
  final int bytes;

  const _StorageSummary({required this.count, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.offline_pin_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'lesson' : 'lessons'} saved',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${Formatters.bytes(bytes)} used on this device',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileShell extends StatelessWidget {
  final LessonRef ref;
  final Widget subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _TileShell({
    required this.ref,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CourseArt(
                thumbnail: ref.course.thumbnail,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ref.course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  subtitle,
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ActiveTile extends StatelessWidget {
  final LessonRef ref;

  const _ActiveTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DownloadProvider>().stateOf(ref.lesson.id);
    final known = state.totalBytes > 0;
    return _TileShell(
      ref: ref,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (known)
            SoftProgressBar(value: state.progress, height: 5)
          else
            const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: LinearProgressIndicator(minHeight: 5),
            ),
          const SizedBox(height: 5),
          Text(
            known
                ? '${Formatters.percent(state.progress)}  •  ${Formatters.bytes(state.receivedBytes)} of ${Formatters.bytes(state.totalBytes)}'
                : state.status == DownloadStatus.queued
                    ? 'Starting...'
                    : Formatters.bytes(state.receivedBytes),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
      trailing: DownloadAction(lesson: ref.lesson, courseId: ref.course.id),
    );
  }
}

class _FailedTile extends StatelessWidget {
  final LessonRef ref;

  const _FailedTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DownloadProvider>().stateOf(ref.lesson.id);
    return _TileShell(
      ref: ref,
      subtitle: Text(
        state.error ?? 'Download failed.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
      trailing: DownloadAction(lesson: ref.lesson, courseId: ref.course.id),
    );
  }
}

class _CompletedTile extends StatelessWidget {
  final LessonRef ref;
  final DownloadRecord record;
  final VoidCallback onTap;

  const _CompletedTile({
    required this.ref,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      ref: ref,
      onTap: onTap,
      subtitle: Row(
        children: [
          const Icon(Icons.schedule_rounded,
              size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            Formatters.duration(ref.lesson.durationSeconds),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.sd_storage_rounded,
              size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            Formatters.bytes(record.totalBytes),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Remove',
            onPressed: () => confirmRemoveDownload(context, ref.lesson),
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textMuted),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
