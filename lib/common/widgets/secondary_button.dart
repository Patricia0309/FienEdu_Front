import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        foregroundColor: Theme.of(context).primaryColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.button.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
