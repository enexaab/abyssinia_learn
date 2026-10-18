import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class CourseRepository {
  static const String _asset = 'assets/data/courses.json';

  List<Course>? _cache;

  Future<List<Course>> fetchCourses({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final raw = await rootBundle.loadString(_asset);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (data['courses'] as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
