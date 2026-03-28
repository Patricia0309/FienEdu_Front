import 'package:flutter/material.dart';
import '../../../common/theme/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';

class PrivacyPolicyModal extends StatefulWidget {
  const PrivacyPolicyModal({super.key});

  @override
  State<PrivacyPolicyModal> createState() => _PrivacyPolicyModalState();
}

class _PrivacyPolicyModalState extends State<PrivacyPolicyModal> {
  // Variable de estado para controlar el checkbox
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      // Usamos DraggableScrollableSheet para un modal más avanzado, pero empecemos con algo simple.
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Para que el modal no ocupe toda la pantalla
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Política de Privacidad', style: AppTextStyles.heading),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // Cierra el modal
              ),
            ],
          ),
          Text(
            'Lee las políticas de privacidad y acepta los términos para continuar.',
            style: AppTextStyles.small,
          ),
          const SizedBox(height: 20),

          // --- Contenido con Scroll ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'En FinEdu se respeta tu privacidad y se protegen tus datos personales.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recopilación de datos',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'FinEdu recopila información sobre tus transacciones financieras únicamente para proporcionarte análisis y recomendaciones personalizadas.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uso de la información',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'FinEdu utiliza algoritmos como (K-means) para analizar tus patrones de gasto y ofrecerte recomendaciones relevantes.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seguridad',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tus datos están protegidos y nunca serán compartidos con terceros sin tu consentimiento.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Checkbox de Aceptación ---
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              // Usamos Expanded para que el texto no se desborde si la pantalla es pequeña
              Expanded(
                child: Text(
                  'Acepto las política de privacidad',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Botón de Continuar ---
          PrimaryButton(
            text: 'Continuar',
            // Si _isChecked es true, la función se activa.
            // Si es false, onPressed es null, y el botón se deshabilita automáticamente.
            onPressed: _isChecked
                ? () {
                    // Cierra el modal y devuelve 'true' para indicar que se aceptó.
                    Navigator.pop(context, true);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
