class AudioFile {
  final String id;
  final String path;
  final String name;
  final String? artist;
  final Duration? duration;

  AudioFile({
    required this.id,
    required this.path,
    required this.name,
    this.artist,
    this.duration,
  });

  String get displayName {
    if (artist != null && artist!.isNotEmpty) {
      return '$artist - $name';
    }
    return name;
  }

  String get fileName => path.split(RegExp(r'[/\\]')).last;

  AudioFile copyWith({
    String? id,
    String? path,
    String? name,
    String? artist,
    Duration? duration,
  }) {
    return AudioFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
    );
  }
}