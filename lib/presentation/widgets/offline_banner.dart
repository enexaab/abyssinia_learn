import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/connectivity_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: online
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are offline. Downloaded lessons are still available.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
