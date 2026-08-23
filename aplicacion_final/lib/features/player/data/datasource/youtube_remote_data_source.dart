import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioStreamData {
  final String url;
  final DateTime expiresAt;

  AudioStreamData({required this.url, required this.expiresAt});
}

abstract class YouTubeRemoteDataSource {
  Future<List<Video>> searchVideos(String query);
  Future<AudioStreamData> getAudioStreamInfo(String videoId);
}

class YouTubeRemoteDataSourceImpl implements YouTubeRemoteDataSource {
  final YoutubeExplode _yt;

  YouTubeRemoteDataSourceImpl({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  @override
  Future<List<Video>> searchVideos(String query) async {
    try {
      final searchList = await _yt.search.search(query);
      return searchList.whereType<Video>().toList();
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }

  @override
  Future<AudioStreamData> getAudioStreamInfo(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioOnlyStreams = manifest.audioOnly;

      if (audioOnlyStreams.isEmpty) {
        throw Exception('No audio streams found for video $videoId');
      }

      final bestAudioStream = audioOnlyStreams.withHighestBitrate();
      final streamUrl = bestAudioStream.url.toString();

      final uri = Uri.parse(streamUrl);
      final expireParam = uri.queryParameters['expire'];

      DateTime expiresAt;
      if (expireParam != null) {
        final seconds = int.tryParse(expireParam);
        if (seconds != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } else {
          expiresAt = DateTime.now().add(const Duration(hours: 5));
        }
      } else {
        expiresAt = DateTime.now().add(const Duration(hours: 5));
      }

      return AudioStreamData(
        url: streamUrl,
        expiresAt: expiresAt,
      );
    } catch (e) {
      throw Exception('Error extracting audio stream: $e');
    }
  }
}