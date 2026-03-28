// lib/features/analysis/models/profile_response_model.dart
class ProfileResponse {
  final String profile;
  final String justification;
  final String recommendation;
  final bool isCalculating;
  final int currentCount;
  final int goal;

  ProfileResponse({
    required this.profile,
    required this.justification,
    required this.recommendation,
    required this.isCalculating,
    required this.currentCount,
    required this.goal,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      profile: json['profile'] as String? ?? '',
      justification: json['justification'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      isCalculating: json['is_calculating'] as bool? ?? false,
      currentCount: json['current_count'] as int? ?? 0,
      goal: json['goal'] as int? ?? 15,
    );
  }
}
