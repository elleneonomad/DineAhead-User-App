class TableModel {
  final int id;
  final String tableNumber;
  final int seats;
  final bool isBooked;
  final bool isAvailable;
  final String locationType; // e.g. Indoor, Outdoor, Private
  final String? imageUrl;
  final String? note;
  final List<String>? features; // e.g. ["Pet-friendly", "Smoking area"]
  final double? minSpend;
  final List<String>? reservationTimeSlots; // e.g. ["12:00 PM", "2:00 PM"]

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.seats,
    required this.isBooked,
    required this.isAvailable,
    required this.locationType,
    this.imageUrl,
    this.note,
    this.features,
    this.minSpend,
    this.reservationTimeSlots,
  });
}
