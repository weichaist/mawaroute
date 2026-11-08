import 'package:flutter/material.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: kPrimaryColor,
    scaffoldBackgroundColor: const Color(0xFF2f333e),
    fontFamily: 'MPlusRounded1c',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2f333e),
      elevation: 0,
      iconTheme: IconThemeData(color: kBgColor),
      titleTextStyle: TextStyle(color: kBgColor),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: kBgColor)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: kPrimaryContainerColor,
      selectionColor: kPrimaryColor.withValues(alpha: 0.15),
    ),
    inputDecorationTheme: inputDecorationTheme(),
  );
}

InputDecorationTheme inputDecorationTheme() {
  return InputDecorationTheme(
    // floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelStyle: const TextStyle(color: kPrimaryColor),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryContainerColor),
      gapPadding: 12,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      gapPadding: 12,
      borderSide: const BorderSide(color: kPrimaryContainerColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      gapPadding: 12,
      borderSide: const BorderSide(color: kHintTextColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
  );
}
