import 'package:flutter/material.dart';
import 'package:lostandfound/pages/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:lostandfound/pages/login_page.dart'; // Assuming LoginPage is your actual entry point after onboarding (if used)
import 'package:lostandfound/pages/home_page.dart'; // Assuming HomePage is used somewhere

Future<void> main() async {
  // Ensure Flutter's binding is initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file. This must complete before runApp().
  await dotenv.load(
    fileName: ".env",
  ); // This line is crucial for dotenv to work

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmritaFind', // Added a title for clarity
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color(
          0xFF8C2F39,
        ), // Using your project's primary color
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C2F39)),
        useMaterial3: true,
      ),
      home: OnboardingScreen(), // Your app's starting screen, removed const
    );
  }
}
