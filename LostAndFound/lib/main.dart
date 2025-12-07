import 'package:flutter/material.dart';
import 'package:lostandfound/pages/onboarding_screen.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      themeMode: ThemeMode.light,
      home: OnboardingScreen(),
    ),
  );
}
