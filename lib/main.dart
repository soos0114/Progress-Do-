import 'dart:async';

import 'package:flutter/material.dart';

import 'services/notifications.dart';
import 'services/voice.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.init();
  unawaited(Voice.preload()); // 着信音を先読み（起動はブロックしない）
  await appState.load();
  await Notifications.handleLaunch(); // 通知から起動された場合に着信へ
  runApp(const KizumeApp());
}

class KizumeApp extends StatelessWidget {
  const KizumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progress-Do',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C6EF5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF12151C),
      ),
      home: const HomeScreen(),
    );
  }
}
