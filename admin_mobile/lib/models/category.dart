class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? image;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }
}
