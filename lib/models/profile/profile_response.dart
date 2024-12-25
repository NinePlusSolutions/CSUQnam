import 'package:json_annotation/json_annotation.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  final String? id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String? avatarUrl;
  final bool isActive;
  final String? address;
  final int? status;
  final String? dateOfBirth;
  final List<FarmByUserResponse> farmByUserResponse;

  ProfileResponse({
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

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}

@JsonSerializable()
class FarmByUserResponse {
  final List<FarmResponse> farmResponse;
  final String userId;

  FarmByUserResponse({
    required this.farmResponse,
    required this.userId,
  });

  factory FarmByUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmByUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmByUserResponseToJson(this);
}

@JsonSerializable()
class FarmResponse {
  final int id;
  final int farmId;
  final String farmName;
  final List<ProductTeamResponse> productTeamResponse;

  FarmResponse({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.productTeamResponse,
  });

  factory FarmResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmResponseToJson(this);
}

@JsonSerializable()
class ProductTeamResponse {
  final int id;
  final int productTeamId;
  final String productTeamName;
  final List<FarmLotResponse> farmLotResponse;

  ProductTeamResponse({
    required this.id,
    required this.productTeamId,
    required this.productTeamName,
    required this.farmLotResponse,
  });

  factory ProductTeamResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductTeamResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTeamResponseToJson(this);
}

@JsonSerializable()
class FarmLotResponse {
  final int id;
  final int farmLotId;
  final String farmLotName;
  final List<AgeShavedResponse> ageShavedResponse;

  FarmLotResponse({
    required this.id,
    required this.farmLotId,
    required this.farmLotName,
    required this.ageShavedResponse,
  });

  factory FarmLotResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmLotResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmLotResponseToJson(this);
}

@JsonSerializable()
class AgeShavedResponse {
  final int? value;

  AgeShavedResponse({
    this.value,
  });

  factory AgeShavedResponse.fromJson(Map<String, dynamic> json) =>
      _$AgeShavedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AgeShavedResponseToJson(this);
}
