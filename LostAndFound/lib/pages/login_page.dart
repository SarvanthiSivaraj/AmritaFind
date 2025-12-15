import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

void main() {
  runApp(const LostFoundApp());
}

class LostFoundApp extends StatelessWidget {
  const LostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found – Amrita Campus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8C2F39),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C2F39)),
        fontFamily: 'Lexend',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// -------------------------------
  /// EXTRACT ROLL FROM EMAIL
  /// -------------------------------
  String _rollFromEmail(String email) {
    return email.split('@')[0].toUpperCase();
  }

  /// ---------------------------------------------------------
  /// LOGIN + STORE ROLL NUMBER
  /// ---------------------------------------------------------
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final String? error =
        await AuthService.instance.login(email, password);

    if (!mounted) return;

    if (error == null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        final rollNumber = _rollFromEmail(user.email!);

        final ref =
            FirebaseFirestore.instance.collection("users").doc(user.uid);

        final snap = await ref.get();

        if (!snap.exists) {
          // create profile
          await ref.set({
            "name": rollNumber,
            "department": "CSE",
            "year": "1",
            "rollNumber": rollNumber,
            "contact": "",
          });
        } else {
          // ensure rollNumber always matches email
          await ref.update({
            "rollNumber": rollNumber,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  // Forgot Password
  void _openForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Forgot password tapped")),
    );
  }

  // Outlook Sign-in (placeholder)
  Future<void> _signInWithOutlook() async {
    const clientId = 'YOUR_AZURE_APP_CLIENT_ID';
    const redirectUri = 'msauth://com.your.app/redirect';
    const scope = 'openid profile email offline_access';

    final authorizeUrl = Uri.https(
      'login.microsoftonline.com',
      '/common/oauth2/v2.0/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'response_mode': 'query',
        'scope': scope,
      },
    );

    if (await canLaunchUrl(authorizeUrl)) {
      await launchUrl(authorizeUrl,
          mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Outlook sign-in')),
      );
    }
  }

  /// ---------------------------------------------------------
  /// UI (UNCHANGED)
  /// ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF8C2F39);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 56),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),

                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDiQUacZ7nZa_jeyqNctfBo8LMORygeGPqIUEN4UMRhxjHnqxppOaVqZPjPorS7thY-dFjqrlK8sCI4FY783F5l_tB5tIDXLZkglnA_UbXJ0Y_pbCjErT7JxNAfSAGuV_AbLb7q73yNyabBSamPHQjDYVqO4cAx-gvaTcaUyUF5vog85cC14G29n54ekkqmPJVygl4baOgjDY5uKmRbyxJtUHRZw-dl25P56mHFB5q6I2E7uz8SuVIw8U-tiBN8n7A9kFnzw3YLBo-8',
                            height: 64,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Find what's lost on campus.",
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF999999)),
                      ),
                      const SizedBox(height: 28),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _label("Amrita Email"),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    _inputStyle(hint: "email", primary: primary),
                                validator: (v) =>
                                    v == null || !v.contains("@")
                                        ? "Enter valid email"
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              _label("Password"),
                              _passwordField(primary),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _isSubmitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text("Login",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      );

  InputDecoration _inputStyle(
          {required String hint, required Color primary}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  Widget _passwordField(Color primary) => TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: const InputDecoration(hintText: "Password"),
      );
}
