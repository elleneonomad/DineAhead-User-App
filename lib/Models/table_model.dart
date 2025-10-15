class TableModel {
  final String id; // new backend uses string ids
  final String name; // display name; new backend: tableNumber
  final String description;
  final List<String> images;
  final bool isActive;
  final bool isAvailable; // For filtering available tables
  final String seatLevelName; // reuse to show capacity as string
  final String locationTypeName; // new backend: location
  final String? restaurantId; // new backend provides restaurantId
  final int? capacity; // numeric capacity
  final int? maxBookingDuration; // new backend provides this sometimes
  final double? minSpending; // minimum spending requirement for booking

  TableModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.isActive,
    this.isAvailable = true, // Default to true
    required this.seatLevelName,
    required this.locationTypeName,
    this.restaurantId,
    this.capacity,
    this.maxBookingDuration,
    this.minSpending,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    // Support both old and new shapes
    final bool isNew = json.containsKey('tableNumber') || json.containsKey('capacity') || json.containsKey('location');
    if (isNew) {
      final id = (json['id'] ?? '').toString();
      final tableNumber = (json['tableNumber'] ?? '').toString();
      final desc = (json['description'] ?? '').toString();
      final imgs = (json['images'] is List)
          ? List<String>.from((json['images'] as List).map((e) => e.toString()))
          : <String>[];
      // If isActive field exists, use its value; otherwise default to true
      final isActive = json.containsKey('isActive') 
          ? (json['isActive'] == true) 
          : true;
      // Check both isAvailable and is_available fields
      final isAvailable = json.containsKey('isAvailable')
          ? (json['isAvailable'] == true)
          : json.containsKey('is_available')
              ? (json['is_available'] == true)
              : true;
      final capNum = (json['capacity'] is num) ? (json['capacity'] as num).toInt() : int.tryParse(json['capacity']?.toString() ?? '');
      final capacityStr = capNum?.toString() ?? '';
      final location = (json['location'] ?? '').toString();
      final restId = json['restaurantId']?.toString();
      final maxDur = (json['maxBookingDuration'] is num) ? (json['maxBookingDuration'] as num).toInt() : int.tryParse(json['maxBookingDuration']?.toString() ?? '');
      final minSpend = (json['minSpending'] is num) ? (json['minSpending'] as num).toDouble() : double.tryParse(json['minSpending']?.toString() ?? '');
      return TableModel(
        id: id,
        name: tableNumber.isNotEmpty ? tableNumber : id,
        description: desc,
        images: imgs,
        isActive: isActive,
        isAvailable: isAvailable,
        seatLevelName: capacityStr,
        locationTypeName: location,
        restaurantId: restId,
        capacity: capNum,
        maxBookingDuration: maxDur,
        minSpending: minSpend,
      );
    }

    // Fallback to old mapping
    return TableModel(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: List<String>.from((json['images'] ?? []).map((e) => e.toString())),
      // If is_active field exists, use its value; otherwise default to true
      isActive: json.containsKey('is_active')
          ? (json['is_active'] == true)
          : true,
      // If is_available field exists, use its value; otherwise default to true
      isAvailable: json.containsKey('is_available')
          ? (json['is_available'] == true)
          : true,
      seatLevelName: json['seat_level_name']?.toString() ?? '',
      locationTypeName: json['location_type_name']?.toString() ?? '',
      restaurantId: null,
      capacity: null,
      maxBookingDuration: null,
      minSpending: null,
    );
  }
}
