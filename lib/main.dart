import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmatch/features/game/presentation/providers/game_provider.dart';
import 'features/game/presentation/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  final saveDir = Directory('${appDir.path}/tmatch_saves');
  if (!await saveDir.exists()) {
    await saveDir.create(recursive: true);
  }

  runApp(ProviderScope(
    overrides: [
      saveDirProvider.overrideWithValue(saveDir.path),
    ],
    child: const TMatchApp(),
  ));
}

class TMatchApp extends StatelessWidget {
  const TMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triple Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
