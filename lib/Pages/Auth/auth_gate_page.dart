import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// গুগল এবং এক্স আইকনের জন্য প্যাকেজ ইম্পোর্ট
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

// এই ফাংশনটি একটি ফুল-স্ক্রিন পপ-আপ ওপেন করবে যা Grok-এর মতো ডিজাইন করা হয়েছে।
void showAuthPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    // পপ-আপটি ফুল-স্ক্রিন হবে
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
    // প্রিমিয়াম ব্ল্যাক থিম
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ১. উপরের 'Skip' বাটন
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // পপ-আপটি বন্ধ করার জন্য
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

              // ২. মাঝের অংশ (লোগো এবং টেক্সট)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Grok লোগো টেক্সট
                      const Text(
                        "Grok",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64, // বড় ফন্ট
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32), // গ্যাপ
                      // সাব-টেক্সট ১
                      const Text(
                        "Thanks for trying Grok.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // সাব-টেক্সট ২
                      const Text(
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

              // ৩. নিচের অংশ (লগ-ইন বাটন এবং শর্তাবলী)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // গুগল বাটন
                  _buildAuthButton(
                    icon: MdiIcons.google, // গুগল আইকন
                    text: "Continue with Google",
                    onPressed: () {
                      // গুগলের লগ-ইন লজিক এখানে
                    },
                  ),
                  const SizedBox(height: 16),
                  // ইমেল বাটন
                  _buildAuthButton(
                    icon: Icons.email_outlined, // ইমেল আইকন
                    text: "Continue with Email",
                    onPressed: () {
                      // ইমেলের লগ-ইন লজিক এখানে
                    },
                  ),
                  const SizedBox(height: 16),
                  // এক্স (X) বাটন
                  _buildAuthButton(
                    icon: MdiIcons.twitter, // এক্স (X) আইকন (টুইটারের লোগো হিসেবে)
                    text: "Continue with X",
                    onPressed: () {
                      // এক্স-এর লগ-ইন লজিক এখানে
                    },
                  ),
                  const SizedBox(height: 32),
                  // শর্তাবলী এবং প্রাইভেসী পলিসি টেক্সট
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

  // বাটন তৈরির জন্য একটি সাহায্যকারী ফাংশন
  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // গাঢ় ধূসর রং
        borderRadius: BorderRadius.circular(30), // গোলাকার কোণা
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12), // আইকন এবং টেক্সটের মাঝের গ্যাপ
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
