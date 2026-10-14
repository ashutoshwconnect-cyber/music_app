import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:music_player/models/track_model.dart';
import 'package:music_player/providers/audio_player_provider.dart';
import 'package:music_player/providers/music_provider.dart';

/// TrackTile displays a single song in the list with artwork,
/// title, artist, duration, favorite button, and playing indicator.
class TrackTile extends StatelessWidget {
  final TrackModel track;
  final List<TrackModel> playlist;

  const TrackTile({
    super.key,
    required this.track,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final musicProvider = context.watch<MusicProvider>();

    final isCurrent = audioProvider.currentTrack?.id == track.id;
    final isPlaying = isCurrent && audioProvider.isPlaying;
    final isFav = musicProvider.isFavorite(track);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        audioProvider.playTrack(track, playlist: playlist);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Track artwork thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: track.displayImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.displayImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surface,
                          child: const Icon(Icons.music_note, size: 24),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surface,
                          child: const Icon(Icons.music_note, size: 24),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surface,
                        child: const Icon(Icons.music_note, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Song title and artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Playing animation or duration
            if (isPlaying)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.equalizer_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              )
            else
              Text(
                track.formattedDuration,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),

            // Favorite button
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : theme.iconTheme.color?.withValues(alpha: 0.4),
                size: 20,
              ),
              onPressed: () {
                musicProvider.toggleFavorite(track);
              },
            ),
          ],
        ),
      ),
    );
  }
}
