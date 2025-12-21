import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lostandfound/pages/chat_bot_page.dart';
import 'firebase_options.dart'; // <-- required for Firebase
import 'package:lostandfound/pages/app_shell.dart';
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
        primaryColor: const Color(0xFFBF0C4F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBF0C4F)),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),

      /// 👇 Your app starts here
      home: ChatbotScreen(),
    );
  }
}
