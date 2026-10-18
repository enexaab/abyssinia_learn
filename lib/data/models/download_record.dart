enum DownloadStatus { none, queued, downloading, completed, failed }

class DownloadRecord {
  final String lessonId;
  final String courseId;
  final String filePath;
  final int totalBytes;
  final DateTime completedAt;

  const DownloadRecord({
    required this.lessonId,
    required this.courseId,
    required this.filePath,
    required this.totalBytes,
    required this.completedAt,
  });

  factory DownloadRecord.fromJson(Map<String, dynamic> json) {
    return DownloadRecord(
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      filePath: json['filePath'] as String,
      totalBytes: json['totalBytes'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'filePath': filePath,
      'totalBytes': totalBytes,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final int receivedBytes;
  final int totalBytes;
  final String? error;

  const DownloadState({
    this.status = DownloadStatus.none,
    this.progress = 0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.error,
  });

  bool get isActive =>
      status == DownloadStatus.queued || status == DownloadStatus.downloading;

  bool get isCompleted => status == DownloadStatus.completed;

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    int? receivedBytes,
    int? totalBytes,
    String? error,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error,
    );
  }
}
