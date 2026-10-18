import 'package:flutter/foundation.dart';
import '../../data/models/course.dart';
import '../../data/models/lesson_progress.dart';
import '../../data/repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repository;

  ProgressProvider(this._repository);

  String? _userId;
  Map<String, LessonProgress> _progress = {};

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _progress = userId == null ? {} : _repository.load(userId);
    notifyListeners();
  }

  LessonProgress of(String lessonId) =>
      _progress[lessonId] ?? const LessonProgress();

  bool isCompleted(String lessonId) => of(lessonId).completed;

  int completedCount(Course course) =>
      course.allLessons.where((l) => isCompleted(l.id)).length;

  double courseFraction(Course course) {
    if (course.lessonCount == 0) return 0;
    return completedCount(course) / course.lessonCount;
  }

  int chapterCompleted(Chapter chapter) =>
      chapter.lessons.where((l) => isCompleted(l.id)).length;

  Lesson nextLesson(Course course) {
    final lessons = course.allLessons;
    for (final lesson in lessons) {
      final p = of(lesson.id);
      if (!p.completed && p.positionMs > 0) return lesson;
    }
    for (final lesson in lessons) {
      if (!isCompleted(lesson.id)) return lesson;
    }
    return lessons.first;
  }

  bool hasStarted(Course course) => course.allLessons.any((l) {
        final p = of(l.id);
        return p.completed || p.positionMs > 0;
      });

  Future<void> update(
    String lessonId, {
    required int positionMs,
    required int durationMs,
    bool? completed,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final current = of(lessonId);
    final reached = durationMs > 0 && positionMs >= durationMs * 0.9;
    _progress[lessonId] = current.copyWith(
      positionMs: positionMs,
      durationMs: durationMs,
      completed: completed ?? (current.completed || reached),
    );
    notifyListeners();
    await _repository.save(userId, _progress);
  }

  Future<void> setCompleted(String lessonId, bool completed) async {
    final userId = _userId;
    if (userId == null) return;
    final current = of(lessonId);
    _progress[lessonId] = current.copyWith(
      completed: completed,
      positionMs: completed ? current.positionMs : 0,
    );
    notifyListeners();
    await _repository.save(userId, _progress);
  }
}
