import 'package:flutter/material.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

ThemeData mainTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'MPlusRounded1c',
    cardTheme: const CardThemeData(
      elevation: 3.6,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 12.0),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: kTextColor),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: kPrimaryColor,
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
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      gapPadding: 12,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      gapPadding: 12,
      borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      gapPadding: 12,
      borderSide: const BorderSide(color: kHintTextColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
  );
}
