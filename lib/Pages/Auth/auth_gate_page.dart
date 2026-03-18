import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAuthPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true, // বাইরে ক্লিক করলে কেটে যাবে
    barrierLabel: "AuthPopup",
    transitionDuration: const Duration(milliseconds: 300), // স্মুথ এনিমেশন
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15 * animation.value, // ব্যাকগ্রাউন্ড ব্লার ইফেক্ট
          sigmaY: 15 * animation.value,
        ),
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1F23).withOpacity(0.85), // iOS Dark Glass
                  borderRadius: BorderRadius.circular(28), // রাউন্ডেড কর্নার
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // হালকা বর্ডার
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // যতটুকু জায়গা দরকার ততটুকু নিবে
                  children: [
                    // Premium Icon / Glowing Lock
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00C897).withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C897).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded, // এখানে আপনার 3D Lock ইমেজও দিতে পারেন
                        color: Color(0xFF00C897),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      "Access Restricted",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      "Please log in or create an account to unlock this premium feature.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9EA4AF),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // পপ-আপ বন্ধ করবে
                          // Navigator.pushNamed(context, '/login'); // লগইন পেজে নিয়ে যাবে
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C897),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Log In Now",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context), // পপ-আপ কেটে দিবে
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory, // iOS স্টাইল (নো স্প্ল্যাশ)
                      ),
                      child: Text(
                        "Maybe Later",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9EA4AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

