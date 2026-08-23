import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacion_final/core/constants/app_colors.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';
import 'package:aplicacion_final/features/player/domain/repositories/audio_repository.dart';
import 'package:aplicacion_final/features/player/presentation/providers/audio_player_provider.dart';
import 'package:aplicacion_final/features/player/presentation/views/widgets/mini_player_widget.dart';

final searchQueryProvider = StateProvider<String>((ref) => 'Spotify Hits');

final searchResultsProvider = FutureProvider<List<AudioTrack>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.watch(audioRepositoryProvider);
  return repo.searchTracks(query);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: TextField(
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Buscar en YouTube Music...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppColors.primary),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = value.trim();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          searchResult.when(
            data: (tracks) => ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return ListTile(
                  leading: Image.network(track.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary), maxLines: 1),
                  subtitle: Text(track.artist, style: const TextStyle(color: AppColors.textSecondary), maxLines: 1),
                  onTap: () {
                    ref.read(playerNotifierProvider.notifier).playTrack(track);
                  },
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayerWidget(),
          ),
        ],
      ),
    );
  }
}