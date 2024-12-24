class ApiConstants {
  static const baseUrlDev = 'http://119.82.130.211:6780/api';
  static const baseUrlProd = 'http://119.82.130.211:6780/api';
  static const baseUrl = 'http://119.82.130.211:6780/api';

  static const String login = '/identity/token';
  static const String status = '/v1/common/status';
  static const String profile = '/v1/common/profile';
  static const String treeCondition = '/v1/tree-condition';
  static const String shavedStatus = '/v1/common/shaved-status';

  static String getLoginUrl() => '$baseUrlProd$login';
  static String getStatusUrl() => '$baseUrlProd$status';
  static String getProfileUrl() => '$baseUrlProd$profile';
  static String getShavedStatusUrl() => '$baseUrlProd$shavedStatus';
  static String getSyncTreeConditionUrl() => '$baseUrlProd$treeCondition';
}
