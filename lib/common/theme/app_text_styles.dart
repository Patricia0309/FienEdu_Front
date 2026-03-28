import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle title = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w900, // Black
    color: AppColors.primary,
  );
  
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold, // Bold
    color: AppColors.primary,
  );

  static final TextStyle heading = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.primary,
  );

  static final TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal, // Regular
    color: AppColors.secondary,
  );

  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textLight,
  );

  static final TextStyle small = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal, // Regular
    color: AppColors.secondary,
  );
}