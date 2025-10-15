import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Async/async_app.dart';
import 'Providers/fav_manager.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Log init errors but do not crash the app
    debugPrint('Firebase init failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteManager(),
      child: asyncApp(),
    ),
  );
}
