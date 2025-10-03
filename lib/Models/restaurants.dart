import 'package:dinengo/Models/food_review_model.dart';
import 'package:dinengo/Models/message_model.dart';
import 'package:dinengo/Models/table_model.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String deliveryTime;
  final String priceLevel;
  final bool freeDelivery;
  final String address;
  final String phoneNumber;
  final bool isOpen;
  final Map<String, String> operatingHours; // e.g., {"Monday": "8am-10pm"}
  final Map<String, double> location; // {"lat": 12.34, "lng": 56.78}
  final List<String> discounts;
  final List<MenuItem> menu;
  final bool isDeliveryOnly;
  final int? totalSeats;
  final int? availableSeats;
  final List<ChatMessage> chatHistory;
  final List<TableModel> tables; // ✅ Add this


  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.deliveryTime,
    required this.priceLevel,
    required this.freeDelivery,
    required this.address,
    required this.phoneNumber,
    required this.isOpen,
    required this.operatingHours,
    required this.location,
    required this.discounts,
    required this.menu,
    required this.isDeliveryOnly,
    this.totalSeats,
    this.availableSeats,
    this.chatHistory = const [],
    required this.tables, 
  });

  double get averageMenuPrice {
    if (menu.isEmpty) return 0;
    final total = menu.fold(0.0, (sum, item) => sum + item.price);
    return total / menu.length;
  }
}

class MenuItem {
  final String id;
  final String name;
  final String? description;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String? category;
  final String? restaurantId;
  final String? restaurantName;
  final List<CustomizationOption>? customizations;
  final List<Review> reviews;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.description,
    this.category,
    this.restaurantId,
    this.restaurantName,
    this.customizations,
    this.reviews = const [],
  });
}

class CustomizationOption {
  final String name;
  final List<String> choices;

  CustomizationOption({
    required this.name,
    required this.choices,
  });
}
