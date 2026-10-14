class TrackModel {
  final String id;
  final String name;
  final int duration; // Duration in seconds
  final String artistId;
  final String artistName;
  final String albumName;
  final String albumImage;
  final String image;
  final String audioUrl;
  final String shareUrl;

  TrackModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.artistId,
    required this.artistName,
    required this.albumName,
    required this.albumImage,
    required this.image,
    required this.audioUrl,
    required this.shareUrl,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Track',
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      artistId: json['artist_id']?.toString() ?? '',
      artistName: json['artist_name']?.toString() ?? 'Unknown Artist',
      albumName: json['album_name']?.toString() ?? '',
      albumImage: json['album_image']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      audioUrl: json['audio']?.toString() ?? '',
      shareUrl: json['shareurl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'artist_id': artistId,
      'artist_name': artistName,
      'album_name': albumName,
      'album_image': albumImage,
      'image': image,
      'audio': audioUrl,
      'shareurl': shareUrl,
    };
  }

  String get displayImage {
    if (image.isNotEmpty) return image;
    if (albumImage.isNotEmpty) return albumImage;
    return '';
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    final secondsString = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutes:$secondsString';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
