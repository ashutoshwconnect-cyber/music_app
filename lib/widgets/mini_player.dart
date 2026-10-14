import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/audio_player_provider.dart';
import 'package:music_player/screens/now_playing_screen.dart';

/// MiniPlayer is displayed at the bottom of the screen whenever a song is loaded.
/// Tapping it opens the full NowPlayingScreen.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final currentTrack = audioProvider.currentTrack;

    // Do not show mini player if no track is selected
    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final position = audioProvider.position;
    final duration = audioProvider.duration;

    // Calculate playback progress ratio (between 0.0 and 1.0)
    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        // Open full player screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NowPlayingScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar line at top
              LinearProgressIndicator(
                value: progress,
                minHeight: 2.5,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    // Artwork thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: currentTrack.displayImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: currentTrack.displayImage,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.scaffoldBackgroundColor,
                                  child: const Icon(Icons.music_note, size: 20),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.scaffoldBackgroundColor,
                                  child: const Icon(Icons.music_note, size: 20),
                                ),
                              )
                            : Container(
                                color: theme.scaffoldBackgroundColor,
                                child: const Icon(Icons.music_note, size: 20),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Song title and artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentTrack.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentTrack.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Play/Pause button
                    if (audioProvider.isBuffering)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          audioProvider.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          color: theme.colorScheme.primary,
                          size: 34,
                        ),
                        onPressed: () {
                          audioProvider.togglePlayPause();
                        },
                      ),

                    // Skip next button
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 28),
                      onPressed: () {
                        audioProvider.playNext();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
