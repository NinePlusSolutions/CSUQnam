import 'package:json_annotation/json_annotation.dart';

part 'tree_condition_request.g.dart';

@JsonSerializable()
class TreeConditionRequest {
  @JsonKey(name: 'treeConditionList')
  final List<TreeCondition> treeConditionList;

  TreeConditionRequest({
    required this.treeConditionList,
  });

  factory TreeConditionRequest.fromJson(Map<String, dynamic> json) =>
      _$TreeConditionRequestFromJson(json);
  Map<String, dynamic> toJson() => {
        'treeConditionList': treeConditionList.map((x) => x.toJson()).toList(),
      };
}

@JsonSerializable()
class TreeCondition {
  @JsonKey(name: 'inventoryBatchId')
  final int inventoryBatchId;
  @JsonKey(name: 'farmId')
  final int farmId;
  @JsonKey(name: 'farmName')
  final String farmName;
  @JsonKey(name: 'productTeamId')
  final int productTeamId;
  @JsonKey(name: 'productTeamName')
  final String productTeamName;
  @JsonKey(name: 'farmLotId')
  final int farmLotId;
  @JsonKey(name: 'farmLotName')
  final String farmLotName;
  @JsonKey(name: 'treeLineName')
  final String treeLineName;
  @JsonKey(name: 'shavedStatus')
  final int shavedStatus;
  @JsonKey(name: 'shavedStatusName')
  final String shavedStatusName;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'dateCheck')
  final DateTime dateCheck;
  @JsonKey(name: 'treeConditionDetails')
  final List<TreeConditionDetail> treeConditionDetails;
  @JsonKey(name: 'averageAgeToShave')
  final int averageAgeToShave;

  TreeCondition({
    required this.inventoryBatchId,
    required this.farmId,
    required this.farmName,
    required this.productTeamId,
    required this.productTeamName,
    required this.farmLotId,
    required this.farmLotName,
    required this.treeLineName,
    required this.shavedStatus,
    required this.shavedStatusName,
    this.description,
    required this.dateCheck,
    required this.treeConditionDetails,
    required this.averageAgeToShave,
  });

  factory TreeCondition.fromJson(Map<String, dynamic> json) =>
      _$TreeConditionFromJson(json);

  Map<String, dynamic> toJson() => {
        'inventoryBatchId': inventoryBatchId,
        'farmId': farmId,
        'farmName': farmName,
        'productTeamId': productTeamId,
        'productTeamName': productTeamName,
        'farmLotId': farmLotId,
        'farmLotName': farmLotName,
        'treeLineName': treeLineName,
        'shavedStatus': shavedStatus,
        'shavedStatusName': shavedStatusName,
        'description': description,
        'dateCheck': dateCheck.toIso8601String(),
        'treeConditionDetails':
            treeConditionDetails.map((x) => x.toJson()).toList(),
        'averageAgeToShave': averageAgeToShave,
      };
}

@JsonSerializable()
class TreeConditionDetail {
  @JsonKey(name: 'statusId')
  final int statusId;
  @JsonKey(name: 'statusName')
  final String statusName;
  @JsonKey(name: 'value')
  final String value;

  TreeConditionDetail({
    required this.statusId,
    required this.statusName,
    required this.value,
  });

  factory TreeConditionDetail.fromJson(Map<String, dynamic> json) =>
      _$TreeConditionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$TreeConditionDetailToJson(this);
}
