class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String? streamUrl;
  final Duration duration;
  final DateTime? expiresAt;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.streamUrl,
    required this.duration,
    this.expiresAt,
  });

  bool get isStreamExpired {
    if (expiresAt == null) return true;
    // Margen de seguridad de 30 segundos previo a la expiración real
    return DateTime.now().isAfter(expiresAt!.subtract(const Duration(seconds: 30)));
  }

  AudioTrack copyWith({
    String? streamUrl,
    DateTime? expiresAt,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      duration: duration,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}