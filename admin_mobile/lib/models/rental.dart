class RentalModel {
  final int id;
  final String clientName;
  final String caftanName;
  final String sizeName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final double depositAmount;
  final String status;
  final String paymentStatus;

  RentalModel({
    required this.id,
    required this.clientName,
    required this.caftanName,
    required this.sizeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.depositAmount,
    required this.status,
    required this.paymentStatus,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>?;
    final caftan = json['caftan'] as Map<String, dynamic>?;
    final size = json['size'] as Map<String, dynamic>?;

    final totalPriceRaw = json['total_price'];
    final depositRaw = json['deposit_amount'];

    return RentalModel(
      id: json['id'] as int,
      clientName: client != null ? client['name'] as String? ?? '-' : '-',
      caftanName: caftan != null ? caftan['name'] as String? ?? '-' : '-',
      sizeName: size != null ? size['name'] as String? ?? '-' : '-',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalDays: json['total_days'] as int? ?? 0,
      totalPrice: totalPriceRaw is num ? totalPriceRaw.toDouble() : 0.0,
      depositAmount: depositRaw is num ? depositRaw.toDouble() : 0.0,
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
    );
  }
}
