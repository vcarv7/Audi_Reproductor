import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/vinyl_disc.dart';

class VinylScanState extends StatelessWidget {
  final int count;

  const VinylScanState({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const VinylDisc(isPlaying: true, size: 140),
            const SizedBox(height: 32),
            const Text(
              'Escaneando tu música...',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '$count ${count == 1 ? 'canción encontrada' : 'canciones encontradas'}',
                key: ValueKey(count),
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
