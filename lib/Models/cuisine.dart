class Cuisine {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  Cuisine({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    return Cuisine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}
