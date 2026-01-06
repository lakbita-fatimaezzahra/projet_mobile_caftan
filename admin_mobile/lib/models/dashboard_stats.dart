class DashboardStats {
  final int totalCaftans;
  final int availableCaftans;
  final int activeRentals;
  final int clientsCount;
  final num monthlyRevenue;

  DashboardStats({
    required this.totalCaftans,
    required this.availableCaftans,
    required this.activeRentals,
    required this.clientsCount,
    required this.monthlyRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final totalCaftansRaw = json['total_caftans'];
    final availableCaftansRaw = json['available_caftans'];
    final activeRentalsRaw = json['active_rentals'];
    final clientsCountRaw = json['clients_count'];
    final monthlyRevenueRaw = json['monthly_revenue'];

    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0;
    }

    num _toNum(dynamic value) {
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
      return 0;
    }

    return DashboardStats(
      totalCaftans: _toInt(totalCaftansRaw),
      availableCaftans: _toInt(availableCaftansRaw),
      activeRentals: _toInt(activeRentalsRaw),
      clientsCount: _toInt(clientsCountRaw),
      monthlyRevenue: _toNum(monthlyRevenueRaw),
    );
  }
}
