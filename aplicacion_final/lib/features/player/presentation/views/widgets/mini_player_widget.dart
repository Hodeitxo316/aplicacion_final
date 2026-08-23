import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacion_final/core/constants/app_colors.dart';
import 'package:aplicacion_final/features/player/presentation/providers/audio_player_provider.dart';
import 'package:aplicacion_final/features/player/presentation/views/full_player_screen.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrackAsync = ref.watch(playerNotifierProvider);
    final playerStateAsync = ref.watch(playerStateStreamProvider);

    return currentTrackAsync.when(
      data: (track) {
        if (track == null) return const SizedBox.shrink();

        final isPlaying = playerStateAsync.value?.playing ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FullPlayerScreen(track: track)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: Image.network(
                    track.thumbnailUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey, width: 60, height: 60),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.artist,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => ref.read(playerNotifierProvider.notifier).togglePlayPause(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 60,
        margin: const EdgeInsets.all(8),
        color: AppColors.card,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}