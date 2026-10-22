import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:music_player/screens/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:music_player/providers/audio_player_provider.dart';
import 'package:music_player/providers/music_provider.dart';
import 'package:music_player/providers/theme_provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

    return GetMaterialApp(
      title: 'SoundWave Music Player',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      home: const AuthWrapper(),
    );
  }
}
