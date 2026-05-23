 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

// Auth Popup দেখানোর জন্য এই function call করুন
void showAuthPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const VxAuthGateContent();
    },
  );
}

class VxAuthGateContent extends StatelessWidget {
  const VxAuthGateContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // মাঝখানের অংশ (Logo and Text)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Name with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFF4FB3),
                            Color(0xFFB24FF3),
                            Color(0xFF4F9DFF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "Vx",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Welcome to Vx",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Discover short videos that will\nmake your day. Join millions of\ncreators and viewers.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Feature highlights
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureChip("📹 Create"),
                          const SizedBox(width: 12),
                          _buildFeatureChip("❤️ Like"),
                          const SizedBox(width: 12),
                          _buildFeatureChip("💬 Comment"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // নিচের অংশ (Login Buttons)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAuthButton(
                    icon: MdiIcons.google,
                    text: "Continue with Google",
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4FB3), Color(0xFFB24FF3)],
                    ),
                    onPressed: () {
                      // Google Login Logic
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Google login coming soon"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    icon: Icons.email_outlined,
                    text: "Continue with Email",
                    gradient: null,
                    onPressed: () {
                      // Email Login Logic
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email login coming soon"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    icon: Icons.phone_android,
                    text: "Continue with Phone",
                    gradient: null,
                    onPressed: () {
                      // Phone Login Logic
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Phone login coming soon"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      "By continuing you agree to our\nTerms of Service and Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature chip widget
  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Auth button builder
  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    LinearGradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? const Color(0xFF1E1E1E) : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: const Color(0xFFFF4FB3).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

