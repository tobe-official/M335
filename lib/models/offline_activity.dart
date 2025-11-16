class OfflineActivity {
  final String id;
  final String userId;
  final int steps;
  final DateTime timestamp;

  OfflineActivity({
    required this.id,
    required this.userId,
    required this.steps,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'steps': steps,
    'timestamp': timestamp.toIso8601String(),
  };

  factory OfflineActivity.fromJson(Map<String, dynamic> json) {
    return OfflineActivity(
      id: json['id'],
      userId: json['userId'],
      steps: json['steps'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}