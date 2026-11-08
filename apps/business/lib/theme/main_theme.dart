import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_business/theme/constants.dart';

ThemeData mainTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'MPlusRounded1c',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: kPrimaryColor,
      selectionColor: CupertinoColors.link.withValues(alpha: 0.6),
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
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: kPrimaryColor),
        gapPadding: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      gapPadding: 12,
      borderSide: const BorderSide(color: kPrimaryColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      gapPadding: 12,
      borderSide: const BorderSide(color: kTextColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      gapPadding: 12,
      borderSide: const BorderSide(color: kAlertColor),
    ),
  );
}
