import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFC2144E);
  static const Color secondary = Color(0xFFF3A3BE);
  static const Color background = Color(0xFFFFF2F7);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static Color textColor = Colors.black;

  static const Color text = Color(0xFF000000);
  static const Color textLight = Color(0xFF8B8B8B);

  static const Color card = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF2C2C2C);

  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  static const Color button = Color.fromARGB(193, 243, 163, 190);
  static const Color redbutton = Color(0xFFC2144E);
  static const Color buttonText1 = Color(0xFFFFFFFF);
  static const Color buttonText2 = Color(0xFF000000);

  static const Color glassWhite = Color(0x80FFFFFF); // 50% opacity
  static const Color glassBlack = Color(0x80000000); // 50% opacity

  // Dark theme example
  static Color darkBackgroundColor = Colors.black;
  static Color darkTextColor = Colors.white;

  static Color loder = const Color(0xFFC2144E);
}

// Dynamic Fonts
class AppTextStyles {
  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static TextStyle subHeading = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle body1 = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static TextStyle body2 = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static TextStyle body3 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static TextStyle button1 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  static TextStyle button2 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
  static TextStyle redbutton = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.redbutton,
  );
  static TextStyle cardtext1 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF8B8B8B),
  );
  static TextStyle cardtext2 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF8B8B8B),
  );
}
