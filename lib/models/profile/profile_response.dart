import 'package:json_annotation/json_annotation.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  @JsonKey(name: 'data')
  final ProfileData? data;
  @JsonKey(name: 'messages')
  final List<dynamic> messages;
  @JsonKey(name: 'status')
  final bool status;

  ProfileResponse({
    this.data,
    required this.messages,
    required this.status,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class ProfileData {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'phoneNumber')
  final String phoneNumber;
  @JsonKey(name: 'fullName')
  final String fullName;
  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'address')
  final String? address;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'dateOfBirth')
  final String? dateOfBirth;
  @JsonKey(name: 'farmByUserResponse')
  final List<FarmByUserResponse> farmByUserResponse;

  ProfileData({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.avatarUrl,
    required this.isActive,
    this.address,
    this.status,
    this.dateOfBirth,
    required this.farmByUserResponse,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable()
class FarmByUserResponse {
  @JsonKey(name: 'farmId')
  final int farmId;
  @JsonKey(name: 'productTeamId')
  final int productTeamId;
  @JsonKey(name: 'farmLotId')
  final int farmLotId;
  @JsonKey(name: 'ageShaved')
  final int? ageShaved;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'farmName')
  final String farmName;
  @JsonKey(name: 'farmLotName')
  final String farmLotName;
  @JsonKey(name: 'productTeamName')
  final String productTeamName;
  @JsonKey(name: 'treeLineByFarmLotResponse')
  final List<TreeLineByFarmLotResponse> treeLineByFarmLotResponse;

  FarmByUserResponse({
    required this.farmId,
    required this.productTeamId,
    required this.farmLotId,
    this.ageShaved,
    required this.userId,
    required this.farmName,
    required this.farmLotName,
    required this.productTeamName,
    required this.treeLineByFarmLotResponse,
  });

  factory FarmByUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmByUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmByUserResponseToJson(this);
}

@JsonSerializable()
class TreeLineByFarmLotResponse {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'rowNumber')
  final int rowNumber;

  TreeLineByFarmLotResponse({
    required this.id,
    required this.name,
    required this.rowNumber,
  });

  factory TreeLineByFarmLotResponse.fromJson(Map<String, dynamic> json) =>
      _$TreeLineByFarmLotResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TreeLineByFarmLotResponseToJson(this);
}
