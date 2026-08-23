import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AppAudioHandler() {
    _init();
  }

  void _init() {
    // Sincronizar el estado de just_audio con audio_service para las notificaciones del sistema
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });
  }

  /// Carga y reproduce una pista directamente desde la URL extraída
  Future<void> playTrack(AudioTrack track, String directUrl) async {
    final item = MediaItem(
      id: track.id,
      album: 'YouTube Music',
      title: track.title,
      artist: track.artist,
      duration: track.duration,
      artUri: Uri.parse(track.thumbnailUrl),
      extras: {'url': directUrl},
    );

    mediaItem.add(item);

    try {
      await _player.setUrl(directUrl);
      _player.play();
    } catch (e) {
      throw Exception("Error cargando la fuente de audio: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Expone el reproductor subyacente para los streamings directos de UI
  AudioPlayer get player => _player;
}