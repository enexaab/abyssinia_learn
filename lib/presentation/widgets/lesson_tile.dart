import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../../data/models/download_record.dart';
import '../providers/download_provider.dart';
import '../providers/progress_provider.dart';
import 'download_action.dart';
import 'progress_bar.dart';

class LessonTile extends StatelessWidget {
  final Course course;
  final Lesson lesson;
  final int number;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.course,
    required this.lesson,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().of(lesson.id);
    final downloads = context.watch<DownloadProvider>();
    final state = downloads.stateOf(lesson.id);
    final downloaded = downloads.isDownloaded(lesson.id);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: progress.completed ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: progress.completed
                ? AppColors.primary.withOpacity(0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: progress.completed
                    ? AppColors.primary
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: progress.completed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 22)
                    : Text(
                        '$number',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.duration(lesson.durationSeconds),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (downloaded) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.offline_pin_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (state.status == DownloadStatus.downloading) ...[
                        const SizedBox(width: 10),
                        Text(
                          state.totalBytes > 0
                              ? Formatters.percent(state.progress)
                              : Formatters.bytes(state.receivedBytes),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!progress.completed && progress.positionMs > 0) ...[
                    const SizedBox(height: 8),
                    SoftProgressBar(value: progress.fraction, height: 4),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            DownloadAction(lesson: lesson, courseId: course.id),
          ],
        ),
      ),
    );
  }
}
