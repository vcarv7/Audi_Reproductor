import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, info }

class StyledSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = switch (type) {
      SnackbarType.success => const Color(0xFF4CAF50),
      SnackbarType.error => AppTheme.accent,
      SnackbarType.info => const Color(0xFF2196F3),
    };
    final icon = switch (type) {
      SnackbarType.success => Icons.check_circle_rounded,
      SnackbarType.error => Icons.error_outline_rounded,
      SnackbarType.info => Icons.info_outline_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
          duration: duration,
        ),
      );
  }
}
