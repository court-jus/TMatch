import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmatch/core/storage/file_save_storage.dart';
import 'package:tmatch/core/storage/web_save_storage.dart';
import 'package:tmatch/features/game/data/game_repository.dart';
import 'package:tmatch/features/game/presentation/providers/game_provider.dart';
import 'features/game/presentation/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final gameRepository = await _createGameRepository();

  runApp(
    ProviderScope(
      overrides: [gameRepositoryProvider.overrideWith((ref) => gameRepository)],
      child: const TMatchApp(),
    ),
  );
}

Future<GameRepository> _createGameRepository() async {
  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    return GameRepository(WebSaveStorage(prefs));
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${appDir.path}/tmatch_saves');
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
    return GameRepository(FileSaveStorage(saveDir.path));
  }
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
