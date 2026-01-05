class ClientModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? cin;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.cin,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      cin: json['cin'] as String?,
    );
  }
}
