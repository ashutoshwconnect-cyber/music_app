import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_player/core/constants/api_constants.dart';
import 'package:music_player/models/track_model.dart';

class ApiService {
  // Fetch popular songs from Jamendo
  Future<List<TrackModel>> getTracks({int offset = 0, int limit = 20}) async {
    final url =
        '${ApiConstants.baseUrl}/tracks/?client_id=${ApiConstants.clientId}&format=json&limit=$limit&offset=$offset&order=popularity_total';

    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results.map((item) => TrackModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load songs');
  }

  // Search songs by name
  Future<List<TrackModel>> searchTracks({
    required String query,
    int offset = 0,
    int limit = 20,
  }) async {
    final url =
        '${ApiConstants.baseUrl}/tracks/?client_id=${ApiConstants.clientId}&format=json&namesearch=$query&limit=$limit&offset=$offset';

    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];
      return results.map((item) => TrackModel.fromJson(item)).toList();
    }
    throw Exception('Failed to search songs');
  }
}
