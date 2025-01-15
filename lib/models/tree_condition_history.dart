class TreeConditionHistoryResponse {
  final TreeConditionHistoryData data;
  final List<String> messages;
  final bool status;

  TreeConditionHistoryResponse({
    required this.data,
    required this.messages,
    required this.status,
  });

  factory TreeConditionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TreeConditionHistoryResponse(
      data: TreeConditionHistoryData.fromJson(json['data']),
      messages: List<String>.from(json['messages']),
      status: json['status'],
    );
  }
}

class TreeConditionHistoryData {
  final List<TreeConditionHistory> treeConditionList;

  TreeConditionHistoryData({
    required this.treeConditionList,
  });

  factory TreeConditionHistoryData.fromJson(Map<String, dynamic> json) {
    return TreeConditionHistoryData(
      treeConditionList: (json['treeConditionList'] as List)
          .map((e) => TreeConditionHistory.fromJson(e))
          .toList(),
    );
  }
}

class TreeConditionHistory {
  final int id;
  final int farmId;
  final String farmName;
  final int productTeamId;
  final String productTeamName;
  final int farmLotId;
  final String farmLotName;
  final String userId;
  final String treeLineName;
  final int shavedStatus;
  final String shavedStatusName;
  final String? description;
  final DateTime dateCheck;
  final List<TreeConditionDetail> treeConditionDetails;
  final String yearShaved;

  TreeConditionHistory({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.productTeamId,
    required this.productTeamName,
    required this.farmLotId,
    required this.farmLotName,
    required this.userId,
    required this.treeLineName,
    required this.shavedStatus,
    required this.shavedStatusName,
    this.description,
    required this.dateCheck,
    required this.treeConditionDetails,
    required this.yearShaved,
  });

  factory TreeConditionHistory.fromJson(Map<String, dynamic> json) {
    return TreeConditionHistory(
      id: json['id'],
      farmId: json['farmId'],
      farmName: json['farmName'],
      productTeamId: json['productTeamId'],
      productTeamName: json['productTeamName'],
      farmLotId: json['farmLotId'],
      farmLotName: json['farmLotName'],
      userId: json['userId'],
      treeLineName: json['treeLineName'],
      shavedStatus: json['shavedStatus'],
      shavedStatusName: json['shavedStatusName'],
      description: json['description'],
      dateCheck: DateTime.parse(json['dateCheck']),
      treeConditionDetails: (json['treeConditionDetails'] as List)
          .map((e) => TreeConditionDetail.fromJson(e))
          .toList(),
      yearShaved: json['averageAgeToShave']?.toString() ?? '',
    );
  }
}

class TreeConditionDetail {
  final int statusId;
  final String statusName;
  final String value;

  TreeConditionDetail({
    required this.statusId,
    required this.statusName,
    required this.value,
  });

  factory TreeConditionDetail.fromJson(Map<String, dynamic> json) {
    return TreeConditionDetail(
      statusId: json['statusId'],
      statusName: json['statusName'],
      value: json['value'],
    );
  }
}
