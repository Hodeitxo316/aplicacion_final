import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';
import 'package:aplicacion_final/features/player/data/datasources/youtube_remote_data_source.dart';
import 'package:aplicacion_final/features/player/data/repositories/audio_repository_impl.dart';

abstract class AudioRepository {
  Future<List<AudioTrack>> searchTracks(String query);
  Future<String> getDirectAudioStreamUrl(String trackId);
  Future<AudioTrack> ensureValidStream(AudioTrack track);
}

// Inyección de dependencias con Riverpod
final youtubeRemoteDataSourceProvider = Provider<YouTubeRemoteDataSource>((ref) {
  return YouTubeRemoteDataSourceImpl();
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final remoteDataSource = ref.watch(youtubeRemoteDataSourceProvider);
  return AudioRepositoryImpl(remoteDataSource: remoteDataSource);
});