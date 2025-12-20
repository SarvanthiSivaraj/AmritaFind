import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';


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

  String _rollFromEmail(String email) {
    return email.split('@')[0].toUpperCase();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final String? error = await AuthService.instance.login(email, password);

    if (!mounted) return;

    if (error == null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        final rollNumber = _rollFromEmail(user.email!);

        final ref =
            FirebaseFirestore.instance.collection("users").doc(user.uid);

        final snap = await ref.get();

        if (!snap.exists) {
          await ref.set({
            "name": rollNumber,
            "department": "CSE",
            "year": "1",
            "rollNumber": rollNumber,
            "contact": "",
          });
        } else {
          await ref.update({"rollNumber": rollNumber});
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

  void _openForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Forgot password tapped")),
    );
  }

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
    }
  }

  // ==========================
  // UI MATCHING HTML
  // ==========================
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFBF0C4F);
    const background = Color(0xFFFAF9F6);
    const border = Color(0xFFE7CFD1);
    const textMain = Color(0xFF1B0D0E);
    const textMuted = Color(0xFF9A4C52);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Logo
                    Container(
                      height: 96,
                      width: 96,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Image.network(
                        'https://img.jagranjosh.com/images/2024/May/852024/Logo2.wsmf.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Login to report or find lost items.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _label("Email address"),
                    _textField(
                      controller: _emailController,
                      hint: "student@amrita.edu",
                      icon: Icons.mail_outline,
                      border: border,
                      primary: primary,
                      textMuted: textMuted,
                      validator: (v) =>
                          v == null || !v.contains("@")
                              ? "Enter valid email"
                              : null,
                    ),

                    const SizedBox(height: 20),

                    _label("Password"),
                    _textField(
                      controller: _passwordController,
                      hint: "Enter your password",
                      icon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      border: border,
                      primary: primary,
                      textMuted: textMuted,
                      obscure: _obscurePassword,
                      onIconTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (v) =>
                          v == null || v.length < 6
                              ? "Minimum 6 characters"
                              : null,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _openForgotPassword,
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Log In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B0D0E),
            ),
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color border,
    required Color primary,
    required Color textMuted,
    bool obscure = false,
    VoidCallback? onIconTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        suffixIcon: GestureDetector(
          onTap: onIconTap,
          child: Icon(icon, color: textMuted),
        ),
      ),
    );
  }
}
