import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/theme_provider.dart';
import 'package:music_player/screens/favorites_screen.dart';
import 'package:music_player/widgets/error_view.dart';
import 'package:music_player/widgets/mini_player.dart';
import 'package:music_player/widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = context.read<MusicProvider>();
      if (musicProvider.tracks.isEmpty && !musicProvider.isLoading) {
        musicProvider.fetchInitialTracks();
      }
    });
  }


  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll - 250)) {
      context.read<MusicProvider>().fetchNextPage();
    }
  }

  /// Handle search submission
  void _handleSearch(String query) {
    context.read<MusicProvider>().search(query);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('M U S I C'),
            ],
          ),
          actions: [
            // Favorites screen shortcut
            IconButton(
              tooltip: 'Favorite Songs',
              icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            // Light/Dark Theme toggle
            IconButton(
              tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search songs or artists...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
      
            // Main Song List View / States
            Expanded(
              child: _buildBody(musicProvider),
            ),
      
            // Docked Mini Player
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(MusicProvider musicProvider) {
    // 1. Initial Loading State
    if (musicProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Error State
    if (musicProvider.errorMessage != null && musicProvider.tracks.isEmpty) {
      return ErrorView(
        message: musicProvider.errorMessage!,
        onRetry: () {
          musicProvider.fetchInitialTracks();
        },
      );
    }

    // 3. Empty State (no search results found)
    if (musicProvider.tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Songs Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with another keyword or explore different genres.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Success State with Pull-To-Refresh and Infinite Scroll Pagination
    return RefreshIndicator(
      onRefresh: () async {
        await musicProvider.fetchInitialTracks();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: musicProvider.tracks.length + 1, // +1 for pagination loader
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          // Bottom pagination indicator
          if (index == musicProvider.tracks.length) {
            if (musicProvider.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              );
            } else if (!musicProvider.hasMore && musicProvider.tracks.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "You've reached the end of the list",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }

          // Song tile item
          final track = musicProvider.tracks[index];
          return TrackTile(
            track: track,
            playlist: musicProvider.tracks,
          );
        },
      ),
    );
  }
}
