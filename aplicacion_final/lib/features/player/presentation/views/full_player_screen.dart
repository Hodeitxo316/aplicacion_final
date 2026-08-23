import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacion_final/core/constants/app_colors.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';
import 'package:aplicacion_final/features/player/presentation/providers/audio_player_provider.dart';

class FullPlayerScreen extends ConsumerWidget {
  final AudioTrack track;

  const FullPlayerScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final positionAsync = ref.watch(currentPositionStreamProvider);
    final isPlaying = playerStateAsync.value?.playing ?? false;

    final position = positionAsync.value ?? Duration.zero;
    final totalDuration = track.duration;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('REPRODUCIENDO DESDE YOUTUBE', style: TextStyle(fontSize: 12, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                track.thumbnailUrl,
                height: 320,
                width: 320,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 320,
                  width: 320,
                  color: AppColors.card,
                  child: const Icon(Icons.music_note, size: 100, color: Colors.white54),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white24,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: position.inSeconds.clamp(0, totalDuration.inSeconds).toDouble(),
                max: totalDuration.inSeconds > 0 ? totalDuration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  ref.read(audioHandlerProvider).seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(_formatDuration(totalDuration), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: () => ref.read(playerNotifierProvider.notifier).togglePlayPause(),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}