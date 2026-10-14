import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/models/track_model.dart';
import 'package:music_player/core/constants/api_constants.dart';
import 'package:music_player/services/api_service.dart';

void main() {
  group('TrackModel Tests', () {
    test('TrackModel parses JSON correctly', () {
      final json = {
        'id': '101',
        'name': 'Test Track',
        'duration': 195,
        'artist_id': '50',
        'artist_name': 'Test Artist',
        'album_name': 'Test Album',
        'album_image': 'https://example.com/album.jpg',
        'image': 'https://example.com/track.jpg',
        'audio': 'https://example.com/audio.mp3',
        'shareurl': 'https://example.com/share',
      };

      final track = TrackModel.fromJson(json);

      expect(track.id, '101');
      expect(track.name, 'Test Track');
      expect(track.duration, 195);
      expect(track.artistName, 'Test Artist');
      expect(track.formattedDuration, '3:15');
      expect(track.displayImage, 'https://example.com/track.jpg');
    });

    test('TrackModel toJson and fromJson roundtrip works', () {
      final track = TrackModel(
        id: '102',
        name: 'Another Song',
        duration: 65,
        artistId: '10',
        artistName: 'Musician',
        albumName: 'EP',
        albumImage: '',
        image: 'https://example.com/cover.png',
        audioUrl: 'https://example.com/song.mp3',
        shareUrl: 'https://example.com',
      );

      final map = track.toJson();
      final reconstructed = TrackModel.fromJson(map);

      expect(reconstructed.id, track.id);
      expect(reconstructed.name, track.name);
      expect(reconstructed.formattedDuration, '1:05');
    });
  });

  group('ApiConstants Tests', () {
    test('Default Client ID is present', () {
      expect(ApiConstants.clientId.isNotEmpty, true);
      expect(ApiConstants.pageSize, 20);
    });
  });

  group('ApiService Tests', () {
    test('getTracks fetches real tracks from Jamendo', () async {
      final service = ApiService();
      final tracks = await service.getTracks(limit: 5);
      expect(tracks.isNotEmpty, true);
    });
  });
}
