import '../models/lesson_progress.dart';
import '../services/storage_service.dart';

class ProgressRepository {
  final StorageService _storage;

  ProgressRepository(this._storage);

  String _key(String userId) => 'progress_$userId';

  Map<String, LessonProgress> load(String userId) {
    final data = _storage.getJson(_key(userId));
    if (data is! Map) return {};
    final result = <String, LessonProgress>{};
    data.forEach((key, value) {
      if (value is Map) {
        result[key as String] =
            LessonProgress.fromJson(Map<String, dynamic>.from(value));
      }
    });
    return result;
  }

  Future<void> save(String userId, Map<String, LessonProgress> progress) {
    final encoded = progress.map((k, v) => MapEntry(k, v.toJson()));
    return _storage.setJson(_key(userId), encoded);
  }
}
