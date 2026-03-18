import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Layout/premium_theme_controller.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: PremiumTheme.accentColor,
      builder: (context, accentColor, child) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome Back",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Log in to access your profile and premium features.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 30),
              _buildField("Email Address", CupertinoIcons.mail_solid, accentColor, false),
              const SizedBox(height: 16),
              _buildField("Password", CupertinoIcons.lock_fill, accentColor, true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    shadowColor: accentColor.withOpacity(0.5),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(String hint, IconData icon, Color accent, bool isPass) {
    return TextField(
      obscureText: isPass && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: isPass ? IconButton(
          icon: Icon(_isPasswordVisible ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill, color: Colors.white54),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accent, width: 2)),
      ),
    );
  }
}
