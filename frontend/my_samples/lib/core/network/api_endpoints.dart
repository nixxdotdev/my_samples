/// Central registry of all backend REST API endpoints.
class ApiEndpoints {
  // Base samples endpoint
  static const String samples = '/api/samples';
  static String sampleById(String id) => '/api/samples/$id';
  static String sampleStatus(String id) => '/api/samples/$id/status';

  // Notifications endpoint
  static const String notifications = '/api/notifications';
  static String notificationById(String id) => '/api/notifications/$id';
  static String markNotificationRead(String id) => '/api/notifications/$id/read';
  static const String markAllNotificationsRead = '/api/notifications/read-all';

  // Analytics
  static const String analyticsSummary = '/api/analytics/summary';

  // Auth endpoints (for future creator login)
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';
}
