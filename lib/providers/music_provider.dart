import 'package:flutter/foundation.dart';
import 'package:music_player/core/constants/api_constants.dart';
import 'package:music_player/models/track_model.dart';
import 'package:music_player/services/api_service.dart';
import 'package:music_player/services/storage_service.dart';

class MusicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Track lists
  List<TrackModel> _tracks = [];
  List<TrackModel> _favorites = [];

  // State indicators
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination fields
  int _currentOffset = 0;
  bool _hasMore = true;

  // Search query
  String _searchQuery = '';

  MusicProvider() {
    _initialize();
  }

  // Load favorites and fetch initial songs from API
  Future<void> _initialize() async {
    await loadFavorites();
    await fetchInitialTracks();
  }

  // Getters
  List<TrackModel> get tracks => _tracks;
  List<TrackModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  Future<void> fetchInitialTracks() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOffset = 0;
    _hasMore = true;
    notifyListeners();

    try {
      List<TrackModel> fetched;
      if (_searchQuery.trim().isEmpty) {
        // Handle cold start network delay: retry once if network is still connecting
        try {
          fetched = await _apiService.getTracks(
            offset: 0,
            limit: ApiConstants.pageSize,
          );
        } catch (_) {
          await Future.delayed(const Duration(seconds: 1));
          fetched = await _apiService.getTracks(
            offset: 0,
            limit: ApiConstants.pageSize,
          );
        }
      } else {
        fetched = await _apiService.searchTracks(
          query: _searchQuery,
          offset: 0,
          limit: ApiConstants.pageSize,
        );
      }

      _tracks = fetched;
      _currentOffset = fetched.length;
      _hasMore = fetched.length >= ApiConstants.pageSize;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Could not load tracks. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    // Guard against duplicate requests or reaching the end of list
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      List<TrackModel> nextTracks;
      if (_searchQuery.trim().isEmpty) {
        nextTracks = await _apiService.getTracks(
          offset: _currentOffset,
          limit: ApiConstants.pageSize,
        );
      } else {
        nextTracks = await _apiService.searchTracks(
          query: _searchQuery,
          offset: _currentOffset,
          limit: ApiConstants.pageSize,
        );
      }

      if (nextTracks.isEmpty) {
        _hasMore = false;
      } else {
        _tracks.addAll(nextTracks);
        _currentOffset += nextTracks.length;
        // If received less than page size, we reached the end
        if (nextTracks.length < ApiConstants.pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading next page: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;

    _searchQuery = trimmed;
    await fetchInitialTracks();
  }

  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    await fetchInitialTracks();
  }

  Future<void> loadFavorites() async {
    _favorites = await StorageService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(TrackModel track) async {
    final existingIndex = _favorites.indexWhere((t) => t.id == track.id);
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(track);
    }
    await StorageService.saveFavorites(_favorites);
    notifyListeners();
  }

  bool isFavorite(TrackModel track) {
    return _favorites.any((t) => t.id == track.id);
  }
}
