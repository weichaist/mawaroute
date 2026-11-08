import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF08162E);

const kDefaultPadding = 24.0;
const kMaxWidth = 1080.0;
const kDefaultHeight = 666.0;
const kDefaultDuration = Duration(milliseconds: 240);

const kDefaultShadow = BoxShadow(
  offset: Offset(0, 1.5),
  spreadRadius: 1.5,
  blurRadius: 3,
  color: Colors.black12,
);

InputDecorationTheme inputDecorationTheme() {
  return InputDecorationTheme(
    // floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelStyle: const TextStyle(color: Colors.white),
    enabledBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Colors.white),
    ),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Colors.white),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Colors.red),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Colors.white),
    ),
    errorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}
