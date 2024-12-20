class ApiConstants {
  static const baseUrlDev = 'http://119.82.130.211:6780/api';
  static const baseUrlProd = 'http://119.82.130.211:6780/api';

  static const String login = '/identity/token';
  static const String status = '/v1/common/status';

  static String getLoginUrl() => '$baseUrlProd$login';
  static String getStatusUrl() => '$baseUrlProd$status';
}
