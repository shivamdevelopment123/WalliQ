import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade200,
      primary: Colors.grey.shade500,
      secondary: Colors.grey.shade300,
      inversePrimary: Colors.grey.shade900,
      inverseSurface: Colors.white.withOpacity(0.9)
  ),
  highlightColor: Colors.white,
);