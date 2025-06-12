import 'package:flutter/material.dart';
import '../Models/restaurants.dart';

class FavoriteManager extends ChangeNotifier {
  final List<Restaurant> _favorites = [];

  List<Restaurant> get favorites => _favorites;

  bool isFavorite(Restaurant restaurant) {
    return _favorites.contains(restaurant);
  }

  void toggleFavorite(Restaurant restaurant) {
    if (isFavorite(restaurant)) {
      _favorites.remove(restaurant);
    } else {
      _favorites.add(restaurant);
    }
    notifyListeners();
  }
}
