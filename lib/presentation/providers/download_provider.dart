import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/course.dart';
import '../../data/models/download_record.dart';
import '../../data/repositories/download_repository.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadRepository _repository;

  DownloadProvider(this._repository);

  final Map<String, DownloadRecord> _records = {};
  final Map<String, DownloadState> _states = {};
  final Map<String, CancelToken> _tokens = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<DownloadRecord> get records {
    final list = _records.values.toList();
    list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return list;
  }

  List<String> get activeLessonIds =>
      _states.entries.where((e) => e.value.isActive).map((e) => e.key).toList();

  int get totalBytes =>
      _records.values.fold(0, (sum, record) => sum + record.totalBytes);

  Future<void> initialize() async {
    final stored = await _repository.loadRecords();
    for (final record in stored) {
      _records[record.lessonId] = record;
      _states[record.lessonId] = DownloadState(
        status: DownloadStatus.completed,
        progress: 1,
        receivedBytes: record.totalBytes,
        totalBytes: record.totalBytes,
      );
    }
    _loaded = true;
    notifyListeners();
  }

  DownloadState stateOf(String lessonId) =>
      _states[lessonId] ?? const DownloadState();

  String? localPath(String lessonId) => _records[lessonId]?.filePath;

  bool isDownloaded(String lessonId) => _records.containsKey(lessonId);

  Future<void> start(Lesson lesson, String courseId) async {
    if (!lesson.downloadable) return;
    final current = stateOf(lesson.id);
    if (current.isActive || current.isCompleted) return;

    final token = CancelToken();
    _tokens[lesson.id] = token;
    _states[lesson.id] = const DownloadState(status: DownloadStatus.queued);
    notifyListeners();

    try {
      final record = await _repository.download(
        lesson: lesson,
        courseId: courseId,
        cancelToken: token,
        onProgress: (received, total) {
          final fraction = total > 0 ? received / total : 0.0;
          _states[lesson.id] = DownloadState(
            status: DownloadStatus.downloading,
            progress: fraction.clamp(0.0, 1.0),
            receivedBytes: received,
            totalBytes: total > 0 ? total : 0,
          );
          notifyListeners();
        },
      );
      _records[lesson.id] = record;
      await _repository.saveRecords(_records.values.toList());
      _states[lesson.id] = DownloadState(
        status: DownloadStatus.completed,
        progress: 1,
        receivedBytes: record.totalBytes,
        totalBytes: record.totalBytes,
      );
    } on DownloadException catch (e) {
      if (token.isCancelled) {
        _states.remove(lesson.id);
      } else {
        _states[lesson.id] = DownloadState(
          status: DownloadStatus.failed,
          error: e.message,
        );
      }
    } catch (_) {
      _states[lesson.id] = const DownloadState(
        status: DownloadStatus.failed,
        error: 'Download failed. Please try again.',
      );
    } finally {
      _tokens.remove(lesson.id);
      notifyListeners();
    }
  }

  void cancel(String lessonId) {
    _tokens[lessonId]?.cancel('cancelled');
  }

  Future<void> remove(String lessonId) async {
    final record = _records.remove(lessonId);
    _states.remove(lessonId);
    if (record != null) {
      await _repository.deleteFile(record);
      await _repository.saveRecords(_records.values.toList());
    }
    notifyListeners();
  }

  Future<void> removeAll() async {
    final ids = _records.keys.toList();
    for (final id in ids) {
      await remove(id);
    }
  }

  void dismissFailure(String lessonId) {
    if (_states[lessonId]?.status == DownloadStatus.failed) {
      _states.remove(lessonId);
      notifyListeners();
    }
  }
}
