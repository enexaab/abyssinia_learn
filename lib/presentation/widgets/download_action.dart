import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/course.dart';
import '../../data/models/download_record.dart';
import '../providers/download_provider.dart';

class DownloadAction extends StatelessWidget {
  final Lesson lesson;
  final String courseId;
  final double size;

  const DownloadAction({
    super.key,
    required this.lesson,
    required this.courseId,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DownloadProvider>();
    final state = provider.stateOf(lesson.id);

    if (!lesson.downloadable) {
      return Tooltip(
        message: 'Streaming only',
        child: _frame(
          const Icon(Icons.stream_rounded, color: AppColors.textMuted, size: 20),
          AppColors.surface,
        ),
      );
    }

    switch (state.status) {
      case DownloadStatus.queued:
      case DownloadStatus.downloading:
        return GestureDetector(
          onTap: () => provider.cancel(lesson.id),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size - 6,
                  height: size - 6,
                  child: CircularProgressIndicator(
                    value: state.status == DownloadStatus.queued ||
                            state.totalBytes == 0
                        ? null
                        : state.progress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
                const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.primaryDark),
              ],
            ),
          ),
        );
      case DownloadStatus.completed:
        return GestureDetector(
          onTap: () => confirmRemoveDownload(context, lesson),
          child: _frame(
            const Icon(Icons.download_done_rounded,
                color: Colors.white, size: 20),
            AppColors.primary,
          ),
        );
      case DownloadStatus.failed:
        return GestureDetector(
          onTap: () {
            provider.dismissFailure(lesson.id);
            provider.start(lesson, courseId);
          },
          child: _frame(
            const Icon(Icons.refresh_rounded,
                color: AppColors.error, size: 20),
            AppColors.error.withOpacity(0.1),
          ),
        );
      case DownloadStatus.none:
        return GestureDetector(
          onTap: () => provider.start(lesson, courseId),
          child: _frame(
            const Icon(Icons.file_download_outlined,
                color: AppColors.primaryDark, size: 22),
            AppColors.primaryLight,
          ),
        );
    }
  }

  Widget _frame(Widget child, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: child),
    );
  }
}

Future<void> confirmRemoveDownload(BuildContext context, Lesson lesson) async {
  final provider = context.read<DownloadProvider>();
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove download?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '"${lesson.title}" will be deleted from this device. You can download it again anytime.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  if (confirmed == true) {
    await provider.remove(lesson.id);
  }
}
