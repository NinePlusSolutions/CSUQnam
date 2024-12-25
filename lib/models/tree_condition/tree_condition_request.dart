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
  @JsonKey(name: 'farmId')
  final int farmId;
  @JsonKey(name: 'productTeamId')
  final int productTeamId;
  @JsonKey(name: 'farmLotId')
  final int farmLotId;
  @JsonKey(name: 'treeLineName')
  final String treeLineName;
  @JsonKey(name: 'shavedStatus')
  final int shavedStatus;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'dateCheck')
  final DateTime dateCheck;
  @JsonKey(name: 'treeConditionDetails')
  final List<TreeConditionDetail> treeConditionDetails;

  TreeCondition({
    required this.farmId,
    required this.productTeamId,
    required this.farmLotId,
    required this.treeLineName,
    required this.shavedStatus,
    this.description,
    required this.dateCheck,
    required this.treeConditionDetails,
  });

  factory TreeCondition.fromJson(Map<String, dynamic> json) =>
      _$TreeConditionFromJson(json);

  Map<String, dynamic> toJson() => {
        'farmId': farmId,
        'productTeamId': productTeamId,
        'farmLotId': farmLotId,
        'treeLineName': treeLineName,
        'shavedStatus': shavedStatus,
        'description': description,
        'dateCheck': dateCheck.toIso8601String(),
        'treeConditionDetails':
            treeConditionDetails.map((x) => x.toJson()).toList(),
      };
}

@JsonSerializable()
class TreeConditionDetail {
  @JsonKey(name: 'statusId')
  final int statusId;
  @JsonKey(name: 'value')
  final String value;

  TreeConditionDetail({
    required this.statusId,
    required this.value,
  });

  factory TreeConditionDetail.fromJson(Map<String, dynamic> json) =>
      _$TreeConditionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$TreeConditionDetailToJson(this);
}
