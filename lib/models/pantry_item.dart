// lib/models/pantry_item.dart

class PantryItem {
  final String name;
  final String? imagePath;
  final DateTime addedDate;
  final DateTime expirationDate;

  PantryItem({
    required this.name,
    this.imagePath, 
    required this.addedDate,
    required this.expirationDate,
  });

  // Helper to calculate how far from expiration the item is (0.0 to 1.0)
  double get expirationProgress {
    final totalDuration = expirationDate.difference(addedDate).inSeconds;
    final elapsed = DateTime.now().difference(addedDate).inSeconds;
    if (totalDuration <= 0) return 1.0;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }
}