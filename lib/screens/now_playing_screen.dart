import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/audio_player_provider.dart';
import 'package:music_player/providers/music_provider.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  // Local state for dragging the slider smoothly
  double? _dragValue;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final secondsString = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutes:$secondsString';
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final musicProvider = context.watch<MusicProvider>();
    final currentTrack = audioProvider.currentTrack;
    final theme = Theme.of(context);

    // If for any reason no track is selected, go back
    if (currentTrack == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No song currently playing')),
      );
    }

    final isFav = musicProvider.isFavorite(currentTrack);
    final position = audioProvider.position;
    final duration = audioProvider.duration;

    // Current slider position in seconds
    final currentSeconds = _dragValue ?? position.inSeconds.toDouble();
    final totalSeconds = duration.inSeconds.toDouble();
    final maxSliderValue = totalSeconds > 0 ? totalSeconds : 1.0;
    final sliderValue = currentSeconds.clamp(0.0, maxSliderValue);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.redAccent : theme.iconTheme.color,
            ),
            onPressed: () {
              musicProvider.toggleFavorite(currentTrack);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive artwork sizing based on available screen height
            final artSize = (constraints.maxHeight * 0.40).clamp(200.0, 340.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Large Album Artwork
                    Center(
                      child: Container(
                        width: artSize,
                        height: artSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: currentTrack.displayImage.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: currentTrack.displayImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.surface,
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 80,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: theme.colorScheme.surface,
                                        child: const Icon(
                                          Icons.music_note,
                                          size: 80,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: theme.colorScheme.surface,
                                  child: const Icon(Icons.music_note, size: 80),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Song Title & Artist Name
                    Column(
                      children: [
                        Text(
                          currentTrack.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentTrack.artistName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                        if (currentTrack.albumName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            currentTrack.albumName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Seek / Progress Bar Slider
                    Column(
                      children: [
                        Slider(
                          min: 0.0,
                          max: maxSliderValue,
                          value: sliderValue,
                          onChanged: (val) {
                            setState(() {
                              _dragValue = val;
                            });
                          },
                          onChangeEnd: (val) {
                            audioProvider.seek(Duration(seconds: val.toInt()));
                            setState(() {
                              _dragValue = null;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Current playback elapsed time
                              Text(
                                _formatDuration(
                                  _dragValue != null
                                      ? Duration(seconds: _dragValue!.toInt())
                                      : position,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                              // Total song duration
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Playback Controls Row: Shuffle, Prev, Play/Pause, Next, Repeat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle Button
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: audioProvider.isShuffle
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color?.withValues(alpha: 0.4),
                          ),
                          iconSize: 26,
                          onPressed: () {
                            audioProvider.toggleShuffle();
                          },
                        ),

                        // Previous Song Button
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded),
                          iconSize: 38,
                          onPressed: () {
                            audioProvider.playPrevious();
                          },
                        ),

                        // Big Play / Pause Button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: audioProvider.isBuffering
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    audioProvider.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                  iconSize: 42,
                                  onPressed: () {
                                    audioProvider.togglePlayPause();
                                  },
                                ),
                        ),

                        // Next Song Button
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          iconSize: 38,
                          onPressed: () {
                            audioProvider.playNext();
                          },
                        ),

                        // Repeat Button
                        IconButton(
                          icon: Icon(
                            Icons.repeat_rounded,
                            color: audioProvider.isRepeat
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color?.withValues(alpha: 0.4),
                          ),
                          iconSize: 26,
                          onPressed: () {
                            audioProvider.toggleRepeat();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
