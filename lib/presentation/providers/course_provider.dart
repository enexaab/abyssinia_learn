import 'package:flutter/foundation.dart';
import '../../data/models/course.dart';
import '../../data/repositories/course_repository.dart';

enum LoadStatus { idle, loading, loaded, error }

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<Course> _courses = [];
  String _query = '';
  String _category = 'All';
  String? _error;

  LoadStatus get status => _status;
  List<Course> get courses => _courses;
  String get query => _query;
  String get category => _category;
  String? get error => _error;

  List<String> get categories {
    final set = <String>{'All'};
    for (final course in _courses) {
      set.add(course.category);
    }
    return set.toList();
  }

  List<Course> get filtered {
    final q = _query.trim().toLowerCase();
    return _courses.where((course) {
      if (_category != 'All' && course.category != _category) return false;
      if (q.isEmpty) return true;
      if (course.title.toLowerCase().contains(q)) return true;
      if (course.description.toLowerCase().contains(q)) return true;
      if (course.instructor.toLowerCase().contains(q)) return true;
      return course.allLessons.any((l) => l.title.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> load({bool force = false}) async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _courses = await _repository.fetchCourses(forceRefresh: force);
      _status = LoadStatus.loaded;
    } catch (_) {
      _error = 'We could not load the courses. Please try again.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = 'All';
    notifyListeners();
  }

  Course? courseById(String id) {
    for (final course in _courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  LessonRef? refForLesson(String lessonId) {
    for (final course in _courses) {
      for (final chapter in course.chapters) {
        for (final lesson in chapter.lessons) {
          if (lesson.id == lessonId) {
            return LessonRef(course: course, chapter: chapter, lesson: lesson);
          }
        }
      }
    }
    return null;
  }
}
