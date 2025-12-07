import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_screen.dart';

void main() {
    runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: OnboardingScreen(),
    ),
  );
}
