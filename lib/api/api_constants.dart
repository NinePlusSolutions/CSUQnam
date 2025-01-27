class ApiConstants {
  static const baseUrlDev = 'http://caosu.nineplus.vn/api';
  static const baseUrlProd = 'http://caosu.nineplus.vn/api';
  static const baseUrl = 'http://caosu.nineplus.vn/api';
//http://caosu.nineplus.vn/api/identity/token
  static const String login = '/identity/token';
  static const String status = '/v1/common/status';
  static const String profile = '/v1/common/profile';
  static const String treeCondition = '/v1/tree-condition';
  static const String shavedStatus = '/v1/common/shaved-status';
  static const String history = '/v1/tree-condition/history';
  static const String inventoryBatches = '/v1/common/inventory-batches';
  static const String changePassword = '/v1/common/change-password';

  // Farm endpoints
  static const String farm = '/v1/common/farm';
  static const String productTeam = '/v1/common/product-team';
  static const String farmLot = '/v1/common/farm-lot';
  static const String yearShaved = '/v1/common/year-shaved';

  // URL getters
  static String getLoginUrl() => '$baseUrlProd$login';
  static String getStatusUrl() => '$baseUrlProd$status';
  static String getProfileUrl() => '$baseUrlProd$profile';
  static String getShavedStatusUrl() => '$baseUrlProd$shavedStatus';
  static String getFarmUrl() => '$baseUrlProd$farm';
  static String getProductTeamUrl() => '$baseUrlProd$productTeam';
  static String getFarmLotUrl() => '$baseUrlProd$farmLot';
  static String getYearShavedUrl() => '$baseUrlProd$yearShaved';
  static String getSyncTreeConditionUrl() => '$baseUrlProd$treeCondition';
  static String getHistoryTreeConditionUrl() => '$baseUrlProd$history';
  static String getInventoryBatchesUrl() => '$baseUrlProd$inventoryBatches';
  static String getChangePasswordUrl() => '$baseUrlProd$changePassword';
}
