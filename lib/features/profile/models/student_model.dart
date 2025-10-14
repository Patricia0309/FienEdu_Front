// lib/features/profile/models/student_model.dart

class Student {
  final int id;
  final String email;
  final String displayName;

  const Student({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      email: json['email'] ?? '', // Usa un string vacío si el email es nulo
      displayName: json['display_name'],
    );
  }
}
