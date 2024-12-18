class ApiConstants {
  static const baseUrlDev = 'https://dummyjson.com/';
  static const baseUrlProd = 'https://reqres.in';

  static const String baseUrl = 'http://119.82.130.211:6780/api';
  static const String login = '/identity/token';
  static const String status = '/v1/common/status';

  static String getLoginUrl() => '$baseUrl$login';
  static String getStatusUrl() => '$baseUrl$status';
}
