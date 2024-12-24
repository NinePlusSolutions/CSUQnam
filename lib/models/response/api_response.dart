class ApiResponse<T> {
  final T? data;
  final List<String> messages;
  final bool status;

  ApiResponse({
    this.data,
    required this.messages,
    required this.status,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse(
      data: json['data'] != null ? fromJson(json['data']) : null,
      messages: List<String>.from(json['messages'] ?? []),
      status: json['status'] as bool,
    );
  }
}
