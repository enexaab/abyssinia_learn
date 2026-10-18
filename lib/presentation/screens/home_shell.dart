import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/course_provider.dart';
import '../providers/download_provider.dart';
import '../widgets/offline_banner.dart';
import 'courses_screen.dart';
import 'downloads_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourseProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDownloads =
        context.select<DownloadProvider, int>((d) => d.activeLessonIds.length);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                CoursesScreen(),
                DownloadsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppColors.primaryLight,
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon:
                  Icon(Icons.grid_view_rounded, color: AppColors.primaryDark),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: activeDownloads > 0,
                label: Text('$activeDownloads'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.download_for_offline_outlined),
              ),
              selectedIcon: const Icon(Icons.download_for_offline_rounded,
                  color: AppColors.primaryDark),
              label: 'Downloads',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppColors.primaryDark),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
