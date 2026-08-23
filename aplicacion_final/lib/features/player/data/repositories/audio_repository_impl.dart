import 'package:aplicacion_final/features/player/data/datasources/youtube_remote_data_source.dart';
import 'package:aplicacion_final/features/player/domain/entities/audio_track.dart';
import 'package:aplicacion_final/features/player/domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final YouTubeRemoteDataSource remoteDataSource;

  AudioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AudioTrack>> searchTracks(String query) async {
    final videos = await remoteDataSource.searchVideos(query);

    return videos.map((video) {
      final thumbnail = video.thumbnails.maxResUrl.isNotEmpty
          ? video.thumbnails.maxResUrl
          : video.thumbnails.highResUrl;

      return AudioTrack(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        thumbnailUrl: thumbnail,
        duration: video.duration ?? Duration.zero,
      );
    }).toList();
  }

  @override
  Future<String> getDirectAudioStreamUrl(String trackId) async {
    final streamData = await remoteDataSource.getAudioStreamInfo(trackId);
    return streamData.url;
  }

  @override
  Future<AudioTrack> ensureValidStream(AudioTrack track) async {
    if (track.streamUrl != null && !track.isStreamExpired) {
      return track;
    }

    final streamData = await remoteDataSource.getAudioStreamInfo(track.id);

    return track.copyWith(
      streamUrl: streamData.url,
      expiresAt: streamData.expiresAt,
    );
  }
}