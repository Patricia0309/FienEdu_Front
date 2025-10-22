import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? iconPrefix;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle selectedLabelStyle;
  final TextStyle unselectedLabelStyle;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;


  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.iconPrefix,
    this.selectedColor = AppColors.accent3,
    this.unselectedColor = AppColors.background,
    this.selectedLabelStyle = const TextStyle(color: AppColors.primary),
    this.unselectedLabelStyle = const TextStyle(color: AppColors.secondary),
    this.selectedBorderColor = AppColors.accent2,
    this.unselectedBorderColor = AppColors.secondary,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: Chip(
        avatar: iconPrefix, // Usamos avatar para el icono
        label: Text(label),
        labelStyle: isSelected ? selectedLabelStyle : unselectedLabelStyle,
        backgroundColor: isSelected ? selectedColor : unselectedColor,
        side: BorderSide(
          color: isSelected ? selectedBorderColor : unselectedBorderColor,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bordes más redondeados
      ),
    );
  }
}