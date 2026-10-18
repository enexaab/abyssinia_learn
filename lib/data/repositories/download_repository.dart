import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/course.dart';
import '../models/download_record.dart';
import '../services/storage_service.dart';

class DownloadException implements Exception {
  final String message;

  const DownloadException(this.message);

  @override
  String toString() => message;
}

class DownloadRepository {
  static const String _recordsKey = 'download_records';

  final StorageService _storage;
  final Dio _dio;

  DownloadRepository(this._storage, {Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(minutes: 5),
                followRedirects: true,
              ),
            );

  Future<Directory> _downloadsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<DownloadRecord>> loadRecords() async {
    final data = _storage.getJson(_recordsKey);
    if (data is! List) return [];
    final records = data
        .whereType<Map>()
        .map((e) => DownloadRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final valid = <DownloadRecord>[];
    for (final record in records) {
      if (await File(record.filePath).exists()) valid.add(record);
    }
    if (valid.length != records.length) {
      await saveRecords(valid);
    }
    return valid;
  }

  Future<void> saveRecords(List<DownloadRecord> records) {
    return _storage.setJson(
      _recordsKey,
      records.map((r) => r.toJson()).toList(),
    );
  }

  Future<DownloadRecord> download({
    required Lesson lesson,
    required String courseId,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    final dir = await _downloadsDir();
    final finalPath = '${dir.path}/${lesson.id}.mp4';
    final partPath = '$finalPath.part';
    final partFile = File(partPath);

    try {
      await _dio.download(
        lesson.videoUrl,
        partPath,
        cancelToken: cancelToken,
        deleteOnError: true,
        onReceiveProgress: onProgress,
      );
      final target = File(finalPath);
      if (await target.exists()) await target.delete();
      await partFile.rename(finalPath);
      final size = await File(finalPath).length();
      if (size == 0) {
        await File(finalPath).delete();
        throw const DownloadException('The downloaded file was empty.');
      }
      return DownloadRecord(
        lessonId: lesson.id,
        courseId: courseId,
        filePath: finalPath,
        totalBytes: size,
        completedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (await partFile.exists()) await partFile.delete();
      if (CancelToken.isCancel(e)) {
        throw const DownloadException('Download cancelled.');
      }
      throw DownloadException(_describe(e));
    } on FileSystemException {
      if (await partFile.exists()) await partFile.delete();
      throw const DownloadException(
        'Could not save the file. Check your device storage.',
      );
    }
  }

  Future<void> deleteFile(DownloadRecord record) async {
    final file = File(record.filePath);
    if (await file.exists()) await file.delete();
  }

  String _describe(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'The server responded with an error (${e.response?.statusCode}).';
      default:
        return 'Download failed. Please try again.';
    }
  }
}
