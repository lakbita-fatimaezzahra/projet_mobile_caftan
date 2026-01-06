class SizeModel {
  final int id;
  final String name;
  final String? description;

  SizeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
