import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/audio_player_provider.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/theme_provider.dart';
import 'package:music_player/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
      ],
      child: const MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SoundWave Music Player',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      home: const HomeScreen(),
    );
  }
}

