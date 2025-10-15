import 'package:dinengo/Models/food_review_model.dart';
import 'package:dinengo/Models/message_model.dart';
import 'package:dinengo/Models/table_model.dart';

class Restaurant {
  final String id;
  final String? merchantId; // for chat participants (Firebase UID)
  final String name;
  final String description;
  final String imagePath; // ⚠️ we’ll keep for compatibility (use cover)
  final String cover;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String deliveryTime;
  final String priceLevel;
  final bool freeDelivery;
  final String address;
  final String phoneNumber;
  final bool isOpen;
  final Map<String, String> operatingHours;
  final Map<String, double> location;
  final List<String> discounts;
  final List<MenuItem> menu;
  // final bool isDeliveryOnly;
  final int? totalSeats;
  final int? availableSeats;
  final List<ChatMessage> chatHistory;
  final List<TableModel> tables;
  
  // Additional info
  final Map<String, dynamic>? policies;
  final Map<String, dynamic>? payment;
  final Map<String, dynamic>? businessHours;
  final Map<String, dynamic>? socialMedia;
  final Map<String, dynamic>? parking;
  final Map<String, dynamic>? cancellation;

  Restaurant({
    required this.id,
    this.merchantId,
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
    // required this.isDeliveryOnly,
    this.totalSeats,
    this.availableSeats,
    this.chatHistory = const [],
    required this.tables,
    required this.cover,
    this.policies,
    this.payment,
    this.businessHours,
    this.socialMedia,
    this.parking,
    this.cancellation,
  });

  double get averageMenuPrice {
    if (menu.isEmpty) return 0;
    final total = menu.fold(0.0, (sum, item) => sum + item.price);
    return total / menu.length;
  }

  /// ✅ New factory method (compatible with new backend user endpoints)
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Prefer explicit coverImage; fallback to first from images
    String cover = '';
    final coverImage = json['coverImage'];
    if (coverImage is String && coverImage.trim().isNotEmpty) {
      cover = coverImage.trim();
    } else {
      final images = json['images'];
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is String) cover = first;
        if (first is Map && first['url'] is String) cover = first['url'];
      }
    }

    // cuisine: ["Italian", ...]
    final List<String> tags = (json['cuisine'] as List?)
            ?.whereType<dynamic>()
            .map((e) => e.toString())
            .toList() ??
        [];

    // businessHours: { monday: {open, close, isOpen}, ... }
    final biz = json['businessHours'];
    final Map<String, String> operatingHours = {};
    if (biz is Map) {
      biz.forEach((key, value) {
        if (value is Map) {
          final open = value['open']?.toString() ?? '';
          final close = value['close']?.toString() ?? '';
          if (open.isNotEmpty || close.isNotEmpty) {
            operatingHours[key.toString()] = "$open - $close".trim();
          }
        }
      });
    }

    // rating/totalReviews
    final double rating = (json['rating'] is num)
        ? (json['rating'] as num).toDouble()
        : double.tryParse(json['rating']?.toString() ?? '') ?? 0.0;
    final int reviewCount = (json['totalReviews'] is num)
        ? (json['totalReviews'] as num).toInt()
        : int.tryParse(json['totalReviews']?.toString() ?? '') ?? 0;

    // priceRange: string
    final String priceRange = json['priceRange']?.toString() ?? '';

    return Restaurant(
      id: json['id']?.toString() ?? '',
      merchantId: json['merchantId']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imagePath: cover,
      cover: cover,
      rating: rating,
      reviewCount: reviewCount,
      tags: tags,
      deliveryTime: '', // optional; could be derived from businessHours if needed
      priceLevel: priceRange,
      freeDelivery: false,
      address: json['address']?.toString() ?? '',
      phoneNumber: json['phone']?.toString() ?? '',
      isOpen: true, // could be derived from today's businessHours
      operatingHours: operatingHours,
      location: {"lat": 0.0, "lng": 0.0}, // not provided by new payload
      discounts: const [],
      menu: const [],
      totalSeats: null,
      availableSeats: null,
      tables: const [],
      policies: json['policies'] as Map<String, dynamic>?,
      payment: json['payment'] as Map<String, dynamic>?,
      businessHours: json['businessHours'] as Map<String, dynamic>?,
      socialMedia: json['socialMedia'] as Map<String, dynamic>?,
      parking: json['parking'] as Map<String, dynamic>?,
      cancellation: json['cancellation'] as Map<String, dynamic>?,
    );
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
