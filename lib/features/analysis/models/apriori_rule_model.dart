// Para el JSON de GET /analytics/rules
class AprioriRule {
  final String antecedent;
  final String consequent;

  AprioriRule({required this.antecedent, required this.consequent});

  factory AprioriRule.fromJson(Map<String, dynamic> json) {
    return AprioriRule(
      antecedent: json['antecedent'] as String? ?? '?',
      consequent: json['consequent'] as String? ?? '?',
    );
  }
}
