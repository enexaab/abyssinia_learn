import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../../data/models/download_record.dart';
import '../providers/download_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/download_action.dart';
import '../widgets/info_chip.dart';
import '../widgets/lesson_tile.dart';

class PlayerScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  const PlayerScreen({super.key, required this.course, required this.lesson});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Lesson _lesson = widget.lesson;
  late final ProgressProvider _progress;
  late final DownloadProvider _downloads;

  VideoPlayerController? _video;
  ChewieController? _chewie;
  Timer? _ticker;
  bool _loading = true;
  bool _playingOffline = false;
  bool _completionHandled = false;
  String? _error;

  List<Lesson> get _lessons => widget.course.allLessons;
  int get _index => _lessons.indexWhere((l) => l.id == _lesson.id);

  @override
  void initState() {
    super.initState();
    _progress = context.read<ProgressProvider>();
    _downloads = context.read<DownloadProvider>();
    _load();
  }

  @override
  void dispose() {
    _saveProgress(deferred: true);
    _releasePlayer();
    super.dispose();
  }

  void _releasePlayer() {
    _ticker?.cancel();
    _ticker = null;
    _video?.removeListener(_onVideoTick);
    _chewie?.dispose();
    _video?.dispose();
    _chewie = null;
    _video = null;
  }

  Future<void> _load() async {
    if (!mounted) return;
    _ticker?.cancel();
    _ticker = null;
    final oldChewie = _chewie;
    final oldVideo = _video;
    oldVideo?.removeListener(_onVideoTick);
    setState(() {
      _chewie = null;
      _video = null;
      _loading = true;
      _error = null;
      _completionHandled = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldChewie?.dispose();
      oldVideo?.dispose();
    });

    final localPath = _downloads.localPath(_lesson.id);
    final hasLocal = localPath != null && await File(localPath).exists();
    final controller = hasLocal
        ? VideoPlayerController.file(File(localPath))
        : VideoPlayerController.networkUrl(Uri.parse(_lesson.videoUrl));

    try {
      await controller.initialize().timeout(const Duration(seconds: 25));
      if (!mounted) {
        await controller.dispose();
        return;
      }

      final saved = _progress.of(_lesson.id);
      final duration = controller.value.duration.inMilliseconds;
      if (!saved.completed &&
          saved.positionMs > 1500 &&
          saved.positionMs < duration - 2000) {
        await controller.seekTo(Duration(milliseconds: saved.positionMs));
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
        errorBuilder: (context, message) => _PlayerMessage(
          icon: Icons.error_outline_rounded,
          title: 'Playback error',
          message: message,
          onRetry: _load,
        ),
      );

      controller.addListener(_onVideoTick);
      _ticker = Timer.periodic(const Duration(seconds: 4), (_) {
        _saveProgress();
      });

      setState(() {
        _video = controller;
        _chewie = chewie;
        _playingOffline = hasLocal;
        _loading = false;
      });
    } on TimeoutException {
      await controller.dispose();
      _fail('The video took too long to load. Check your connection.');
    } catch (_) {
      await controller.dispose();
      _fail(
        hasLocal
            ? 'The downloaded file could not be played. Try removing and downloading it again.'
            : 'This lesson could not be loaded. Check your internet connection or download it for offline use.',
      );
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = message;
    });
  }

  void _onVideoTick() {
    final video = _video;
    if (video == null || _completionHandled) return;
    final value = video.value;
    final total = value.duration.inMilliseconds;
    if (total > 0 && value.position.inMilliseconds >= total - 300) {
      _completionHandled = true;
      _progress.update(
        _lesson.id,
        positionMs: total,
        durationMs: total,
        completed: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson completed. Great job!')),
        );
      }
    }
  }

  void _saveProgress({bool deferred = false}) {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    final total = video.value.duration.inMilliseconds;
    if (total <= 0) return;
    final lessonId = _lesson.id;
    final position = video.value.position.inMilliseconds;
    final progress = _progress;
    void write() {
      progress.update(lessonId, positionMs: position, durationMs: total);
    }

    if (deferred) {
      Future<void>.microtask(write);
    } else {
      write();
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= _lessons.length) return;
    _saveProgress();
    setState(() => _lesson = _lessons[index]);
    _load();
  }

  Chapter get _chapter => widget.course.chapters
      .firstWhere((c) => c.lessons.any((l) => l.id == _lesson.id));

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final downloads = context.watch<DownloadProvider>();
    final completed = progress.isCompleted(_lesson.id);
    final downloaded = downloads.isDownloaded(_lesson.id);
    final index = _index;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPlayer(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      icon: Icons.menu_book_rounded,
                      label: _chapter.title,
                    ),
                    InfoChip(
                      icon: Icons.schedule_rounded,
                      label: Formatters.duration(_lesson.durationSeconds),
                    ),
                    if (_playingOffline)
                      const InfoChip(
                        icon: Icons.offline_pin_rounded,
                        label: 'Playing offline',
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _lesson.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DownloadAction(
                      lesson: _lesson,
                      courseId: widget.course.id,
                      size: 46,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DownloadStatusText(lesson: _lesson, downloaded: downloaded),
                const SizedBox(height: 12),
                Text(
                  _lesson.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: index > 0 ? () => _goTo(index - 1) : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                        label: const Text('Previous'),
                        style: _navStyle(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: index < _lessons.length - 1
                            ? () => _goTo(index + 1)
                            : null,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('Next'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      progress.setCompleted(_lesson.id, !completed),
                  icon: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    completed ? 'Completed' : 'Mark as completed',
                    style: const TextStyle(color: AppColors.primaryDark),
                  ),
                  style: _navStyle(
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Up next',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < _lessons.length; i++) ...[
                  Opacity(
                    opacity: i == index ? 0.55 : 1,
                    child: LessonTile(
                      course: widget.course,
                      lesson: _lessons[i],
                      number: i + 1,
                      onTap: () => _goTo(i),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _navStyle({BorderSide? side}) {
    return OutlinedButton.styleFrom(
      side: side,
      minimumSize: const Size.fromHeight(50),
      foregroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildPlayer() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return _PlayerMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Unable to play video',
        message: _error!,
        onRetry: _load,
      );
    }
    final chewie = _chewie;
    if (chewie == null) return const SizedBox.shrink();
    return Chewie(controller: chewie);
  }
}

class _DownloadStatusText extends StatelessWidget {
  final Lesson lesson;
  final bool downloaded;

  const _DownloadStatusText({required this.lesson, required this.downloaded});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DownloadProvider>().stateOf(lesson.id);
    String text;
    Color color = AppColors.textSecondary;
    IconData icon = Icons.cloud_outlined;

    if (!lesson.downloadable) {
      text = 'This lesson is available for streaming only.';
      icon = Icons.stream_rounded;
    } else if (downloaded) {
      text =
          'Saved on this device (${Formatters.bytes(state.totalBytes)}). Tap the icon to remove.';
      color = AppColors.primaryDark;
      icon = Icons.offline_pin_rounded;
    } else if (state.isActive) {
      final percent = state.totalBytes > 0
          ? Formatters.percent(state.progress)
          : Formatters.bytes(state.receivedBytes);
      text = 'Downloading... $percent';
      color = AppColors.primaryDark;
      icon = Icons.downloading_rounded;
    } else if (state.status == DownloadStatus.failed) {
      text = state.error ?? 'Download failed. Tap the icon to retry.';
      color = AppColors.error;
      icon = Icons.error_outline_rounded;
    } else {
      text = 'Download this lesson to watch without internet.';
    }

    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _PlayerMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E1A13),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
