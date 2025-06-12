import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../Providers/fav_manager.dart';
import '../Pages/restaurant_details_page.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteManager>(context).favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorite Restaurants",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6F00),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFFFF6F00)),
        elevation: 3,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorite restaurants yet."))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final restaurant = favorites[index];

                return Slidable(
                  key: ValueKey(restaurant.name),
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          // Swipe right to hide doesn't need code — built-in
                        },
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black54,
                        icon: Icons.arrow_back,
                        label: 'Hide',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () {
                        Provider.of<FavoriteManager>(context, listen: false)
                            .toggleFavorite(restaurant);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${restaurant.name} removed from favorites")),
                        );
                      },
                    ),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          // do nothing here, let swipe again remove it
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Remove',
                      ),
                    ],
                  ),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.asset(restaurant.imagePath, width: 50),
                      title: Text(restaurant.name),
                      subtitle: Text("Rating: ${restaurant.rating}"),
                      trailing: TextButton(
                        onPressed: () {
                          Provider.of<FavoriteManager>(context, listen: false)
                              .toggleFavorite(restaurant);
                        },
                        child: const Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RestaurantDetailPage(restaurant: restaurant),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
