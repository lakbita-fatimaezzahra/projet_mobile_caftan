class ApiConstants {
  // À adapter selon ton environnement (émulateur Android, device, etc.)
  // Pour l'émulateur Android: http://10.0.2.2:8000
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Base pour les fichiers stockés dans storage/app/public
  static const String imagesBaseUrl = 'http://10.0.2.2:8000/storage';
  // Admin
  static const String adminLogin = '/admin/login';
  static const String adminLogout = '/admin/logout';
  static const String adminUser = '/admin/user';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCategories = '/admin/categories';
  static const String adminCaftans = '/admin/caftans';
  static const String adminRentals = '/admin/rentals';
  static const String adminClients = '/admin/clients';
  static const String adminSizes = '/admin/sizes';
}
