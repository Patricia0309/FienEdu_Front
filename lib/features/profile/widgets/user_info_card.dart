// lib/features/profile/widgets/user_info_card.dart
import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../features/profile/models/student_model.dart';

class UserInfoCard extends StatelessWidget {
  final Student student; // Ahora recibe un objeto Student

  const UserInfoCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... el BoxDecoration no cambia
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información personal', style: AppTextStyles.heading),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: student.displayName, // <-- Dato real
            enabled: false,
            decoration: const InputDecoration(/* ... */),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: student.email, // <-- Dato real
            enabled: false,
            decoration: const InputDecoration(/* ... */),
          ),
        ],
      ),
    );
  }
}
