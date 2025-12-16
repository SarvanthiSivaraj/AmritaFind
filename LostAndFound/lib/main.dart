import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // <-- required for Firebase
import 'package:lostandfound/pages/onboarding_screen.dart';
import 'package:lostandfound/pages/login_page.dart';
import 'package:lostandfound/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await dotenv.load(fileName: ".env");

  // Initialize Firebase BEFORE running the app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmritaFind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        primaryColor: const Color(0xFF8C2F39),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C2F39)),
        useMaterial3: true,
      ),

      /// 👇 Your app starts here
      home: OnboardingScreen(),
    );
  }
}
