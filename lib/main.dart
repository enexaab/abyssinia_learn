import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/download_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/connectivity_provider.dart';
import 'presentation/providers/course_provider.dart';
import 'presentation/providers/download_provider.dart';
import 'presentation/providers/progress_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = await StorageService.create();

  final auth = AuthProvider(AuthRepository(storage));
  final courses = CourseProvider(CourseRepository());
  final progress = ProgressProvider(ProgressRepository(storage));
  final downloads = DownloadProvider(DownloadRepository(storage));
  final connectivity = ConnectivityProvider();

  auth.addListener(() => progress.bindUser(auth.user?.id));

  await Future.wait([
    auth.initialize(),
    downloads.initialize(),
    connectivity.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<CourseProvider>.value(value: courses),
        ChangeNotifierProvider<ProgressProvider>.value(value: progress),
        ChangeNotifierProvider<DownloadProvider>.value(value: downloads),
        ChangeNotifierProvider<ConnectivityProvider>.value(value: connectivity),
      ],
      child: const AbyssiniaLearnApp(),
    ),
  );
}
