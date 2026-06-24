class AppConstants {
  // App info
  static const appName = 'SwiftDrop';
  static const appVersion = '1.0.0';

  // User roles
  static const roleCustomer = 'customer';
  static const roleRider = 'rider';
  static const roleAdmin = 'admin';

  // Storage keys
  static const keyUserRole = 'user_role';
  static const keyAuthToken = 'auth_token';
  static const keyUserId = 'user_id';
  static const keyThemeMode = 'theme_mode';

  // Order statuses
  static const statusPending = 'pending';
  static const statusConfirmed = 'confirmed';
  static const statusPreparing = 'preparing';
  static const statusOnTheWay = 'on_the_way';
  static const statusDelivered = 'delivered';
  static const statusCancelled = 'cancelled';

  // Timeouts
  static const apiTimeoutSeconds = 30;
}