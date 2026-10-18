class LessonProgress {
  final int positionMs;
  final int durationMs;
  final bool completed;

  const LessonProgress({
    this.positionMs = 0,
    this.durationMs = 0,
    this.completed = false,
  });

  double get fraction {
    if (completed) return 1;
    if (durationMs <= 0) return 0;
    return (positionMs / durationMs).clamp(0.0, 1.0);
  }

  LessonProgress copyWith({int? positionMs, int? durationMs, bool? completed}) {
    return LessonProgress(
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      completed: completed ?? this.completed,
    );
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      positionMs: (json['positionMs'] as int?) ?? 0,
      durationMs: (json['durationMs'] as int?) ?? 0,
      completed: (json['completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positionMs': positionMs,
      'durationMs': durationMs,
      'completed': completed,
    };
  }
}
