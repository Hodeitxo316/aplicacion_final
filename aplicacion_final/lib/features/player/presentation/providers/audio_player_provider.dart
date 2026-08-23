import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:aplicacion_final/core/audio/app_audio_handler.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';
import 'package:aplicacion_final/features/player/domain/repositories/audio_repository.dart';

// Provider global para la instancia del handler de audio
final audioHandlerProvider = Provider<AppAudioHandler>((ref) {
  throw UnimplementedError('AudioHandler no ha sido inicializado en main.dart');
});

// StateNotifier para controlar la pista actual y el estado de carga
class PlayerNotifier extends StateNotifier<AsyncValue<AudioTrack?>> {
  final AppAudioHandler _audioHandler;
  final AudioRepository _repository;

  PlayerNotifier(this._audioHandler, this._repository) : super(const AsyncValue.data(null));

  Future<void> playTrack(AudioTrack track) async {
    state = const AsyncValue.loading();
    try {
      // Garantizar que tenemos una URL válida y no expirada
      final trackWithStream = await _repository.ensureValidStream(track);
      
      if (trackWithStream.streamUrl != null) {
        await _audioHandler.playTrack(trackWithStream, trackWithStream.streamUrl!);
        state = AsyncValue.data(trackWithStream);
      } else {
        state = AsyncValue.error('No se pudo extraer la URL del stream', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void togglePlayPause() {
    if (_audioHandler.player.playing) {
      _audioHandler.pause();
    } else {
      _audioHandler.play();
    }
  }
}

final playerNotifierProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<AudioTrack?>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  final repository = ref.watch(audioRepositoryProvider);
  return PlayerNotifier(handler, repository);
});

// Streams optimizados para consumo directo en UI (60 FPS sin rebuilds pesados)
final playerStateStreamProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState.stream;
});

final currentPositionStreamProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.player.positionStream;
});