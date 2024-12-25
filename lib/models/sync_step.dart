enum SyncStatus {
  waiting,
  inProgress,
  completed,
  error,
}

class SyncStep {
  final String title;
  final SyncStatus status;
  final String? errorMessage;

  const SyncStep({
    required this.title,
    required this.status,
    this.errorMessage,
  });

  SyncStep copyWith({
    String? title,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return SyncStep(
      title: title ?? this.title,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
