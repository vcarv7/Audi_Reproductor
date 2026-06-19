class Artist {
  final int id;
  final String name;
  final int trackCount;
  final int albumCount;
  final bool isUnknown;

  const Artist({
    required this.id,
    required this.name,
    this.trackCount = 0,
    this.albumCount = 0,
    this.isUnknown = false,
  });

  String get displayName => isUnknown ? 'Artista desconocido' : name;
}

class Album {
  final int id;
  final String name;
  final String? artistName;
  final int trackCount;
  final bool isUnknown;

  const Album({
    required this.id,
    required this.name,
    this.artistName,
    this.trackCount = 0,
    this.isUnknown = false,
  });

  String get displayName => isUnknown ? 'Álbum desconocido' : name;
  String get displayArtist => isUnknown
      ? 'Artista desconocido'
      : (artistName ?? 'Artista desconocido');
}

class Genre {
  final int id;
  final String name;
  final int trackCount;
  final bool isUnknown;

  const Genre({
    required this.id,
    required this.name,
    this.trackCount = 0,
    this.isUnknown = false,
  });

  String get displayName => isUnknown ? 'Género desconocido' : name;
}