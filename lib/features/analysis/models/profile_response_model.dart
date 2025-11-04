// Para el JSON de POST /analytics/profile
class ProfileResponse {
  final String profile;
  final String justification;
  final String recommendation;

  ProfileResponse({
    required this.profile,
    required this.justification,
    required this.recommendation,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      profile: json['profile'] as String? ?? 'Desconocido',
      justification: json['justification'] as String? ?? 'Sin descripción.',
      recommendation: json['recommendation'] as String? ?? 'Sigue registrando.',
    );
  }
}
