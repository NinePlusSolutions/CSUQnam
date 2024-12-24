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
  @JsonKey(name: 'farm')
  final Farm farm;
  @JsonKey(name: 'productTeam')
  final ProductTeam productTeam;
  @JsonKey(name: 'farmLot')
  final FarmLot farmLot;
  @JsonKey(name: 'ageShaved')
  final int ageShaved;
  @JsonKey(name: 'userId')
  final String userId;

  FarmByUserResponse({
    required this.farm,
    required this.productTeam,
    required this.farmLot,
    required this.ageShaved,
    required this.userId,
  });

  factory FarmByUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmByUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmByUserResponseToJson(this);
}

@JsonSerializable()
class Farm {
  @JsonKey(name: 'farmId')
  final int farmId;
  @JsonKey(name: 'farmName')
  final String farmName;

  Farm({
    required this.farmId,
    required this.farmName,
  });

  factory Farm.fromJson(Map<String, dynamic> json) => _$FarmFromJson(json);
  Map<String, dynamic> toJson() => _$FarmToJson(this);
}

@JsonSerializable()
class ProductTeam {
  @JsonKey(name: 'productTeamId')
  final int productTeamId;
  @JsonKey(name: 'productTeamName')
  final String productTeamName;

  ProductTeam({
    required this.productTeamId,
    required this.productTeamName,
  });

  factory ProductTeam.fromJson(Map<String, dynamic> json) =>
      _$ProductTeamFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTeamToJson(this);
}

@JsonSerializable()
class FarmLot {
  @JsonKey(name: 'farmLotId')
  final int farmLotId;
  @JsonKey(name: 'farmLotName')
  final String farmLotName;

  FarmLot({
    required this.farmLotId,
    required this.farmLotName,
  });

  factory FarmLot.fromJson(Map<String, dynamic> json) => _$FarmLotFromJson(json);
  Map<String, dynamic> toJson() => _$FarmLotToJson(this);
}
