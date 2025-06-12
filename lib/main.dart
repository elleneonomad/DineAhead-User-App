import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Async/async_app.dart';
import 'Providers/fav_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteManager(),
      child: asyncApp(),
    ),
    
  );
}
