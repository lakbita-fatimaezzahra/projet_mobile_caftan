class CaftanImageModel {
  final int id;
  final String imagePath;
  final bool isPrimary;

  CaftanImageModel({
    required this.id,
    required this.imagePath,
    required this.isPrimary,
  });

  factory CaftanImageModel.fromJson(Map<String, dynamic> json) {
    return CaftanImageModel(
      id: json['id'] as int,
      imagePath: json['image_path'] as String,
      isPrimary: json['is_primary'] == true,
    );
  }
}

class Caftan {
  final int id;
  final String name;
  final String description;
  final double pricePerDay;
  final bool isAvailable;
  final String? categoryName;
  final String? imageUrl;
  final List<CaftanImageModel> images;

  Caftan({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerDay,
    required this.isAvailable,
    this.categoryName,
    this.imageUrl,
    this.images = const [],
  });

  factory Caftan.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final primaryImage = json['primary_image'] as Map<String, dynamic>?;
    final imagesJson = json['images'] as List<dynamic>?;

    // price_per_day may arrive as num (e.g. 100 or 100.0) or as String (e.g. "100.00").
    // Normalize it to a double for the model.
    final rawPrice = json['price_per_day'];
    double parsedPrice;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice.replaceAll(',', '.')) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    final rawAvailable = json['is_available'];
    final bool parsedAvailable;
    if (rawAvailable is bool) {
      parsedAvailable = rawAvailable;
    } else if (rawAvailable is num) {
      parsedAvailable = rawAvailable != 0;
    } else if (rawAvailable is String) {
      parsedAvailable = rawAvailable == '1' || rawAvailable.toLowerCase() == 'true';
    } else {
      parsedAvailable = false;
    }

    return Caftan(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerDay: parsedPrice,
      isAvailable: parsedAvailable,
      categoryName: category != null ? category['name'] as String? : null,
      imageUrl: primaryImage != null ? primaryImage['image_path'] as String? : null,
      images: imagesJson != null
          ? imagesJson
              .map((e) => CaftanImageModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
