import 'dart:ui';

class CourseThumbnail {
  final String art;
  final List<Color> colors;

  const CourseThumbnail({required this.art, required this.colors});

  factory CourseThumbnail.fromJson(Map<String, dynamic> json) {
    final hexes = (json['colors'] as List).cast<String>();
    return CourseThumbnail(
      art: json['art'] as String,
      colors: hexes.map(_parseHex).toList(),
    );
  }

  static Color _parseHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;
  final bool downloadable;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.videoUrl,
    required this.downloadable,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      durationSeconds: json['durationSeconds'] as int,
      videoUrl: json['videoUrl'] as String,
      downloadable: (json['downloadable'] as bool?) ?? true,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final List<Lesson> lessons;

  const Chapter({
    required this.id,
    required this.title,
    required this.lessons,
  });

  int get totalSeconds =>
      lessons.fold(0, (sum, lesson) => sum + lesson.durationSeconds);

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final String instructor;
  final CourseThumbnail thumbnail;
  final List<Chapter> chapters;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.instructor,
    required this.thumbnail,
    required this.chapters,
  });

  int get chapterCount => chapters.length;

  List<Lesson> get allLessons =>
      chapters.expand((chapter) => chapter.lessons).toList();

  int get lessonCount => allLessons.length;

  int get totalSeconds =>
      chapters.fold(0, (sum, chapter) => sum + chapter.totalSeconds);

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      instructor: json['instructor'] as String,
      thumbnail:
          CourseThumbnail.fromJson(json['thumbnail'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List)
          .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonRef {
  final Course course;
  final Chapter chapter;
  final Lesson lesson;

  const LessonRef({
    required this.course,
    required this.chapter,
    required this.lesson,
  });
}
