import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/models/track_model.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  TrackModel? _currentTrack;
  List<TrackModel> _playlist = [];
  int _currentIndex = -1;

  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isShuffle = false;
  bool _isRepeat = false;
  String? _playerError;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPlayerProvider() {
    _initAudioStreams();
  }

  TrackModel? get currentTrack => _currentTrack;
  List<TrackModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  String? get playerError => _playerError;

  void _initAudioStreams() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering =
          state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;

      if (state.processingState == ProcessingState.completed) {
        if (_isRepeat) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          playNext();
        }
      }
      notifyListeners();
    });

    _positionSubscription = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSubscription = _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> playTrack(TrackModel track, {List<TrackModel>? playlist}) async {
    _playerError = null;

    if (playlist != null && playlist.isNotEmpty) {
      _playlist = List.from(playlist);
      _currentIndex = _playlist.indexWhere((t) => t.id == track.id);
    } else if (!_playlist.contains(track)) {
      _playlist.add(track);
      _currentIndex = _playlist.length - 1;
    } else {
      _currentIndex = _playlist.indexOf(track);
    }

    _currentTrack = track;
    _position = Duration.zero;
    _duration = Duration(seconds: track.duration);
    _isBuffering = true;
    notifyListeners();

    try {
      if (track.audioUrl.isEmpty) {
        throw Exception('Audio stream URL is not available for this track.');
      }

      await _player.stop();
      await _player.setUrl(track.audioUrl);
      await _player.play();
    } catch (e) {
      _playerError = 'Could not play audio: $e';
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration newPosition) async {
    await _player.seek(newPosition);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    if (_isShuffle && _playlist.length > 1) {
      int randomIndex;
      final random = Random();
      do {
        randomIndex = random.nextInt(_playlist.length);
      } while (randomIndex == _currentIndex);
      _currentIndex = randomIndex;
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    final nextTrack = _playlist[_currentIndex];
    await playTrack(nextTrack);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1;
    }

    final previousTrack = _playlist[_currentIndex];
    await playTrack(previousTrack);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    if (_isRepeat) {
      _player.setLoopMode(LoopMode.one);
    } else {
      _player.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
