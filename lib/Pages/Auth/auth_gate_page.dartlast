import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// গুগল এবং এক্স আইকনের জন্য প্যাকেজ (আগে কমান্ড দিয়ে অ্যাড করে নিবেন)
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

// এই ফাংশনটি কল করলে ফুল-স্ক্রিন পপ-আপ ওপেন হবে
void showAuthPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black, // ব্যাকগ্রাউন্ড কালো
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const GrokAuthGateContent();
    },
  );
}

class GrokAuthGateContent extends StatelessWidget {
  const GrokAuthGateContent({super.key});

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
              // ১. উপরের Skip বাটন
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
                    ),
                  ),
                ),
              ),

              // ২. মাঝের অংশ (Logo and Text)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Grok",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Thanks for trying Grok.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // এখানে const নেই, তাই withOpacity এরর দিবে না
                      Text(
                        "You've logged out. We can't wait to\nhave you back to explore the\nuniverse with Grok",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ৩. নিচের অংশ (Login Buttons)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAuthButton(
                    icon: MdiIcons.google,
                    text: "Continue with Google",
                    onPressed: () {
                      // Google Login Logic
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    icon: Icons.email_outlined,
                    text: "Continue with Email",
                    onPressed: () {
                      // Email Login Logic
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildAuthButton(
                    icon: MdiIcons.twitter,
                    text: "Continue with X",
                    onPressed: () {
                      // X Login Logic
                    },
                  ),
                  const SizedBox(height: 32),
                  // এখানেও withOpacity ঠিক করা হয়েছে
                  Center(
                    child: Text(
                      "By continuing you agree to Terms and\nPrivacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
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

  // বাটন তৈরির হেল্পার ফাংশন
  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // ডার্ক গ্রে ব্যাকগ্রাউন্ড
        borderRadius: BorderRadius.circular(30),
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
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
